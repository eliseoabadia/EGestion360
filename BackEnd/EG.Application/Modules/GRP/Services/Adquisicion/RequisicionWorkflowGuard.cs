using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Adquisicion
{
    internal static class RequisicionWorkflowGuard
    {
        public static int GetCurrentEmpresaId(IUserContextService userContext)
        {
            var empresaId = userContext.TryGetCurrentEmpresaId();
            if (!empresaId.HasValue || empresaId.Value <= 0)
                throw new InvalidOperationException("No existe una empresa activa en la sesión.");

            return empresaId.Value;
        }

        public static Task<Requisicion?> GetOwnedRequisicionAsync(
            EGestionContext context,
            IUserContextService userContext,
            int requisicionId,
            bool tracking = false)
        {
            var empresaId = GetCurrentEmpresaId(userContext);
            var query = tracking
                ? context.Requisicions.AsQueryable()
                : context.Requisicions.AsNoTracking();

            return query.FirstOrDefaultAsync(x =>
                x.PkidRequisicion == requisicionId &&
                x.FkidEmpresaSis == empresaId &&
                x.Activo);
        }

        public static async Task<bool> IsLockedAsync(EGestionContext context, int requisicionId)
        {
            if (await context.Cotizacions
                .AsNoTracking()
                .AnyAsync(x => x.FkidRequisicionOrco == requisicionId && x.Activo))
                return true;

            return await context.SolicitudSuficiencia
                .AsNoTracking()
                .AnyAsync(x => x.FkidRequisicionOrco == requisicionId && x.Activo);
        }
    }
}
