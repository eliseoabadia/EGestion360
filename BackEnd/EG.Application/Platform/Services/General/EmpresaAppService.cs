using Mapster;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Platform.Settings;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;

namespace EG.Application.Services.General
{
    public class EmpresaAppService : IEmpresaAppService
    {
        private readonly GenericService<Empresa, EmpresaDto, EmpresaResponse> _service;
        private readonly GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> _serviceView;
        private readonly DocumentStorageSettings _storageSettings;
        private readonly EGestionContext _context;
        public EmpresaAppService(
            GenericService<Empresa, EmpresaDto, EmpresaResponse> service,
            GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> serviceView,
            IOptions<DocumentStorageSettings> storageOptions,
            EGestionContext context)
        {
            _service = service;
            _serviceView = serviceView;
            _storageSettings = storageOptions.Value;
            _context = context;
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
                "NombreCorto",
                "Rfc",
                "RazonSocial",
                "RegImss"
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
                var response = result.Adapt<List<EmpresaResponse>>();
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
                await HydrateLogoAsync(empresa);
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

                NormalizeCoreFields(dto);

                if (string.IsNullOrWhiteSpace(dto.Nombre) || string.IsNullOrWhiteSpace(dto.Rfc))
                    throw new ArgumentException("El nombre y RFC son campos obligatorios");

                dto.FechaCreacion = DateTime.Now;
                dto.UsuarioCreacion = usuarioActual;
                dto.Activo = true;
                dto.PkidEmpresa = 0;
                dto.Rfc = dto.Rfc.Trim().ToUpper();
                dto.NombreCorto = NormalizeNombreCorto(dto.NombreCorto, dto.Nombre);
                NormalizeDatosPatronales(dto);
                NormalizeLogoStorage(dto);

                if (!await _service.CanAddAsync(dto))
                {
                    var rfcExists = await _service.GetQueryWithIncludes()
                        .AnyAsync(e => e.Rfc.ToLower() == dto.Rfc.ToLower() && e.Activo);
                    if (rfcExists)
                        throw new InvalidOperationException($"El RFC '{dto.Rfc}' ya está registrado para otra empresa activa");

                    throw new InvalidOperationException("No se pudo validar la empresa");
                }

                await _service.AddAsync(dto);
                await UpsertEmpresaEstadoAsync(dto.PkidEmpresa, dto);
                await _context.SaveChangesAsync();
                var empresaCreada = await _serviceView.GetByIdAsync(dto.PkidEmpresa, idPropertyName: "PkidEmpresa");
                await HydrateLogoAsync(empresaCreada);
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

                NormalizeCoreFields(dto);

                if (string.IsNullOrWhiteSpace(dto.Nombre) || string.IsNullOrWhiteSpace(dto.Rfc))
                    throw new ArgumentException("El nombre y RFC son campos obligatorios");

                var empresaActual = await _context.Empresas
                    .FirstOrDefaultAsync(item => item.PkidEmpresa == id);

                if (empresaActual == null)
                    throw new InvalidOperationException("Empresa no encontrada");

                dto.PkidEmpresa = id;
                dto.Activo = empresaActual.Activo;
                dto.FechaCreacion = empresaActual.FechaCreacion;
                dto.UsuarioCreacion = empresaActual.UsuarioCreacion ?? dto.UsuarioCreacion;
                dto.FechaModificacion = DateTime.Now;
                dto.UsuarioModificacion = usuarioActual;
                dto.Rfc = dto.Rfc.Trim().ToUpper();
                dto.NombreCorto = NormalizeNombreCorto(dto.NombreCorto, dto.Nombre);
                NormalizeDatosPatronales(dto);

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

                ApplyEmpresaChanges(empresaActual, dto, usuarioActual);
                ApplyLogoStorage(empresaActual, dto);
                await UpsertEmpresaEstadoAsync(id, dto);
                await _context.SaveChangesAsync();

                var empresaActualizada = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidEmpresa");
                await HydrateLogoAsync(empresaActualizada);
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
                var empresa = _empresa.Adapt<EmpresaDto>();
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

        public async Task<EmpresaResponse> UpdateLogoAsync(int id, string logo, byte[] logoEmpresa, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de empresa invalido", nameof(id));

            var empresa = await _context.Empresas.FirstOrDefaultAsync(item => item.PkidEmpresa == id);
            if (empresa == null)
                throw new InvalidOperationException("Empresa no encontrada");

            var mode = NormalizeStorageMode(_storageSettings.Mode);
            if (mode == "FILESYSTEM")
            {
                if (string.IsNullOrWhiteSpace(logo))
                    throw new InvalidOperationException("La ruta del logo es requerida en modo FILESYSTEM");

                empresa.Logo = logo.Trim();
                empresa.LogoEmpresa = null;
            }
            else
            {
                if (logoEmpresa == null || logoEmpresa.Length == 0)
                    throw new InvalidOperationException("El archivo del logo es requerido en modo DATABASE");

                empresa.Logo = null;
                empresa.LogoEmpresa = logoEmpresa;
            }

            empresa.FechaModificacion = DateTime.Now;
            empresa.UsuarioModificacion = usuarioActual;
            await _context.SaveChangesAsync();

            var response = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidEmpresa");
            await HydrateLogoAsync(response);
            return response;
        }

        private static void ApplyEmpresaChanges(Empresa empresa, EmpresaDto dto, int usuarioActual)
        {
            empresa.Nombre = dto.Nombre;
            empresa.NombreCorto = dto.NombreCorto;
            empresa.Rfc = dto.Rfc;
            empresa.RazonSocial = dto.RazonSocial;
            empresa.Giro = dto.Giro;
            empresa.FkidMonedaBaseSis = dto.FkidMonedaBaseSis > 0
                ? dto.FkidMonedaBaseSis
                : empresa.FkidMonedaBaseSis;
            empresa.FkidIdiomaPreferidoSis = dto.FkidIdiomaPreferidoSis;
            empresa.RegImss = dto.RegImss;
            empresa.RegInfonavit = dto.RegInfonavit;
            empresa.CedEmpadronam = dto.CedEmpadronam;
            empresa.NoFonacot = dto.NoFonacot;
            empresa.UsAdmin = dto.UsAdmin;
            empresa.EmailAdmin = dto.EmailAdmin;
            empresa.FkidPeriodoPagoSis = dto.FkidPeriodoPagoSis;
            empresa.PrimaRiesgoImss = dto.PrimaRiesgoImss;
            empresa.UsaSueldoTabular = dto.UsaSueldoTabular;
            empresa.FkidTipoPagoNom = dto.FkidTipoPagoNom;
            empresa.FechaModificacion = DateTime.Now;
            empresa.UsuarioModificacion = usuarioActual;
        }

        private void ApplyLogoStorage(Empresa empresa, EmpresaDto dto)
        {
            var mode = NormalizeStorageMode(_storageSettings.Mode);
            if (mode == "FILESYSTEM")
            {
                if (!string.IsNullOrWhiteSpace(dto.Logo))
                {
                    empresa.Logo = dto.Logo.Trim();
                }

                empresa.LogoEmpresa = null;
                return;
            }

            empresa.Logo = null;
            if (dto.LogoEmpresa is { Length: > 0 })
            {
                empresa.LogoEmpresa = dto.LogoEmpresa;
            }
        }

        private async Task UpsertEmpresaEstadoAsync(int empresaId, EmpresaDto dto)
        {
            if (empresaId <= 0 || dto.PkidEstado <= 0)
            {
                return;
            }

            var relaciones = await _context.EmpresaEstados
                .Where(item => item.FkidEmpresaSis == empresaId)
                .ToListAsync();

            var relacionActual = relaciones
                .FirstOrDefault(item => item.FkidEstadoSis == dto.PkidEstado);

            foreach (var relacion in relaciones)
            {
                relacion.Activo = relacion.FkidEstadoSis == dto.PkidEstado;
            }

            if (relacionActual == null)
            {
                _context.EmpresaEstados.Add(new EmpresaEstado
                {
                    FkidEmpresaSis = empresaId,
                    FkidEstadoSis = dto.PkidEstado,
                    FechaApertura = dto.FechaApertura,
                    EsOficinaPrincipal = dto.EsOficinaPrincipal,
                    Activo = true
                });
                return;
            }

            relacionActual.Activo = true;
            relacionActual.FechaApertura = dto.FechaApertura;
            relacionActual.EsOficinaPrincipal = dto.EsOficinaPrincipal;
        }

        private void NormalizeLogoStorage(EmpresaDto dto)
        {
            var mode = NormalizeStorageMode(_storageSettings.Mode);
            if (mode == "FILESYSTEM")
            {
                dto.Logo = string.IsNullOrWhiteSpace(dto.Logo) ? null : dto.Logo.Trim();
                dto.LogoEmpresa = null;
                return;
            }

            dto.Logo = null;
        }

        private async Task HydrateLogoAsync(EmpresaResponse empresa)
        {
            if (empresa == null)
            {
                return;
            }

            var logo = await _context.Empresas
                .AsNoTracking()
                .Where(item => item.PkidEmpresa == empresa.PkidEmpresa)
                .Select(item => new { item.Logo, item.LogoEmpresa })
                .FirstOrDefaultAsync();

            if (logo == null)
            {
                return;
            }

            empresa.Logo = logo.Logo;
            empresa.LogoEmpresa = logo.LogoEmpresa;
        }

        private static string NormalizeStorageMode(string? value)
        {
            var mode = (value ?? "DATABASE").Trim().ToUpperInvariant();
            return mode == "FILESYSTEM" ? "FILESYSTEM" : "DATABASE";
        }

        private static string NormalizeNombreCorto(string? nombreCorto, string nombre)
        {
            var value = string.IsNullOrWhiteSpace(nombreCorto)
                ? nombre
                : nombreCorto;

            value = (value ?? string.Empty).Trim();
            return value.Length <= 64 ? value : value[..64];
        }

        private static void NormalizeCoreFields(EmpresaDto dto)
        {
            dto.Nombre = TrimOrNull(dto.Nombre);
            dto.NombreCorto = TrimOrNull(dto.NombreCorto);
            dto.Rfc = TrimOrNull(dto.Rfc);
            dto.RazonSocial = TrimOrNull(dto.RazonSocial);
            dto.Giro = TrimOrNull(dto.Giro);
        }

        private static void NormalizeDatosPatronales(EmpresaDto dto)
        {
            dto.RegImss = TrimMax(dto.RegImss, 25);
            dto.RegInfonavit = TrimMax(dto.RegInfonavit, 25);
            dto.CedEmpadronam = TrimMax(dto.CedEmpadronam, 25);
            dto.NoFonacot = TrimMax(dto.NoFonacot, 25);
            dto.UsAdmin = TrimMax(dto.UsAdmin, 100);
            dto.EmailAdmin = TrimMax(dto.EmailAdmin, 100);
            dto.PrimaRiesgoImss = dto.PrimaRiesgoImss < 0 ? 0 : dto.PrimaRiesgoImss;
        }

        private static string TrimMax(string? value, int maxLength)
        {
            value = string.IsNullOrWhiteSpace(value) ? null : value.Trim();
            return value == null || value.Length <= maxLength ? value : value[..maxLength];
        }

        private static string TrimOrNull(string? value)
        {
            return string.IsNullOrWhiteSpace(value) ? null : value.Trim();
        }
    }
}
