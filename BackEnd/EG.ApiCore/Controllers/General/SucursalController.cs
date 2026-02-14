using AutoMapper;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class SucursalController : ControllerBase
    {
        private readonly GenericService<Sucursal, SucursalDto, SucursalResponse> _service;
        private readonly IMapper _mapper;

        public SucursalController(
            GenericService<Sucursal, SucursalDto, SucursalResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;

            //ConfigureService();
        }

        private void ConfigureService()
        {
            // Incluir propiedades de navegación
            _service.AddInclude(s => s.FkidEmpresaSisNavigation);
            _service.AddInclude(s => s.FkidEstadoSisNavigation);

            // Configurar relaciones para búsqueda
            _service.AddRelationFilter("Empresa", new List<string> { "Nombre", "Rfc" });
            _service.AddRelationFilter("Estado", new List<string> { "Nombre" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Validar código único por empresa para CREACIÓN
            _service.AddValidationRule("UniqueSucursalCodePerCompany", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;
                if (sucursalDto == null) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(s => s.FkidEmpresaSis == sucursalDto.FkidEmpresaSis &&
                             s.CodigoSucursal.ToLower() == sucursalDto.CodigoSucursal.ToLower() &&
                             s.Activo);

                return !exists;
            });

            // REGLA 2: Validar código único por empresa para ACTUALIZACIÓN (excluyendo el actual)
            _service.AddValidationRuleWithId("UniqueSucursalCodePerCompanyUpdate", async (dto, id) =>
            {
                var sucursalDto = dto as SucursalDto;
                if (sucursalDto == null || !id.HasValue) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(s => s.FkidEmpresaSis == sucursalDto.FkidEmpresaSis &&
                             s.CodigoSucursal.ToLower() == sucursalDto.CodigoSucursal.ToLower() &&
                             s.PkidSucursal != id.Value &&
                             s.Activo);

                return !exists;
            });

            // REGLA 3: Validar nombre único por empresa
            _service.AddValidationRule("UniqueSucursalNamePerCompany", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;
                if (sucursalDto == null) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(s => s.FkidEmpresaSis == sucursalDto.FkidEmpresaSis &&
                             s.Nombre.ToLower() == sucursalDto.Nombre.ToLower() &&
                             s.Activo);

                return !exists;
            });

            // REGLA 4: Validar nombre único por empresa para ACTUALIZACIÓN
            _service.AddValidationRuleWithId("UniqueSucursalNamePerCompanyUpdate", async (dto, id) =>
            {
                var sucursalDto = dto as SucursalDto;
                if (sucursalDto == null || !id.HasValue) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(s => s.FkidEmpresaSis == sucursalDto.FkidEmpresaSis &&
                             s.Nombre.ToLower() == sucursalDto.Nombre.ToLower() &&
                             s.PkidSucursal != id.Value &&
                             s.Activo);

                return !exists;
            });

            // REGLA 5: Validar que el nombre no esté vacío y tenga al menos 3 caracteres
            _service.AddValidationRule("ValidNameLength", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;
                return !string.IsNullOrWhiteSpace(sucursalDto?.Nombre) && sucursalDto.Nombre.Length >= 3;
            });

            // REGLA 6: Validar código no vacío
            _service.AddValidationRule("ValidCode", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;
                return !string.IsNullOrWhiteSpace(sucursalDto?.CodigoSucursal);
            });

            // REGLA 7: Validar que la empresa sea válida
            _service.AddValidationRule("ValidCompany", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;
                return sucursalDto?.FkidEmpresaSis > 0;
            });

            // REGLA 8: Validar horarios (apertura menor que cierre)
            _service.AddValidationRule("ValidBusinessHours", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;

                if (sucursalDto?.HorarioApertura.HasValue == true &&
                    sucursalDto?.HorarioCierre.HasValue == true)
                {
                    return sucursalDto.HorarioApertura.Value < sucursalDto.HorarioCierre.Value;
                }

                return true;
            });

            // REGLA 9: Validar formato de email si se proporciona
            _service.AddValidationRule("ValidEmail", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;

                if (string.IsNullOrWhiteSpace(sucursalDto?.Email))
                    return true;

                try
                {
                    var addr = new System.Net.Mail.MailAddress(sucursalDto.Email);
                    return addr.Address == sucursalDto.Email;
                }
                catch
                {
                    return false;
                }
            });

            // REGLA 10: Validar que solo haya una matriz por empresa
            _service.AddValidationRule("OnlyOneMatrizPerCompany", async (dto) =>
            {
                var sucursalDto = dto as SucursalDto;
                if (sucursalDto == null || !sucursalDto.EsMatriz) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(s => s.FkidEmpresaSis == sucursalDto.FkidEmpresaSis &&
                             s.EsMatriz &&
                             s.Activo);

                return !exists;
            });

            // REGLA 11: Validar que solo haya una matriz por empresa para ACTUALIZACIÓN
            _service.AddValidationRuleWithId("OnlyOneMatrizPerCompanyUpdate", async (dto, id) =>
            {
                var sucursalDto = dto as SucursalDto;
                if (sucursalDto == null || !sucursalDto.EsMatriz || !id.HasValue) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(s => s.FkidEmpresaSis == sucursalDto.FkidEmpresaSis &&
                             s.EsMatriz &&
                             s.PkidSucursal != id.Value &&
                             s.Activo);

                return !exists;
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<SucursalResponse>
            {
                Success = true,
                Message = "Sucursales obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidSucursal");

            if (result == null)
                return NotFound(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = "Sucursal no encontrada",
                    Code = "NOTFOUND_SUCURSAL",
                    TotalCount = 0
                });

            return Ok(new PagedResult<SucursalResponse>
            {
                Success = true,
                Message = "Sucursal encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<SucursalResponse> { result },
                TotalCount = 1
            });
        }

        [HttpGet("empresa/{empresaId}")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> GetByEmpresaId(int empresaId)
        {
            var result = await _service.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 },
                s => s.FkidEmpresaSis == empresaId && s.Activo);

            return Ok(new PagedResult<SucursalResponse>
            {
                Success = true,
                Message = "Sucursales por empresa obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpGet("empresa/{empresaId}/activas")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> GetActiveByEmpresaId(int empresaId)
        {
            var result = await _service.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 },
                s => s.FkidEmpresaSis == empresaId && s.EsActiva && s.Activo);

            return Ok(new PagedResult<SucursalResponse>
            {
                Success = true,
                Message = "Sucursales activas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpGet("empresa/{empresaId}/matriz")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> GetMatrizByEmpresaId(int empresaId)
        {
            var result = await _service.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1 },
                s => s.FkidEmpresaSis == empresaId && s.EsMatriz && s.Activo);

            var matriz = result.Items?.FirstOrDefault();

            if (matriz == null)
                return NotFound(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = "No se encontró una sucursal matriz para esta empresa",
                    Code = "NOTFOUND_MATRIZ",
                    TotalCount = 0
                });

            return Ok(new PagedResult<SucursalResponse>
            {
                Success = true,
                Message = "Sucursal matriz encontrada",
                Code = "SUCCESS",
                Data = matriz,
                Items = new List<SucursalResponse> { matriz },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> Create([FromBody] SucursalDto dto)
        {
            try
            {
                ConfigureValidations();

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<SucursalResponse>
                    {
                        Success = false,
                        Message = "Ya existe una sucursal activa con ese código o nombre en esta empresa",
                        Code = "DUPLICATE_SUCURSAL",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidSucursal },
                    new PagedResult<SucursalResponse>
                    {
                        Success = true,
                        Message = "Sucursal creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = $"Error al crear sucursal: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> Update(int id, [FromBody] SucursalDto dto)
        {
            try
            {
                dto.PkidSucursal = id;
                ConfigureValidations();

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<SucursalResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra sucursal activa con ese código o nombre en esta empresa, o ya hay una matriz definida",
                        Code = "DUPLICATE_SUCURSAL",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<SucursalResponse>
                {
                    Success = true,
                    Message = "Sucursal actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = $"Sucursal con ID {id} no encontrada",
                    Code = "NOTFOUND_SUCURSAL",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> Delete(int id)
        {
            try
            {
                var sucursal = await _service.GetByIdAsync(id, idPropertyName: "PkidSucursal");

                if (sucursal != null && sucursal.EsMatriz)
                {
                    return BadRequest(new PagedResult<SucursalResponse>
                    {
                        Success = false,
                        Message = "No se puede eliminar la sucursal matriz. Desactive o reasigne la matriz primero.",
                        Code = "CANNOT_DELETE_MATRIZ",
                        TotalCount = 0
                    });
                }

                await _service.DeleteAsync(id);

                return Ok(new PagedResult<SucursalResponse>
                {
                    Success = true,
                    Message = "Sucursal eliminada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = $"Sucursal con ID {id} no encontrada",
                    Code = "NOTFOUND_SUCURSAL",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPatch("{id}/estado")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> CambiarEstadoActivo(int id, [FromBody] bool activo)
        {
            try
            {
                var sucursal = await _service.GetByIdAsync(id, idPropertyName: "PkidSucursal");

                if (sucursal == null)
                    return NotFound(new PagedResult<SucursalResponse>
                    {
                        Success = false,
                        Message = "Sucursal no encontrada",
                        Code = "NOTFOUND_SUCURSAL",
                        TotalCount = 0
                    });

                if (sucursal.EsMatriz && !activo)
                {
                    var otrasActivas = await _service.GetAllPaginadoAsync(
                        new PagedRequest { Page = 1, PageSize = 1 },
                        s => s.FkidEmpresaSis == sucursal.FkidEmpresaSis &&
                             s.PkidSucursal != id &&
                             s.Activo);

                    if (!otrasActivas.Items.Any())
                    {
                        return BadRequest(new PagedResult<SucursalResponse>
                        {
                            Success = false,
                            Message = "No se puede desactivar la única sucursal activa de la empresa",
                            Code = "CANNOT_DEACTIVATE_LAST",
                            TotalCount = 0
                        });
                    }
                }

                var dto = _mapper.Map<SucursalDto>(sucursal);
                dto.Activo = activo;

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<SucursalResponse>
                {
                    Success = true,
                    Message = $"Sucursal {(activo ? "activada" : "desactivada")} correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = $"Error al cambiar estado: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPatch("{id}/activar")]
        public async Task<ActionResult> CambiarEsActiva(int id, [FromBody] bool esActiva)
        {
            try
            {
                var sucursal = await _service.GetByIdAsync(id, idPropertyName: "PkidSucursal");

                if (sucursal == null)
                    return NotFound(new { success = false, message = "Sucursal no encontrada" });

                var dto = _mapper.Map<SucursalDto>(sucursal);
                dto.EsActiva = esActiva;

                await _service.UpdateAsync(id, dto);

                return Ok(new { success = true, message = $"Sucursal marcada como {(esActiva ? "activa" : "inactiva")} correctamente" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = $"Error al cambiar estado operativo: {ex.Message}" });
            }
        }
    }
}