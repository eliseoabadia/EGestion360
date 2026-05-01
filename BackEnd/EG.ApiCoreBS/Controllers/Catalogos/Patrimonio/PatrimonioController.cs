using AutoMapper;
using EG.ApiCoreBS.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PatrimonioController : ControllerBase
    {
        // Familias (ya existe en Almacen, pero agregamos referencia)
        private readonly GenericService<Familium, EG.Domain.DTOs.Requests.Almacen.FamiliaDto, EG.Domain.DTOs.Responses.Almacen.FamiliaResponse> _familiaService;
        
        // Nuevas entidades de Patrimonio
        private readonly GenericService<GrupoBien, GrupoBienDto, GrupoBienResponse> _grupoBienService;
        private readonly GenericService<TipoPatrimonio, TipoPatrimonioDto, TipoPatrimonioResponse> _tipoPatrimonioService;
        private readonly GenericService<TipoAdquisicion, TipoAdquisicionDto, TipoAdquisicionResponse> _tipoAdquisicionService;
        private readonly GenericService<Marca, MarcaDto, MarcaResponse> _marcaService;
        private readonly GenericService<Persona, EG.Domain.DTOs.Requests.Nomina.PersonaDto, EG.Domain.DTOs.Responses.Nomina.PersonaResponse> _personaService;
        
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public PatrimonioController(
            GenericService<Familium, EG.Domain.DTOs.Requests.Almacen.FamiliaDto, EG.Domain.DTOs.Responses.Almacen.FamiliaResponse> familiaService,
            GenericService<GrupoBien, GrupoBienDto, GrupoBienResponse> grupoBienService,
            GenericService<TipoPatrimonio, TipoPatrimonioDto, TipoPatrimonioResponse> tipoPatrimonioService,
            GenericService<TipoAdquisicion, TipoAdquisicionDto, TipoAdquisicionResponse> tipoAdquisicionService,
            GenericService<Marca, MarcaDto, MarcaResponse> marcaService,
            GenericService<Persona, EG.Domain.DTOs.Requests.Nomina.PersonaDto, EG.Domain.DTOs.Responses.Nomina.PersonaResponse> personaService,
            IMapper mapper,
            IUserContextService userContext)
        {
            _familiaService = familiaService;
            _grupoBienService = grupoBienService;
            _tipoPatrimonioService = tipoPatrimonioService;
            _tipoAdquisicionService = tipoAdquisicionService;
            _marcaService = marcaService;
            _personaService = personaService;
            _mapper = mapper;
            _userContext = userContext;
            
            ConfigureServices();
            ConfigureValidations();
        }

        private void ConfigureServices()
        {
            // GrupoBien - incluir navegación a Familia
            _grupoBienService.AddInclude(e => e.FkidFamiliaAlmaNavigation);
        }

        private void ConfigureValidations()
        {
            // GrupoBien - nombre único
            _grupoBienService.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_grupoBienService.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            // TipoPatrimonio - descripción única
            _tipoPatrimonioService.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_tipoPatrimonioService.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            // TipoAdquisicion - clave única
            _tipoAdquisicionService.AddValidationRule("UniqueClave", async (dto) =>
            {
                return !_tipoAdquisicionService.GetQueryWithIncludes()
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.Activo);
            });

            // Marca - descripción única
            _marcaService.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_marcaService.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });
        }

        #region GrupoBien Endpoints
        [HttpGet("grupos-bien")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetAllGruposBien()
        {
            var result = await _grupoBienService.GetAllAsync();
            return Ok(new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "Grupos de bien obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("grupos-bien/{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> GetGrupoBienById(int id)
        {
            var result = await _grupoBienService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

            return Ok(new PagedResult<GrupoBienResponse>
            {
                Success = true,
                Message = "Grupo de bien obtenido correctamente",
                Code = "SUCCESS",
                Items = new List<GrupoBienResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost("grupos-bien")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> CreateGrupoBien([FromBody] GrupoBienResponse response)
        {
            try
            {
                var dto = _mapper.Map<GrupoBienDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _grupoBienService.CanAddAsync(dto);
                await _grupoBienService.AddAsync(dto);

                var created = _grupoBienService.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

                return CreatedAtAction(nameof(GetGrupoBienById), new { id = created?.PkidGrupoBien }, 
                    new PagedResult<GrupoBienResponse>
                    {
                        Success = true,
                        Message = "Grupo de bien creado correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<GrupoBienResponse> { _mapper.Map<GrupoBienResponse>(created) } : new List<GrupoBienResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("grupos-bien/{id}")]
        public async Task<ActionResult<PagedResult<GrupoBienResponse>>> UpdateGrupoBien(int id, [FromBody] GrupoBienResponse response)
        {
            try
            {
                var existing = await _grupoBienService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<GrupoBienResponse> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

                var dto = _mapper.Map<GrupoBienDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _grupoBienService.CanUpdateAsync(id, dto);
                await _grupoBienService.UpdateAsync(id, dto);

                return Ok(new PagedResult<GrupoBienResponse>
                {
                    Success = true,
                    Message = "Grupo de bien actualizado correctamente",
                    Code = "SUCCESS",
                    Items = new List<GrupoBienResponse> { _mapper.Map<GrupoBienResponse>(await _grupoBienService.GetByIdAsync(id)) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<GrupoBienResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("grupos-bien/{id}")]
        public async Task<ActionResult<PagedResult<bool>>> DeleteGrupoBien(int id)
        {
            try
            {
                var existing = await _grupoBienService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Grupo de bien no encontrado", Code = "NOT_FOUND" });

                await _grupoBienService.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Grupo de bien eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }
        #endregion

        #region TipoPatrimonio Endpoints
        [HttpGet("tipos-patrimonio")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> GetAllTiposPatrimonio()
        {
            var result = await _tipoPatrimonioService.GetAllAsync();
            return Ok(new PagedResult<TipoPatrimonioResponse>
            {
                Success = true,
                Message = "Tipos de patrimonio obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("tipos-patrimonio/{id}")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> GetTipoPatrimonioById(int id)
        {
            var result = await _tipoPatrimonioService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<TipoPatrimonioResponse> { Success = false, Message = "Tipo de patrimonio no encontrado", Code = "NOT_FOUND" });

            return Ok(new PagedResult<TipoPatrimonioResponse>
            {
                Success = true,
                Message = "Tipo de patrimonio obtenido correctamente",
                Code = "SUCCESS",
                Items = new List<TipoPatrimonioResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost("tipos-patrimonio")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> CreateTipoPatrimonio([FromBody] TipoPatrimonioResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoPatrimonioDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _tipoPatrimonioService.CanAddAsync(dto);
                await _tipoPatrimonioService.AddAsync(dto);

                var created = _tipoPatrimonioService.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

                return CreatedAtAction(nameof(GetTipoPatrimonioById), new { id = created?.PkidTipoPatrimonio }, 
                    new PagedResult<TipoPatrimonioResponse>
                    {
                        Success = true,
                        Message = "Tipo de patrimonio creado correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<TipoPatrimonioResponse> { _mapper.Map<TipoPatrimonioResponse>(created) } : new List<TipoPatrimonioResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoPatrimonioResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("tipos-patrimonio/{id}")]
        public async Task<ActionResult<PagedResult<TipoPatrimonioResponse>>> UpdateTipoPatrimonio(int id, [FromBody] TipoPatrimonioResponse response)
        {
            try
            {
                var existing = await _tipoPatrimonioService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<TipoPatrimonioResponse> { Success = false, Message = "Tipo de patrimonio no encontrado", Code = "NOT_FOUND" });

                var dto = _mapper.Map<TipoPatrimonioDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _tipoPatrimonioService.CanUpdateAsync(id, dto);
                await _tipoPatrimonioService.UpdateAsync(id, dto);

                return Ok(new PagedResult<TipoPatrimonioResponse>
                {
                    Success = true,
                    Message = "Tipo de patrimonio actualizado correctamente",
                    Code = "SUCCESS",
                    Items = new List<TipoPatrimonioResponse> { _mapper.Map<TipoPatrimonioResponse>(await _tipoPatrimonioService.GetByIdAsync(id)) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoPatrimonioResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("tipos-patrimonio/{id}")]
        public async Task<ActionResult<PagedResult<bool>>> DeleteTipoPatrimonio(int id)
        {
            try
            {
                var existing = await _tipoPatrimonioService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Tipo de patrimonio no encontrado", Code = "NOT_FOUND" });

                await _tipoPatrimonioService.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Tipo de patrimonio eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }
        #endregion

        #region TipoAdquisicion Endpoints
        [HttpGet("tipos-adquisicion")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> GetAllTiposAdquisicion()
        {
            var result = await _tipoAdquisicionService.GetAllAsync();
            return Ok(new PagedResult<TipoAdquisicionResponse>
            {
                Success = true,
                Message = "Tipos de adquisición obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("tipos-adquisicion/{id}")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> GetTipoAdquisicionById(int id)
        {
            var result = await _tipoAdquisicionService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<TipoAdquisicionResponse> { Success = false, Message = "Tipo de adquisición no encontrado", Code = "NOT_FOUND" });

            return Ok(new PagedResult<TipoAdquisicionResponse>
            {
                Success = true,
                Message = "Tipo de adquisición obtenido correctamente",
                Code = "SUCCESS",
                Items = new List<TipoAdquisicionResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost("tipos-adquisicion")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> CreateTipoAdquisicion([FromBody] TipoAdquisicionResponse response)
        {
            try
            {
                var dto = _mapper.Map<TipoAdquisicionDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _tipoAdquisicionService.CanAddAsync(dto);
                await _tipoAdquisicionService.AddAsync(dto);

                var created = _tipoAdquisicionService.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Clave == dto.Clave && x.Activo);

                return CreatedAtAction(nameof(GetTipoAdquisicionById), new { id = created?.PkidTipoAdq }, 
                    new PagedResult<TipoAdquisicionResponse>
                    {
                        Success = true,
                        Message = "Tipo de adquisición creado correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<TipoAdquisicionResponse> { _mapper.Map<TipoAdquisicionResponse>(created) } : new List<TipoAdquisicionResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoAdquisicionResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("tipos-adquisicion/{id}")]
        public async Task<ActionResult<PagedResult<TipoAdquisicionResponse>>> UpdateTipoAdquisicion(int id, [FromBody] TipoAdquisicionResponse response)
        {
            try
            {
                var existing = await _tipoAdquisicionService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<TipoAdquisicionResponse> { Success = false, Message = "Tipo de adquisición no encontrado", Code = "NOT_FOUND" });

                var dto = _mapper.Map<TipoAdquisicionDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _tipoAdquisicionService.CanUpdateAsync(id, dto);
                await _tipoAdquisicionService.UpdateAsync(id, dto);

                return Ok(new PagedResult<TipoAdquisicionResponse>
                {
                    Success = true,
                    Message = "Tipo de adquisición actualizado correctamente",
                    Code = "SUCCESS",
                    Items = new List<TipoAdquisicionResponse> { _mapper.Map<TipoAdquisicionResponse>(await _tipoAdquisicionService.GetByIdAsync(id)) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<TipoAdquisicionResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("tipos-adquisicion/{id}")]
        public async Task<ActionResult<PagedResult<bool>>> DeleteTipoAdquisicion(int id)
        {
            try
            {
                var existing = await _tipoAdquisicionService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Tipo de adquisición no encontrado", Code = "NOT_FOUND" });

                await _tipoAdquisicionService.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Tipo de adquisición eliminado correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }
        #endregion

        #region Marca Endpoints
        [HttpGet("marcas")]
        public async Task<ActionResult<PagedResult<MarcaResponse>>> GetAllMarcas()
        {
            var result = await _marcaService.GetAllAsync();
            return Ok(new PagedResult<MarcaResponse>
            {
                Success = true,
                Message = "Marcas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("marcas/{id}")]
        public async Task<ActionResult<PagedResult<MarcaResponse>>> GetMarcaById(int id)
        {
            var result = await _marcaService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<MarcaResponse> { Success = false, Message = "Marca no encontrada", Code = "NOT_FOUND" });

            return Ok(new PagedResult<MarcaResponse>
            {
                Success = true,
                Message = "Marca obtenida correctamente",
                Code = "SUCCESS",
                Items = new List<MarcaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost("marcas")]
        public async Task<ActionResult<PagedResult<MarcaResponse>>> CreateMarca([FromBody] MarcaResponse response)
        {
            try
            {
                var dto = _mapper.Map<MarcaDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _marcaService.CanAddAsync(dto);
                await _marcaService.AddAsync(dto);

                var created = _marcaService.GetQueryWithIncludes()
                    .FirstOrDefault(x => x.Descripcion == dto.Descripcion && x.Activo);

                return CreatedAtAction(nameof(GetMarcaById), new { id = created?.PkidMarca }, 
                    new PagedResult<MarcaResponse>
                    {
                        Success = true,
                        Message = "Marca creada correctamente",
                        Code = "SUCCESS",
                        Items = created != null ? new List<MarcaResponse> { _mapper.Map<MarcaResponse>(created) } : new List<MarcaResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MarcaResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("marcas/{id}")]
        public async Task<ActionResult<PagedResult<MarcaResponse>>> UpdateMarca(int id, [FromBody] MarcaResponse response)
        {
            try
            {
                var existing = await _marcaService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<MarcaResponse> { Success = false, Message = "Marca no encontrada", Code = "NOT_FOUND" });

                var dto = _mapper.Map<MarcaDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _marcaService.CanUpdateAsync(id, dto);
                await _marcaService.UpdateAsync(id, dto);

                return Ok(new PagedResult<MarcaResponse>
                {
                    Success = true,
                    Message = "Marca actualizada correctamente",
                    Code = "SUCCESS",
                    Items = new List<MarcaResponse> { _mapper.Map<MarcaResponse>(await _marcaService.GetByIdAsync(id)) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<MarcaResponse> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("marcas/{id}")]
        public async Task<ActionResult<PagedResult<bool>>> DeleteMarca(int id)
        {
            try
            {
                var existing = await _marcaService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Marca no encontrada", Code = "NOT_FOUND" });

                await _marcaService.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Marca eliminada correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }
        #endregion

        #region Persona Endpoints
        [HttpGet("personas")]
        public async Task<ActionResult<PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>>> GetAllPersonas()
        {
            var result = await _personaService.GetAllAsync();
            return Ok(new PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>
            {
                Success = true,
                Message = "Personas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Cast<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>().ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("personas/{id}")]
        public async Task<ActionResult<PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>>> GetPersonaById(int id)
        {
            var result = await _personaService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse> 
                { Success = false, Message = "Persona no encontrada", Code = "NOT_FOUND" });

            return Ok(new PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>
            {
                Success = true,
                Message = "Persona obtenida correctamente",
                Code = "SUCCESS",
                Items = new List<EG.Domain.DTOs.Responses.Nomina.PersonaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost("personas")]
        public async Task<ActionResult<PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>>> CreatePersona([FromBody] EG.Domain.DTOs.Responses.Nomina.PersonaResponse response)
        {
            try
            {
                var dto = _mapper.Map<EG.Domain.DTOs.Requests.Nomina.PersonaDto>(response);
                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.UtcNow;

                await _personaService.CanAddAsync(dto);
                await _personaService.AddAsync(dto);

                return CreatedAtAction(nameof(GetPersonaById), new { id = dto.PkidPersona }, 
                    new PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>
                    {
                        Success = true,
                        Message = "Persona creada correctamente",
                        Code = "SUCCESS",
                        Items = new List<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>(),
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse> 
                    { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpPut("personas/{id}")]
        public async Task<ActionResult<PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>>> UpdatePersona(int id, [FromBody] EG.Domain.DTOs.Responses.Nomina.PersonaResponse response)
        {
            try
            {
                var existing = await _personaService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse> 
                        { Success = false, Message = "Persona no encontrada", Code = "NOT_FOUND" });

                var dto = _mapper.Map<EG.Domain.DTOs.Requests.Nomina.PersonaDto>(response);
                dto.UsuarioCreacion = existing.UsuarioCreacion;
                dto.FechaCreacion = existing.FechaCreacion;
                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.UtcNow;

                await _personaService.CanUpdateAsync(id, dto);
                await _personaService.UpdateAsync(id, dto);

                return Ok(new PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse>
                {
                    Success = true,
                    Message = "Persona actualizada correctamente",
                    Code = "SUCCESS",
                    Items = new List<EG.Domain.DTOs.Responses.Nomina.PersonaResponse> { await _personaService.GetByIdAsync(id) },
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EG.Domain.DTOs.Responses.Nomina.PersonaResponse> 
                    { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }

        [HttpDelete("personas/{id}")]
        public async Task<ActionResult<PagedResult<bool>>> DeletePersona(int id)
        {
            try
            {
                var existing = await _personaService.GetByIdAsync(id);
                if (existing == null)
                    return NotFound(new PagedResult<bool> { Success = false, Message = "Persona no encontrada", Code = "NOT_FOUND" });

                await _personaService.DeleteAsync(id);
                return Ok(new PagedResult<bool> { Success = true, Message = "Persona eliminada correctamente", Code = "SUCCESS", Items = new List<bool> { true }, TotalCount = 1 });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<bool> { Success = false, Message = ex.Message, Code = "ERROR" });
            }
        }
        #endregion
    }
}
