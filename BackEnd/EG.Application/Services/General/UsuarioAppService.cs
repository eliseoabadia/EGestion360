using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using System.Net.Mail;

namespace EG.Application.Services.General
{
    public class UsuarioAppService : IUsuarioAppService
    {
        private readonly GenericService<Usuario, UsuarioDto, UsuarioResponse> _service;
        private readonly GenericService<VwUsuarioEmpresa, UsuarioDto, UsuarioResponse> _serviceView;
        private readonly IMapper _mapper;

        public UsuarioAppService(
            GenericService<Usuario, UsuarioDto, UsuarioResponse> service,
            GenericService<VwUsuarioEmpresa, UsuarioDto, UsuarioResponse> serviceView,
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
            // Includes de primer nivel
            _service.AddInclude(u => u.FkidEmpresaSisNavigation);
            _service.AddInclude(u => u.PerfilUsuario);
            _service.AddInclude(u => u.UsuarioSucursals);

            // Filtros de relación
            _service.AddRelationFilter("Empresa", new List<string> { "Nombre", "Rfc" });
            _service.AddRelationFilter("PerfilUsuario", new List<string> { "Rol", "NivelAcceso" });
            _service.AddRelationFilter("UsuarioSucursals", new List<string> 
            { 
                "FkidSucursalNavigation.Nombre",
                "FkidSucursalNavigation.Codigo"
            });

            // Filtros para la vista
            _serviceView.AddRelationFilter("Usuario", new List<string>
            {
                "NombreUsuario", "ApellidoPaterno", "ApellidoMaterno", "Email", "PayrollId"
            });
            _serviceView.AddRelationFilter("Sucursal", new List<string>
            {
                "NombreSucursal", "CodigoSucursal", "AliasSucursal"
            });
            _serviceView.AddRelationFilter("Empresa", new List<string>
            {
                "NombreEmpresa", "RfcEmpresa"
            });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Email único (creación)
            _service.AddValidationRule("UniqueEmail", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (usuarioDto == null || string.IsNullOrWhiteSpace(usuarioDto.Email))
                    return false;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(u => u.Email.ToLower() == usuarioDto.Email.ToLower() && u.Activo);

                return !exists;
            });

            // REGLA 2: Email único (actualización)
            _service.AddValidationRuleWithId("UniqueEmailUpdate", async (dto, id) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (usuarioDto == null || !id.HasValue || string.IsNullOrWhiteSpace(usuarioDto.Email))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(u => u.Email.ToLower() == usuarioDto.Email.ToLower() &&
                                   u.PkIdUsuario != id.Value &&
                                   u.Activo);

                return !exists;
            });

