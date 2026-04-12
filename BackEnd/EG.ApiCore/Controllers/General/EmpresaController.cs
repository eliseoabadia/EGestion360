using AutoMapper;
using EG.ApiCore.Services;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EmpresaController : ControllerBase
    {
        private readonly GenericService<Empresa, EmpresaDto, EmpresaResponse> _service;
        private readonly GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> _serviceView;
        private readonly IMapper _mapper;
        private readonly IUserContextService _userContext;

        public EmpresaController(
            GenericService<Empresa, EmpresaDto, EmpresaResponse> service,
            GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> serviceView,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            _userContext = userContext;

            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // Incluir navegaciones necesarias para búsquedas y ordenamientos en la entidad principal
            _service.AddInclude(e => e.FkidMonedaBaseSisNavigation);
            _service.AddInclude(e => e.FkidIdiomaPreferidoSisNavigation);

            // Configurar búsqueda en propiedades de relaciones (ej: nombre de moneda, idioma)
            _service.AddRelationFilter("FkidMonedaBaseSisNavigation", new List<string> { "Nombre" });
            _service.AddRelationFilter("FkidIdiomaPreferidoSisNavigation", new List<string> { "Nombre" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Nombre de empresa único (case-insensitive)
            _service.AddValidationRule("UniqueCompanyName", async (dto) =>
            {
                var empresaDto = dto as EmpresaDto;
                if (empresaDto == null) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(e => e.Nombre.ToLower() == empresaDto.Nombre.ToLower() && e.Activo);

                return !exists;
            });

            // REGLA 2: Nombre único en actualización (excluyendo la propia)
            _service.AddValidationRuleWithId("UniqueCompanyNameUpdate", async (dto, id) =>
            {
                var empresaDto = dto as EmpresaDto;
                if (empresaDto == null || !id.HasValue) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(e => e.Nombre.ToLower() == empresaDto.Nombre.ToLower() &&
                              e.PkidEmpresa != id.Value &&
                              e.Activo);

                return !exists;
            });

            // REGLA 3: RFC único (case-insensitive)
            _service.AddValidationRule("UniqueRfc", async (dto) =>
            {
                var empresaDto = dto as EmpresaDto;
                if (string.IsNullOrWhiteSpace(empresaDto?.Rfc)) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(e => e.Rfc.ToLower() == empresaDto.Rfc.ToLower() && e.Activo);

                return !exists;
            });

            // REGLA 4: RFC único en actualización
            _service.AddValidationRuleWithId("UniqueRfcUpdate", async (dto, id) =>
            {
                var empresaDto = dto as EmpresaDto;
                if (empresaDto == null || !id.HasValue || string.IsNullOrWhiteSpace(empresaDto.Rfc))
                    return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(e => e.Rfc.ToLower() == empresaDto.Rfc.ToLower() &&
                              e.PkidEmpresa != id.Value &&
                              e.Activo);

                return !exists;
            });

            // REGLA 5: Nombre no vacío y longitud >= 3 y <= 100
            _service.AddValidationRule("ValidNameLength", async (dto) =>
            {
                var empresaDto = dto as EmpresaDto;
                if (empresaDto == null) return false;
                return !string.IsNullOrWhiteSpace(empresaDto.Nombre) &&
                       empresaDto.Nombre.Length >= 3 &&
                       empresaDto.Nombre.Length <= 100;
            });

            // REGLA 6: Moneda base válida (FkidMonedaBaseSis > 0)
            _service.AddValidationRule("ValidMoneda", async (dto) =>
            {
                var empresaDto = dto as EmpresaDto;
                return empresaDto?.FkidMonedaBaseSis > 0;
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetById(int id)
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidEmpresa");

            if (result == null)
                return NotFound(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = "Empresa no encontrada",
                    Code = "NOTFOUND_COMPANY",
                    TotalCount = 0
                });

            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresa encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<EmpresaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Add([FromBody] EmpresaResponse response)
        {
            try
            {
                var dto = _mapper.Map<EmpresaDto>(response);

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<EmpresaResponse>
                    {
                        Success = false,
                        Message = "Ya existe una empresa activa con el mismo nombre o RFC",
                        Code = "DUPLICATE_COMPANY",
                        TotalCount = 0
                    });
                }

                dto.UsuarioCreacion = _userContext.GetCurrentUserId();
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true; // Las nuevas empresas se crean activas

                // TODO: Aquí deberías guardar la relación con Estado si es necesario
                // response.PkidEstado contiene el estado seleccionado.
                // Debes crear/actualizar un registro en EmpresaEstado.

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidEmpresa },
                    new PagedResult<EmpresaResponse>
                    {
                        Success = true,
                        Message = "Empresa creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = $"Error al crear empresa: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Update(int id, [FromBody] EmpresaResponse response)
        {
            try
            {
                var dto = _mapper.Map<EmpresaDto>(response);
                dto.PkidEmpresa = id;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<EmpresaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra empresa activa con el mismo nombre o RFC",
                        Code = "DUPLICATE_COMPANY",
                        TotalCount = 0
                    });
                }

                dto.UsuarioModificacion = _userContext.GetCurrentUserId();
                dto.FechaModificacion = DateTime.Now;

                // TODO: Actualizar la relación con Estado (EmpresaEstado)

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresa actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = $"Empresa con ID {id} no encontrada",
                    Code = "NOTFOUND_COMPANY",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Delete(int id)
        {
            try
            {
                // Opcional: validar si la empresa tiene dependencias (sucursales, usuarios, etc.)
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresa eliminada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = $"Empresa con ID {id} no encontrada",
                    Code = "NOTFOUND_COMPANY",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService(); // Reconfigurar includes si los necesitas para la vista

            var result = await _serviceView.GetAllPaginadoAsync(_params);
            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> BuscarEmpresas([FromBody] BusquedaRequest request)
        {
            _service.ClearConfiguration();
            ConfigureService();

            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _service.GetAllPaginadoAsync(pagedRequest);
            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresas filtradas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}