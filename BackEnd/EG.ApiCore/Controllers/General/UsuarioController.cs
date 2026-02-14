using AutoMapper;
using Azure;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Requests;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UsuarioController : ControllerBase
    {
        private readonly GenericService<Usuario, UsuarioDto, UsuarioResponse> _service;
        private readonly GenericService<VwUsuarioSucursal, UsuarioDto, UsuarioResponse> _serviceView;
        private readonly IMapper _mapper;

        public UsuarioController(
            GenericService<Usuario, UsuarioDto, UsuarioResponse> service,
            GenericService<VwUsuarioSucursal, UsuarioDto, UsuarioResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;

            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // ✅ VERSIÓN SIMPLE - Solo includes de primer nivel
            // EF Core cargará las propiedades anidadas cuando se acceda a ellas
            // o si están configuradas con eager loading por defecto
            _service.AddInclude(u => u.FkidEmpresaSisNavigation);
            _service.AddInclude(u => u.PerfilUsuario);
            _service.AddInclude(u => u.UsuarioSucursals);

            // Nota: Para acceder a FkidSucursalNavigation, aseguramos que esté en la consulta
            // a través de los filtros de relación

            // Configurar relaciones para búsqueda
            _service.AddRelationFilter("Empresa", new List<string> { "Nombre", "Rfc" });
            _service.AddRelationFilter("PerfilUsuario", new List<string> { "Rol", "NivelAcceso" });
            _service.AddRelationFilter("UsuarioSucursals", new List<string> {
                "FkidSucursalNavigation.Nombre",
                "FkidSucursalNavigation.Codigo"
            });

                    // Configurar filtros de búsqueda para la vista
                    _serviceView.AddRelationFilter("Usuario", new List<string> {
                "NombreUsuario", "ApellidoPaterno", "ApellidoMaterno", "Email", "PayrollId"
            });
                    _serviceView.AddRelationFilter("Sucursal", new List<string> {
                "NombreSucursal", "CodigoSucursal", "AliasSucursal"
            });
                    _serviceView.AddRelationFilter("Empresa", new List<string> {
                "NombreEmpresa", "RfcEmpresa"
            });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Validar email único (para creación)
            _service.AddValidationRule("UniqueEmail", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (usuarioDto == null || string.IsNullOrWhiteSpace(usuarioDto.Email))
                    return false;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(u => u.Email.ToLower() == usuarioDto.Email.ToLower() &&
                                  u.Activo);

                return !exists;
            });

            // REGLA 2: Validar email único para ACTUALIZACIÓN - CORREGIDA
            _service.AddValidationRuleWithId("UniqueEmailUpdate", async (dto, id) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (usuarioDto == null || !id.HasValue || string.IsNullOrWhiteSpace(usuarioDto.Email))
                    return true; // Si no hay email, no validamos (ya hay otra regla para campos obligatorios)

                // Buscar si existe OTRO usuario activo con el mismo email
                // IMPORTANTE: Excluimos el usuario actual por ID, sin importar sus sucursales
                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(u => u.Email.ToLower() == usuarioDto.Email.ToLower() &&
                                  u.PkIdUsuario != id.Value &&
                                  u.Activo);

                return !exists; // Retorna true si NO existe otro usuario con ese email (válido)
            });

            // REGLA 3: Validar PayrollId único por empresa (para creación)
            _service.AddValidationRule("UniquePayrollId", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (usuarioDto == null || string.IsNullOrWhiteSpace(usuarioDto.PayrollId))
                    return true; // Si no tiene PayrollId, no validamos

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(u => u.FkidEmpresaSis == usuarioDto.FkidEmpresaSis &&
                                  u.PayrollId.ToLower() == usuarioDto.PayrollId.ToLower() &&
                                  u.Activo);

                return !exists;
            });

            // REGLA 4: Validar PayrollId único por empresa para ACTUALIZACIÓN - CORREGIDA
            _service.AddValidationRuleWithId("UniquePayrollIdUpdate", async (dto, id) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (usuarioDto == null || !id.HasValue || string.IsNullOrWhiteSpace(usuarioDto.PayrollId))
                    return true; // Si no tiene PayrollId, no validamos

                // Buscar si existe OTRO usuario activo con el mismo PayrollId en la misma empresa
                // IMPORTANTE: Excluimos el usuario actual por ID
                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(u => u.FkidEmpresaSis == usuarioDto.FkidEmpresaSis &&
                                  u.PayrollId.ToLower() == usuarioDto.PayrollId.ToLower() &&
                                  u.PkIdUsuario != id.Value &&
                                  u.Activo);

                return !exists; // Retorna true si NO existe otro usuario con ese PayrollId (válido)
            });

            // RESTO DE VALIDACIONES (sin cambios)...
            // REGLA 5: Validar campos obligatorios
            _service.AddValidationRule("ValidNombre", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                return !string.IsNullOrWhiteSpace(usuarioDto?.Nombre);
            });

            _service.AddValidationRule("ValidApellidoPaterno", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                return !string.IsNullOrWhiteSpace(usuarioDto?.ApellidoPaterno);
            });

            // REGLA 6: Validar formato de email
            _service.AddValidationRule("ValidEmailFormat", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (string.IsNullOrWhiteSpace(usuarioDto?.Email))
                    return false;

                try
                {
                    var addr = new System.Net.Mail.MailAddress(usuarioDto.Email);
                    return addr.Address == usuarioDto.Email;
                }
                catch
                {
                    return false;
                }
            });

            // REGLA 7: Validar empresa válida
            _service.AddValidationRule("ValidCompany", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                return usuarioDto?.FkidEmpresaSis > 0;
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            var response = _mapper.Map<List<UsuarioResponse>>(result);
            return Ok(new { success = true, Items = response, TotalCount = response.Count });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetById(int id)
        {
            var usuario = await _serviceView.GetByIdAsync(id, idPropertyName: "PkIdUsuario");

            if (usuario == null)
            {
                return Ok(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = "Usuario no encontrado",
                    Code = "NOTFOUND_USER",
                    //Data = default,
                    Items = new List<UsuarioResponse>(),
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<UsuarioResponse>
            {
                Success = true,
                Message = "Usuario encontrado",
                Code = "SUCCESS",
                Data = usuario,
                Items = new List<UsuarioResponse> { usuario },
                TotalCount = 1
            });
        }

        [HttpGet("empresa/{empresaId}")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetByEmpresaId(int empresaId)
        {
            var result = await _serviceView.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 },
                u => u.IdEmpresa == empresaId && u.UsuarioActivo);

            var response = _mapper.Map<List<UsuarioResponse>>(result.Items);

            return Ok(new PagedResult<UsuarioResponse>
            {
                Success = true,
                Message = "Usuarios por empresa obtenidos correctamente",
                Code = "SUCCESS",
                Items = response,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost("GetAllUsuariosPaginado")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetAllUsuariosPaginado([FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(_params);
            return Ok(new PagedResult<UsuarioResponse>
            {
                Success = true,
                Message = "Usuarios obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpGet("sucursal/{sucursalId}")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> GetBySucursalId(int sucursalId)
        {
            var result = await _serviceView.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 },
                u => u.PkidSucursal == sucursalId && u.RelacionActiva);

            var response = _mapper.Map<List<UsuarioResponse>>(result.Items);

            return Ok(new PagedResult<UsuarioResponse>
            {
                Success = true,
                Message = "Usuarios por sucursal obtenidos correctamente",
                Code = "SUCCESS",
                Items = response,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> Add([FromBody] VwUsuarioSucursal viewDto)
        {
            try
            {
                // Validación básica del DTO
                if (viewDto == null)
                {
                    return BadRequest(new PagedResult<UsuarioResponse>
                    {
                        Success = false,
                        Message = "Los datos del usuario son requeridos",
                        Code = "INVALID_DATA",
                        TotalCount = 0
                    });
                }

                // Validar campos obligatorios mínimos
                if (string.IsNullOrWhiteSpace(viewDto.NombreCompleto) ||
                    string.IsNullOrWhiteSpace(viewDto.Email))
                {
                    return BadRequest(new PagedResult<UsuarioResponse>
                    {
                        Success = false,
                        Message = "El nombre y email son campos obligatorios",
                        Code = "MISSING_REQUIRED_FIELDS",
                        TotalCount = 0
                    });
                }

                // Mapear y preparar el DTO
                var dto = _mapper.Map<UsuarioDto>(viewDto);
                dto.FechaCreacion = DateTime.Now;
                dto.UsuarioCreacion = GetCurrentUserId();
                dto.Activo = true;

                // Asegurar que el email esté en minúsculas para consistencia
                if (!string.IsNullOrWhiteSpace(dto.Email))
                    dto.Email = dto.Email.ToLower().Trim();

                // Validar si puede agregar (aplicará todas las reglas de validación configuradas)
                if (!await _service.CanAddAsync(dto))
                {
                    // Verificar cuál es el conflicto específico para dar un mensaje más claro
                    var emailExists = await _service.GetQueryWithIncludes()
                        .AnyAsync(u => u.Email.ToLower() == dto.Email.ToLower() && u.Activo);

                    if (emailExists)
                    {
                        return Conflict(new PagedResult<UsuarioResponse>
                        {
                            Success = false,
                            Message = $"El email '{dto.Email}' ya está registrado para otro usuario activo",
                            Code = "DUPLICATE_EMAIL",
                            TotalCount = 0
                        });
                    }

                    // Verificar PayrollId si aplica
                    if (!string.IsNullOrWhiteSpace(dto.PayrollId))
                    {
                        var payrollExists = await _service.GetQueryWithIncludes()
                            .AnyAsync(u => u.FkidEmpresaSis == dto.FkidEmpresaSis &&
                                          u.PayrollId.ToLower() == dto.PayrollId.ToLower() &&
                                          u.Activo);

                        if (payrollExists)
                        {
                            return Conflict(new PagedResult<UsuarioResponse>
                            {
                                Success = false,
                                Message = $"El Payroll ID '{dto.PayrollId}' ya está registrado para otro usuario activo en esta empresa",
                                Code = "DUPLICATE_PAYROLL",
                                TotalCount = 0
                            });
                        }
                    }

                    // Mensaje genérico si no se identificó el conflicto específico
                    return Conflict(new PagedResult<UsuarioResponse>
                    {
                        Success = false,
                        Message = "El email o payroll ID ya existe para un usuario activo",
                        Code = "DUPLICATE_USER",
                        TotalCount = 0
                    });
                }

                // Guardar el usuario
                await _service.AddAsync(dto);

                // Obtener el usuario creado para devolverlo
                var usuarioCreado = await _serviceView.GetByIdAsync(dto.PkIdUsuario, idPropertyName: "PkIdUsuario");
                var response = _mapper.Map<UsuarioResponse>(usuarioCreado);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkIdUsuario },
                    new PagedResult<UsuarioResponse>
                    {
                        Success = true,
                        Message = "Usuario creado correctamente",
                        Code = "SUCCESS",
                        Data = response,
                        Items = new List<UsuarioResponse> { response },
                        TotalCount = 1
                    });
            }
            catch (DbUpdateException dbEx)
            {
                // Error específico de base de datos
                var innerMessage = dbEx.InnerException?.Message ?? dbEx.Message;
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Error de base de datos al crear usuario: {innerMessage}",
                    Code = "DB_ERROR",
                    TotalCount = 0
                });
            }
            catch (AutoMapperMappingException mapEx)
            {
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Error al mapear los datos del usuario: {mapEx.Message}",
                    Code = "MAPPING_ERROR",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Error al crear usuario: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> Update(int id, [FromBody] VwUsuarioSucursal viewDto)
        {
            try
            {
                // Validar que el ID coincida
                if (id != viewDto.PkIdUsuario)
                {
                    return BadRequest(new PagedResult<UsuarioResponse>
                    {
                        Success = false,
                        Message = "El ID del usuario no coincide con el parámetro de la URL",
                        Code = "ID_MISMATCH",
                        TotalCount = 0
                    });
                }

                // Validar campos obligatorios mínimos
                if (string.IsNullOrWhiteSpace(viewDto.NombreCompleto) ||
                    string.IsNullOrWhiteSpace(viewDto.Email))
                {
                    return BadRequest(new PagedResult<UsuarioResponse>
                    {
                        Success = false,
                        Message = "El nombre y email son campos obligatorios",
                        Code = "MISSING_REQUIRED_FIELDS",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<UsuarioDto>(viewDto);
                dto.PkIdUsuario = id;
                dto.FechaModificacion = DateTime.Now;
                dto.UsuarioModificacion = GetCurrentUserId();

                // Asegurar que el email esté en minúsculas para consistencia
                if (!string.IsNullOrWhiteSpace(dto.Email))
                    dto.Email = dto.Email.ToLower().Trim();

                // Validar si puede actualizar
                var canUpdate = await _service.CanUpdateAsync(id, dto);

                if (!canUpdate)
                {
                    // Verificar cuál es el conflicto específico
                    var existingUser = await _service.GetQueryWithIncludes()
                        .FirstOrDefaultAsync(u => u.Email.ToLower() == dto.Email.ToLower() &&
                                                u.PkIdUsuario != id &&
                                                u.Activo);

                    if (existingUser != null)
                    {
                        return Conflict(new PagedResult<UsuarioResponse>
                        {
                            Success = false,
                            Message = $"El email '{dto.Email}' ya está siendo utilizado por otro usuario activo (ID: {existingUser.PkIdUsuario})",
                            Code = "DUPLICATE_EMAIL",
                            TotalCount = 0
                        });
                    }

                    // Verificar conflicto por PayrollId
                    if (!string.IsNullOrWhiteSpace(dto.PayrollId))
                    {
                        existingUser = await _service.GetQueryWithIncludes()
                            .FirstOrDefaultAsync(u => u.FkidEmpresaSis == dto.FkidEmpresaSis &&
                                                    u.PayrollId.ToLower() == dto.PayrollId.ToLower() &&
                                                    u.PkIdUsuario != id &&
                                                    u.Activo);

                        if (existingUser != null)
                        {
                            return Conflict(new PagedResult<UsuarioResponse>
                            {
                                Success = false,
                                Message = $"El Payroll ID '{dto.PayrollId}' ya está siendo utilizado por otro usuario activo en esta empresa (ID: {existingUser.PkIdUsuario})",
                                Code = "DUPLICATE_PAYROLL",
                                TotalCount = 0
                            });
                        }
                    }

                    // Mensaje genérico si no se identificó el conflicto
                    return Conflict(new PagedResult<UsuarioResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro usuario activo con ese email o payroll ID en esta empresa",
                        Code = "DUPLICATE_USER",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                // Obtener el usuario actualizado para devolverlo
                var usuarioActualizado = await _serviceView.GetByIdAsync(id, idPropertyName: "PkIdUsuario");
                var response = _mapper.Map<UsuarioResponse>(usuarioActualizado);

                return Ok(new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = "Usuario actualizado correctamente",
                    Code = "SUCCESS",
                    Data = response,
                    Items = new List<UsuarioResponse> { response },
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Usuario con ID {id} no encontrado",
                    Code = "NOTFOUND_USER",
                    TotalCount = 0
                });
            }
            catch (DbUpdateException dbEx)
            {
                var innerMessage = dbEx.InnerException?.Message ?? dbEx.Message;
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Error de base de datos al actualizar usuario: {innerMessage}",
                    Code = "DB_ERROR",
                    TotalCount = 0
                });
            }
            catch (AutoMapperMappingException mapEx)
            {
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Error al mapear los datos del usuario: {mapEx.Message}",
                    Code = "MAPPING_ERROR",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = "Usuario eliminado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Usuario con ID {id} no encontrado",
                    Code = "NOTFOUND_USER",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPatch("{id}/cambiar-estado")]
        public async Task<ActionResult<PagedResult<UsuarioResponse>>> CambiarEstado(int id, [FromBody] bool activo)
        {
            try
            {
                var usuario = await _service.GetByIdAsync(id, idPropertyName: "PkIdUsuario");
                if (usuario == null)
                {
                    return NotFound(new PagedResult<UsuarioResponse>
                    {
                        Success = false,
                        Message = "Usuario no encontrado",
                        Code = "NOTFOUND_USER",
                        TotalCount = 0
                    });
                }

                var dto = _mapper.Map<UsuarioDto>(usuario);
                dto.Activo = activo;
                dto.FechaModificacion = DateTime.Now;
                dto.UsuarioModificacion = GetCurrentUserId();

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = $"Usuario {(activo ? "activado" : "desactivado")} correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = $"Error al cambiar estado: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        private int GetCurrentUserId()
        {
            // Busca primero el claim "UserId"
            var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == "UserId");

            // Si no existe, intenta con "sub" (usado en JWT estándar)
            if (userIdClaim == null)
                userIdClaim = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier || c.Type == "sub");

            if (userIdClaim != null && int.TryParse(userIdClaim.Value, out int userId))
            {
                return userId;
            }

            // Si no se encuentra, lanza excepción o devuelve 0 en lugar de un valor fijo
            throw new InvalidOperationException("No se pudo obtener el ID del usuario autenticado.");
        }
    }
}