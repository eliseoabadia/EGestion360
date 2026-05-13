using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General
{
    public class EmpresaAppService : IEmpresaAppService
    {
        private readonly GenericService<Empresa, EmpresaDto, EmpresaResponse> _service;
        private readonly GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> _serviceView;
        private readonly IMapper _mapper;

        public EmpresaAppService(
            GenericService<Empresa, EmpresaDto, EmpresaResponse> service,
            GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> serviceView,
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
            // Includes para la entidad Empresa
            _service.AddInclude(e => e.EmpresaEstados);
            _service.AddInclude(e => e.Sucursals);
            _service.AddInclude(e => e.Departamentos);

            // Filtros de relación para búsquedas avanzadas
            _service.AddRelationFilter("EmpresaEstados", new List<string>
            {
                "FkidEstadoSisNavigation.Nombre",
                "FkidEstadoSisNavigation.CodigoEstado",
                "FechaApertura",
                "EsOficinaPrincipal"
            });

            _service.AddRelationFilter("Sucursals", new List<string>
            {
                "Nombre",
                "Codigo",
                "Direccion"
            });

            // Filtros para la vista VwEstadoEmpresa
            _serviceView.AddRelationFilter("Estado", new List<string>
            {
                "EstadoNombre",
                "CodigoEstado",
                "FkidPaisSis"
            });

            _serviceView.AddRelationFilter("Empresa", new List<string>
            {
                "EmpresaNombre",
                "Rfc",
                "RazonSocial"
            });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: RFC único (creación)
            _service.AddValidationRule("UniqueRfc", async (dto) =>
            {
                var empresaDto = dto as EmpresaDto;
                if (empresaDto == null || string.IsNullOrWhiteSpace(empresaDto.Rfc))
                    return false;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(e => e.Rfc.ToLower() == empresaDto.Rfc.ToLower() && e.Activo);

                return !exists;
            });

            // REGLA 2: RFC único (actualización)
            _service.AddValidationRuleWithId("UniqueRfcUpdate", async (dto, id) =>
            {
                var empresaDto = dto as EmpresaDto;
                if (empresaDto == null || !id.HasValue || string.IsNullOrWhiteSpace(empresaDto.Rfc))
                    return true;

                var exists = await _service.GetQueryWithIncludes()
                    .AnyAsync(e => e.Rfc.ToLower() == empresaDto.Rfc.ToLower() &&
                                   e.PkidEmpresa != id.Value &&
                                   e.Activo);

                return !exists;
            });

            // REGLA 3: Nombre obligatorio
            _service.AddValidationRule("ValidNombre", async (dto) =>
            {
                var empresaDto = dto as EmpresaDto;
                return !string.IsNullOrWhiteSpace(empresaDto?.Nombre);
            });

            // REGLA 4: RFC obligatorio y formato básico
            _service.AddValidationRule("ValidRfc", async (dto) =>
            {
                var empresaDto = dto as EmpresaDto;
                if (string.IsNullOrWhiteSpace(empresaDto?.Rfc))
                    return false;
                var rfc = empresaDto.Rfc.Trim().ToUpper();
                return rfc.Length >= 12 && rfc.Length <= 13;
            });

            // REGLA 5: Moneda base válida
            _service.AddValidationRule("ValidMonedaBase", async (dto) =>
            {
                var empresaDto = dto as EmpresaDto;
                return empresaDto?.FkidMonedaBaseSis > 0;
            });

            // REGLA 6: Razón social obligatoria
            _service.AddValidationRule("ValidRazonSocial", async (dto) =>
            {
                var empresaDto = dto as EmpresaDto;
                return !string.IsNullOrWhiteSpace(empresaDto?.RazonSocial);
            });
        }

        public async Task<PagedResult<EmpresaResponse>> GetAllAsync()
        {
            try
            {
                var result = await _serviceView.GetAllAsync();
                var response = _mapper.Map<List<EmpresaResponse>>(result);
                return new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresas obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = response,
                    TotalCount = response.Count
                };
            }
            catch (Exception ex)
            {
                // Log4NetLogger.Error($"Error en GetAllAsync: {ex.Message}", ex);
                return new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<EmpresaResponse> GetByIdAsync(int id)
        {
            try
            {
                var empresa = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidEmpresa");
                return empresa;
            }
            catch (Exception ex)
            {
                // Log4NetLogger.Error($"Error en GetByIdAsync: {ex.Message}", ex);
                return null;
            }
        }

        public async Task<PagedResult<EmpresaResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            try
            {
                // Limpiar configuración previa y volver a aplicar (por si acaso)
                _serviceView.ClearConfiguration();
                ConfigureService();

                var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
                return new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresas obtenidas correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                // Log4NetLogger.Error($"Error en GetAllPaginadoAsync: {ex.Message}", ex);
                return new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<EmpresaResponse> CreateAsync(EmpresaDto dto, int usuarioActual)
        {
            try
            {
                if (dto == null)
                    throw new ArgumentNullException(nameof(dto), "Los datos de la empresa son requeridos");

                if (string.IsNullOrWhiteSpace(dto.Nombre) || string.IsNullOrWhiteSpace(dto.Rfc))
                    throw new ArgumentException("El nombre y RFC son campos obligatorios");

                dto.FechaCreacion = DateTime.Now;
                dto.UsuarioCreacion = usuarioActual;
                dto.Activo = true;
                dto.Rfc = dto.Rfc.Trim().ToUpper();

                if (!await _service.CanAddAsync(dto))
                {
                    var rfcExists = await _service.GetQueryWithIncludes()
                        .AnyAsync(e => e.Rfc.ToLower() == dto.Rfc.ToLower() && e.Activo);
                    if (rfcExists)
                        throw new InvalidOperationException($"El RFC '{dto.Rfc}' ya está registrado para otra empresa activa");

                    throw new InvalidOperationException("No se pudo validar la empresa");
                }

                await _service.AddAsync(dto);
                var empresaCreada = await _serviceView.GetByIdAsync(dto.PkidEmpresa, idPropertyName: "PkidEmpresa");
                return empresaCreada;
            }
            catch (Exception ex)
            {
                // Log4NetLogger.Error($"Error en CreateAsync: {ex.Message}", ex);
                throw;
            }
        }

        public async Task<EmpresaResponse> UpdateAsync(int id, EmpresaDto dto, int usuarioActual)
        {
            try
            {
                if (dto == null)
                    throw new ArgumentNullException(nameof(dto), "Los datos de la empresa son requeridos");
                if (id <= 0)
                    throw new ArgumentException("ID de empresa inválido", nameof(id));
                if (string.IsNullOrWhiteSpace(dto.Nombre) || string.IsNullOrWhiteSpace(dto.Rfc))
                    throw new ArgumentException("El nombre y RFC son campos obligatorios");

                dto.PkidEmpresa = id;
                dto.FechaModificacion = DateTime.Now;
                dto.UsuarioModificacion = usuarioActual;
                dto.Rfc = dto.Rfc.Trim().ToUpper();

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    var rfcExists = await _service.GetQueryWithIncludes()
                        .AnyAsync(e => e.Rfc.ToLower() == dto.Rfc.ToLower() &&
                                       e.PkidEmpresa != id &&
                                       e.Activo);
                    if (rfcExists)
                        throw new InvalidOperationException($"El RFC '{dto.Rfc}' ya está registrado para otra empresa activa");

                    throw new InvalidOperationException("No se pudo validar la empresa");
                }

                await _service.UpdateAsync(id, dto);
                var empresaActualizada = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidEmpresa");
                return empresaActualizada;
            }
            catch (Exception ex)
            {
                // Log4NetLogger.Error($"Error en UpdateAsync: {ex.Message}", ex);
                throw;
            }
        }

        public async Task<PagedResult<EmpresaResponse>> BuscarAsync(BusquedaRequest request)
        {
            try
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
                return new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresas filtradas correctamente",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            try
            {
                if (id <= 0)
                    throw new ArgumentException("ID de empresa inválido", nameof(id));

                var _empresa = await _service.GetByIdAsync(id, idPropertyName: "PkidEmpresa");
                var empresa = _mapper.Map<EmpresaDto>(_empresa);
                if (empresa == null)
                    throw new InvalidOperationException("Empresa no encontrada");

                empresa.Activo = false;
                empresa.FechaModificacion = DateTime.Now;
                empresa.UsuarioModificacion = usuarioActual;

                await _service.UpdateAsync(id, empresa);
                return true;
            }
            catch (Exception ex)
            {
                // Log4NetLogger.Error($"Error en DeleteAsync: {ex.Message}", ex);
                throw;
            }
        }
    }
}
