using EG.Business.Services.Adquisicion;
using EG.Business.Services.PresupuestoModificado;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.PBR;
using EG.Domain.DTOs.Responses.PBR;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services.PBR
{
    public class PbrAnteproyectoOperationsService : AdquisicionCrudOperationsService<Anteproyecto, VwAnteproyecto, PbrAnteproyectoDto, PbrAnteproyectoResponse>
    {
        private readonly EGestionContext _context;
        public PbrAnteproyectoOperationsService(GenericService<Anteproyecto, PbrAnteproyectoDto, PbrAnteproyectoResponse> service, GenericService<VwAnteproyecto, PbrAnteproyectoDto, PbrAnteproyectoResponse> serviceView, EGestionContext context) : base(service, serviceView, "PkidAnteproyecto", "Anteproyecto PBR", (dto, id) => dto.PkidAnteproyecto = id)
        {
            _context = context;
        }

        public override Task<PagedResult<PbrAnteproyectoResponse>> CreateAsync(PbrAnteproyectoResponse response, int usuarioActual)
        {
            response.Estatus = string.IsNullOrWhiteSpace(response.Estatus) ? "BORRADOR" : response.Estatus.Trim().ToUpperInvariant();
            response.FkidUsuarioPbr = response.FkidUsuarioPbr <= 0 ? usuarioActual : response.FkidUsuarioPbr;
            response.MontoAutorizado = IsAuthorized(response.Estatus) && response.MontoAutorizado is null ? response.MontoSolicitado : response.MontoAutorizado;
            return base.CreateAsync(response, usuarioActual);
        }

        public override async Task<PagedResult<PbrAnteproyectoResponse>> UpdateAsync(int id, PbrAnteproyectoResponse response, int usuarioActual)
        {
            var existing = await _context.Anteproyectos.AsNoTracking().FirstOrDefaultAsync(x => x.PkidAnteproyecto == id);
            if (existing == null)
            {
                return new PagedResult<PbrAnteproyectoResponse>
                {
                    Success = false,
                    Message = $"Anteproyecto PBR no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }

            if (IsAuthorized(existing.Estatus))
            {
                return Locked();
            }

            response.Estatus = string.IsNullOrWhiteSpace(response.Estatus) ? existing.Estatus : response.Estatus.Trim().ToUpperInvariant();
            response.MontoAutorizado = IsAuthorized(response.Estatus) && response.MontoAutorizado is null ? response.MontoSolicitado : response.MontoAutorizado;
            return await base.UpdateAsync(id, response, usuarioActual);
        }

        public override async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            var existing = await _context.Anteproyectos.AsNoTracking().FirstOrDefaultAsync(x => x.PkidAnteproyecto == id);
            if (existing != null && IsAuthorized(existing.Estatus))
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = "El anteproyecto autorizado no se puede eliminar.",
                    Code = "LOCKED",
                    Data = false,
                    TotalCount = 0
                };
            }

            return await base.DeleteAsync(id);
        }

        private static bool IsAuthorized(string? estatus) => string.Equals(estatus, "AUTORIZADO", StringComparison.OrdinalIgnoreCase) || string.Equals(estatus, "APROBADO", StringComparison.OrdinalIgnoreCase);
        private static PagedResult<PbrAnteproyectoResponse> Locked() => new()
        {
            Success = false,
            Message = "El anteproyecto autorizado no se puede editar.",
            Code = "LOCKED",
            TotalCount = 0
        };
    }

    public class PbrPresupuestoProgramaOperationsService : AdquisicionCrudOperationsService<PresupuestoPrograma, VwPresupuestoPrograma, PbrPresupuestoProgramaDto, PbrPresupuestoProgramaResponse>
    {
        public PbrPresupuestoProgramaOperationsService(GenericService<PresupuestoPrograma, PbrPresupuestoProgramaDto, PbrPresupuestoProgramaResponse> service, GenericService<VwPresupuestoPrograma, PbrPresupuestoProgramaDto, PbrPresupuestoProgramaResponse> serviceView) : base(service, serviceView, "PkidPresupuestoPrograma", "Presupuesto por programa PBR", (dto, id) => dto.PkidPresupuestoPrograma = id)
        {
        }
    }

    public class PbrPartidaGastoOperationsService : AdquisicionCrudOperationsService<PartidaGasto, VwPartidaGasto, PbrPartidaGastoDto, PbrPartidaGastoResponse>
    {
        public PbrPartidaGastoOperationsService(GenericService<PartidaGasto, PbrPartidaGastoDto, PbrPartidaGastoResponse> service, GenericService<VwPartidaGasto, PbrPartidaGastoDto, PbrPartidaGastoResponse> serviceView) : base(service, serviceView, "PkidPartidaGasto", "Partida de gasto PBR", (dto, id) => dto.PkidPartidaGasto = id)
        {
        }
    }

    public class PbrMirNivelOperationsService : AdquisicionCrudOperationsService<MirNivel, VwMirNivel, PbrMirNivelDto, PbrMirNivelResponse>
    {
        public PbrMirNivelOperationsService(GenericService<MirNivel, PbrMirNivelDto, PbrMirNivelResponse> service, GenericService<VwMirNivel, PbrMirNivelDto, PbrMirNivelResponse> serviceView) : base(service, serviceView, "PkidMirNivel", "Nivel MIR PBR", (dto, id) => dto.PkidMirNivel = id)
        {
        }
    }

    public class PbrIndicadorOperationsService : AdquisicionCrudOperationsService<Indicador, VwIndicador, PbrIndicadorDto, PbrIndicadorResponse>
    {
        public PbrIndicadorOperationsService(GenericService<Indicador, PbrIndicadorDto, PbrIndicadorResponse> service, GenericService<VwIndicador, PbrIndicadorDto, PbrIndicadorResponse> serviceView) : base(service, serviceView, "PkidIndicador", "Indicador PBR", (dto, id) => dto.PkidIndicador = id)
        {
        }
    }
}