            // REGLA 3: PayrollId único por empresa (creación)
            _service.AddValidationRule("UniquePayrollId", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (usuarioDto == null || string.IsNullOrWhiteSpace(usuarioDto.PayrollId))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(u => u.FkidEmpresaSis == usuarioDto.FkidEmpresaSis &&
                                   u.PayrollId.ToLower() == usuarioDto.PayrollId.ToLower() &&
                                   u.Activo);

                return !exists;
            });

            // REGLA 4: PayrollId único por empresa (actualización)
            _service.AddValidationRuleWithId("UniquePayrollIdUpdate", async (dto, id) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (usuarioDto == null || !id.HasValue || string.IsNullOrWhiteSpace(usuarioDto.PayrollId))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(u => u.FkidEmpresaSis == usuarioDto.FkidEmpresaSis &&
                                   u.PayrollId.ToLower() == usuarioDto.PayrollId.ToLower() &&
                                   u.PkIdUsuario != id.Value &&
                                   u.Activo);

                return !exists;
            });

            // REGLA 5: Nombre obligatorio
            _service.AddValidationRule("ValidNombre", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                return !string.IsNullOrWhiteSpace(usuarioDto?.Nombre);
            });

            // REGLA 6: Apellido paterno obligatorio
            _service.AddValidationRule("ValidApellidoPaterno", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                return !string.IsNullOrWhiteSpace(usuarioDto?.ApellidoPaterno);
            });

            // REGLA 7: Email válido
            _service.AddValidationRule("ValidEmailFormat", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                if (string.IsNullOrWhiteSpace(usuarioDto?.Email))
                    return false;

                try
                {
                    var addr = new MailAddress(usuarioDto.Email);
                    return addr.Address == usuarioDto.Email;
                }
                catch
                {
                    return false;
                }
            });

            // REGLA 8: Empresa válida
            _service.AddValidationRule("ValidCompany", async (dto) =>
            {
                var usuarioDto = dto as UsuarioDto;
                return usuarioDto?.FkidEmpresaSis > 0;
            });
        }

        public async Task<PagedResult<UsuarioResponse>> GetAllAsync()
        {
            try
            {
                var result = await _serviceView.GetAllAsync();
                var response = _mapper.Map<List<UsuarioResponse>>(result);
                
                return new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = "Usuarios obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = response,
                    TotalCount = response.Count
                };
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en GetAllAsync: {ex.Message}", ex);
                return new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    //Items = new(),
                    TotalCount = 0
                };
            }
        }

        public async Task<UsuarioResponse> GetByIdAsync(int id)
        {
            try
            {
                var usuario = await _serviceView.GetByIdAsync(id, idPropertyName: "PkIdUsuario");
                return usuario;
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en GetByIdAsync: {ex.Message}", ex);
                return null;
            }
        }

        public async Task<PagedResult<UsuarioResponse>> GetAllPaginadoAsync(PagedRequest pageRequest, Func<UsuarioResponse, bool> predicate = null)
        {
            try
            {
                _serviceView.ClearConfiguration();
                ConfigureService();

                var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
                return new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = "Usuarios obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en GetAllPaginadoAsync: {ex.Message}", ex);
                return new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    //Items = new(),
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<UsuarioResponse>> GetByEmpresaIdAsync(int empresaId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = 1000 },
                    u => u.IdEmpresa == empresaId && u.UsuarioActivo);

                var response = _mapper.Map<List<UsuarioResponse>>(result.Items);

                return new PagedResult<UsuarioResponse>
                {
                    Success = true,
                    Message = "Usuarios por empresa obtenidos correctamente",
                    Code = "SUCCESS",
                    Items = response,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en GetByEmpresaIdAsync: {ex.Message}", ex);
                return new PagedResult<UsuarioResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    //Items = new(),
                    TotalCount = 0
                };
            }
        }

        public async Task<UsuarioResponse> CreateAsync(UsuarioDto dto, int usuarioActual)
        {
            try
            {
                if (dto == null)
                    throw new ArgumentNullException(nameof(dto), "Los datos del usuario son requeridos");

                // Validar campos obligatorios mínimos
                if (string.IsNullOrWhiteSpace(dto.Nombre) || string.IsNullOrWhiteSpace(dto.Email))
                    throw new ArgumentException("El nombre y email son campos obligatorios");

                // Preparar DTO
                dto.FechaCreacion = DateTime.Now;
                dto.UsuarioCreacion = usuarioActual;
                dto.Activo = true;
                dto.Email = dto.Email.ToLower().Trim();

                // Validar todas las reglas de negocio
                if (!await _service.CanAddAsync(dto))
                {
                    // Validar email único
                    var emailExists = await _service.GetQueryWithIncludes()
                        .AnyAsync(u => u.Email.ToLower() == dto.Email.ToLower() && u.Activo);

                    if (emailExists)
                        throw new InvalidOperationException($"El email '{dto.Email}' ya está registrado para otro usuario activo");

                    // Validar PayrollId único por empresa
                    if (!string.IsNullOrWhiteSpace(dto.PayrollId))
                    {
                        var payrollExists = await _service.GetQueryWithIncludes()
                            .AnyAsync(u => u.FkidEmpresaSis == dto.FkidEmpresaSis &&
                                           u.PayrollId.ToLower() == dto.PayrollId.ToLower() &&
                                           u.Activo);

                        if (payrollExists)
                            throw new InvalidOperationException($"El Payroll ID '{dto.PayrollId}' ya está registrado para otro usuario activo en esta empresa");
                    }

                    throw new InvalidOperationException("El email o payroll ID ya existe para un usuario activo");
                }

                // Guardar usuario
                await _service.AddAsync(dto);

                // Obtener usuario creado
                var usuarioCreado = await _serviceView.GetByIdAsync(dto.PkIdUsuario, idPropertyName: "PkIdUsuario");
                return usuarioCreado;
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en CreateAsync: {ex.Message}", ex);
                throw;
            }
        }

        public async Task<UsuarioResponse> UpdateAsync(int id, UsuarioDto dto, int usuarioActual)
        {
            try
            {
                if (dto == null)
                    throw new ArgumentNullException(nameof(dto), "Los datos del usuario son requeridos");

                if (id <= 0)
                    throw new ArgumentException("ID de usuario inválido", nameof(id));

                // Validar campos obligatorios
                if (string.IsNullOrWhiteSpace(dto.Nombre) || string.IsNullOrWhiteSpace(dto.Email))
                    throw new ArgumentException("El nombre y email son campos obligatorios");

                // Preparar DTO
                dto.PkIdUsuario = id;
                dto.FechaModificacion = DateTime.Now;
                dto.UsuarioModificacion = usuarioActual;
                dto.Email = dto.Email.ToLower().Trim();

                // Validar todas las reglas de negocio (con ID)
                if (!await _service.CanUpdateAsync(id, dto))
                {
                    // Validar email único
                    var emailExists = await _service.GetQueryWithIncludes()
                        .AnyAsync(u => u.Email.ToLower() == dto.Email.ToLower() &&
                                       u.PkIdUsuario != id &&
                                       u.Activo);

                    if (emailExists)
                        throw new InvalidOperationException($"El email '{dto.Email}' ya está registrado para otro usuario activo");

                    // Validar PayrollId único
                    if (!string.IsNullOrWhiteSpace(dto.PayrollId))
                    {
                        var payrollExists = await _service.GetQueryWithIncludes()
                            .AnyAsync(u => u.FkidEmpresaSis == dto.FkidEmpresaSis &&
                                           u.PayrollId.ToLower() == dto.PayrollId.ToLower() &&
                                           u.PkIdUsuario != id &&
                                           u.Activo);

                        if (payrollExists)
                            throw new InvalidOperationException($"El Payroll ID '{dto.PayrollId}' ya está registrado para otro usuario activo en esta empresa");
                    }

                    throw new InvalidOperationException("El email o payroll ID ya existe para un usuario activo");
                }

                // Actualizar usuario
                await _service.UpdateAsync(id, dto);

                // Obtener usuario actualizado
                var usuarioActualizado = await _serviceView.GetByIdAsync(id, idPropertyName: "PkIdUsuario");
                return usuarioActualizado;
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en UpdateAsync: {ex.Message}", ex);
                throw;
            }
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                if (id <= 0)
                    throw new ArgumentException("ID de usuario inválido", nameof(id));

                // Obtener usuario
                var _usuario = await _service.GetByIdAsync(id, idPropertyName: "PkIdUsuario");

                var usuario = _mapper.Map<UsuarioDto>(_usuario);

                if (usuario == null)
                    throw new InvalidOperationException("Usuario no encontrado");

                // Marcar como inactivo (soft delete)
                usuario.Activo = false;
                usuario.FechaModificacion = DateTime.Now;
                usuario.UsuarioModificacion = usuarioActual;

                await _service.UpdateAsync(id, usuario);
                return true;
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en DeleteAsync: {ex.Message}", ex);
                throw;
            }
        }
    }
}