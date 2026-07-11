using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    public class RequisicionAppService
        : AdquisicionCrudAppService<Requisicion, VwRequisicion, RequisicionDto, RequisicionResponse>,
            IRequisicionAppService
    {
        private readonly GenericService<Cotizacion, CotizacionDto, CotizacionResponse> _cotizacionService;
        private readonly EGestionContext _context;

        public RequisicionAppService(
            GenericService<Requisicion, RequisicionDto, RequisicionResponse> service,
            GenericService<VwRequisicion, RequisicionDto, RequisicionResponse> serviceView,
            GenericService<Cotizacion, CotizacionDto, CotizacionResponse> cotizacionService,
            EGestionContext context)
            : base(
                service,
                serviceView,
                "PkidRequisicion",
                "Requisicion",
                (dto, id) => dto.PkidRequisicion = id)
        {
            _cotizacionService = cotizacionService;
            _context = context;
        }

        public override async Task<PagedResult<RequisicionResponse>> CreateAsync(
            RequisicionResponse response,
            int usuarioActual)
        {
            try
            {
                await ValidateClasificacionAsync(response);
                if (!await OrcoProyectoCatalog.EnsureProyectoOrcoAsync(_context, response.FkidProyectoOrco, usuarioActual))
                {
                    return InvalidProyectoResult(response.FkidProyectoOrco);
                }

                var spResult = await ExecuteMantenimientoAsync(1, null, response, usuarioActual);
                response.PkidRequisicion = spResult.GetId() ?? 0;
                var result = await GetByIdAsync(response.PkidRequisicion);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (ArgumentException ex)
            {
                return ValidationResult(ex.Message);
            }
            catch (Exception ex)
            {
                return new PagedResult<RequisicionResponse>
                {
                    Success = false,
                    Message = $"Error al crear Requisicion: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public override async Task<PagedResult<RequisicionResponse>> GetAllAsync()
        {
            var result = await base.GetAllAsync();
            ApplyCotizacionLocks(result.Items);
            return result;
        }

        public override async Task<PagedResult<RequisicionResponse>> GetByIdAsync(int id)
        {
            var result = await base.GetByIdAsync(id);
            if (result.Success)
            {
                ApplyCotizacionLocks(result.Items);
                if (result.Data != null)
                {
                    result.Data.CotizacionesActivas = CountActiveCotizaciones(id);
                }
            }

            return result;
        }

        public override async Task<PagedResult<RequisicionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await base.GetAllPaginadoAsync(request);
            ApplyCotizacionLocks(result.Items);
            return result;
        }

        public override async Task<PagedResult<RequisicionResponse>> UpdateAsync(
            int id,
            RequisicionResponse response,
            int usuarioActual)
        {
            if (IsLocked(id))
            {
                return LockedResult("La requisicion ya esta vinculada a una cotizacion activa. Liberala para poder editarla.");
            }

            try
            {
                await ValidateClasificacionAsync(response);
                if (!await OrcoProyectoCatalog.EnsureProyectoOrcoAsync(_context, response.FkidProyectoOrco, usuarioActual))
                {
                    return InvalidProyectoResult(response.FkidProyectoOrco);
                }

                var spResult = await ExecuteMantenimientoAsync(2, id, response, usuarioActual);
                var result = await GetByIdAsync(id);
                result.Message = spResult.Mensaje;
                return result;
            }
            catch (ArgumentException ex)
            {
                return ValidationResult(ex.Message);
            }
            catch (Exception ex)
            {
                return new PagedResult<RequisicionResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar Requisicion: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
            => await DeleteAsync(id, 0);

        public async Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual)
        {
            if (IsLocked(id))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "La requisicion ya esta vinculada a una cotizacion activa. Liberala para poder eliminarla.",
                    Code = "LOCKED",
                    Data = false,
                    Items = new List<bool> { false },
                    TotalCount = 0
                };
            }

            try
            {
                var spResult = await StoredProcedureExecutor.ExecuteResultAsync(
                    _context,
                    "[ORCO].[SP_MantenimientoRequisicion]",
                    StoredProcedureExecutor.Param("@Action", 3),
                    StoredProcedureExecutor.Param("@PKIdRequisicion", id),
                    StoredProcedureExecutor.Param("@IdUser", usuarioActual > 0 ? usuarioActual : null));

                return new PagedResult<bool>
                {
                    Success = true,
                    Message = spResult.Mensaje,
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar Requisicion: {ex.Message}",
                    Code = "ERROR",
                    Data = false,
                    TotalCount = 0
                };
            }
        }

        private Task<StoredProcedureResult> ExecuteMantenimientoAsync(
            int action,
            int? id,
            RequisicionResponse response,
            int usuarioActual)
        {
            return StoredProcedureExecutor.ExecuteResultAsync(
                _context,
                "[ORCO].[SP_MantenimientoRequisicion]",
                StoredProcedureExecutor.Param("@Action", action),
                StoredProcedureExecutor.Param("@PKIdRequisicion", id),
                StoredProcedureExecutor.Param("@FKIdEmpresa_SIS", response.FkidEmpresaSis),
                StoredProcedureExecutor.Param("@FKIdPersona_NOM", response.FkidPersonaNom),
                StoredProcedureExecutor.Param("@FKIdArea_SIS", response.FkidAreaSis),
                StoredProcedureExecutor.Param("@Descripcion", response.Descripcion),
                StoredProcedureExecutor.Param("@Observaciones", response.Observaciones),
                StoredProcedureExecutor.Param("@FechaRequisicion", response.FechaRequisicion),
                StoredProcedureExecutor.Param("@Servicio", response.Servicio),
                StoredProcedureExecutor.Param("@FL_FOTO", response.FlFoto),
                StoredProcedureExecutor.Param("@FKIdProyecto_ORCO", response.FkidProyectoOrco),
                StoredProcedureExecutor.Param("@FechaRequiereInicio", response.FechaRequiereInicio),
                StoredProcedureExecutor.Param("@FechaRequiereFin", response.FechaRequiereFin),
                StoredProcedureExecutor.Param("@FKIdPrograma_PRES", response.FkidProgramaPres),
                StoredProcedureExecutor.Param("@Importe", response.Importe),
                StoredProcedureExecutor.Param("@FKIdJefeAlmacen_NOM", response.FkidJefeAlmacenNom),
                StoredProcedureExecutor.Param("@FKIdSuficiencia_PRES", response.FkidSuficienciaPres),
                StoredProcedureExecutor.Param("@FKIdSuperviso_NOM", response.FkidSupervisoNom),
                StoredProcedureExecutor.Param("@FKIdAutorizo_NOM", response.FkidAutorizoNom),
                StoredProcedureExecutor.Param("@FKIdPSolicita_NOM", response.FkidPsolicitaNom),
                StoredProcedureExecutor.Param("@FKIdPJefeAlmacen_NOM", response.FkidPjefeAlmacenNom),
                StoredProcedureExecutor.Param("@FKIdPSuficiencia_NOM", response.FkidPsuficienciaNom),
                StoredProcedureExecutor.Param("@FKIdPSuperviso_NOM", response.FkidPsupervisoNom),
                StoredProcedureExecutor.Param("@FKIdPAutorizo_NOM", response.FkidPautorizoNom),
                StoredProcedureExecutor.Param("@FKIdFuenteFinanciamiento_PRES", response.FkidFuenteFinanciamientoPres),
                StoredProcedureExecutor.Param("@FKIdAnio_SIS", response.FkidAnioSis),
                StoredProcedureExecutor.Param("@FKIdTipoGasto_PRES", response.FkidTipoGastoPres),
                StoredProcedureExecutor.Param("@FKIdDigitoIdentificador_PRES", response.FkidDigitoIdentificadorPres),
                StoredProcedureExecutor.Param("@FKIdDestinoGasto_PRES", response.FkidDestinoGastoPres),
                StoredProcedureExecutor.Param("@FKIdEgresoAutorizado_PRES", response.FkidEgresoAutorizadoPres),
                StoredProcedureExecutor.Param("@Oficio", response.Oficio),
                StoredProcedureExecutor.Param("@FechaOficio", response.FechaOficio),
                StoredProcedureExecutor.Param("@CompraDirecta", response.CompraDirecta),
                StoredProcedureExecutor.Param("@IdUser", usuarioActual));
        }

        private bool IsLocked(int requisicionId) => CountActiveCotizaciones(requisicionId) > 0;

        private async Task ValidateClasificacionAsync(RequisicionResponse response)
        {
            if (!response.FkidAnioSis.HasValue || response.FkidAnioSis.Value <= 0)
                throw new ArgumentException("El anio presupuestal es requerido.");
            if (!response.FkidProgramaPres.HasValue ||
                !await _context.Programas.AsNoTracking().AnyAsync(x => x.PkidPrograma == response.FkidProgramaPres.Value && x.Activo))
                throw new ArgumentException("El programa presupuestario es requerido y debe estar activo.");
            if (!response.FkidFuenteFinanciamientoPres.HasValue ||
                !await _context.FuenteFinanciamientos.AsNoTracking().AnyAsync(x => x.PkidFuenteFinanciamiento == response.FkidFuenteFinanciamientoPres.Value && x.Activo))
                throw new ArgumentException("La fuente de financiamiento es requerida y debe estar activa.");
            if (!response.FkidTipoGastoPres.HasValue ||
                !await _context.TipoGastos.AsNoTracking().AnyAsync(x => x.PkidTipoGasto == response.FkidTipoGastoPres.Value && x.Activo))
                throw new ArgumentException("El tipo de gasto es requerido y debe estar activo.");
            if (!response.FkidDigitoIdentificadorPres.HasValue ||
                !await _context.DigitoIdentificadors.AsNoTracking().AnyAsync(x => x.PkidDigitoIdentificador == response.FkidDigitoIdentificadorPres.Value && x.Activo))
                throw new ArgumentException("El digito identificador es requerido y debe estar activo.");
            if (!response.FkidDestinoGastoPres.HasValue ||
                !await _context.DestinoGastos.AsNoTracking().AnyAsync(x => x.PkidDestinoGasto == response.FkidDestinoGastoPres.Value && x.Activo))
                throw new ArgumentException("El destino del gasto es requerido y debe estar activo.");
            if (!response.Importe.HasValue || response.Importe.Value <= 0)
                throw new ArgumentException("El importe de la requisicion debe ser mayor a cero.");
        }

        private int CountActiveCotizaciones(int requisicionId)
        {
            return _cotizacionService.GetQueryWithIncludes()
                .Count(x => x.FkidRequisicionOrco == requisicionId);
        }

        private void ApplyCotizacionLocks(IList<RequisicionResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var requisicionIds = items.Select(x => x.PkidRequisicion).Distinct().ToList();
            var counts = _cotizacionService.GetQueryWithIncludes()
                .Where(x => requisicionIds.Contains(x.FkidRequisicionOrco))
                .GroupBy(x => x.FkidRequisicionOrco)
                .ToDictionary(x => x.Key, x => x.Count());

            foreach (var item in items)
            {
                item.CotizacionesActivas = counts.TryGetValue(item.PkidRequisicion, out var count) ? count : 0;
            }
        }

        private static PagedResult<RequisicionResponse> LockedResult(string message)
        {
            return new PagedResult<RequisicionResponse>
            {
                Success = false,
                Message = message,
                Code = "LOCKED",
                TotalCount = 0
            };
        }

        private static PagedResult<RequisicionResponse> ValidationResult(string message)
        {
            return new PagedResult<RequisicionResponse>
            {
                Success = false,
                Message = message,
                Code = "VALIDATION",
                TotalCount = 0
            };
        }

        private static PagedResult<RequisicionResponse> InvalidProyectoResult(int? proyectoId)
        {
            return new PagedResult<RequisicionResponse>
            {
                Success = false,
                Message = proyectoId.HasValue
                    ? $"El proyecto seleccionado ({proyectoId.Value}) no existe en ORCO.Proyecto o no esta activo."
                    : "El proyecto seleccionado no es valido.",
                Code = "INVALID_ORCO_PROJECT",
                TotalCount = 0
            };
        }
    }
}
