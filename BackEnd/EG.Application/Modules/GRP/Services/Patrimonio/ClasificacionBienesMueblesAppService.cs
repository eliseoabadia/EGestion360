using EG.Application.Interfaces.Patrimonio;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.Patrimonio
{
    public class ClasificacionBienesMueblesAppService
        : IClasificacionBienesMueblesAppService
    {
        private readonly GenericService<VwOrdenCompraFromClasificacionBien, ClasificacionBienesMueblesDto, ClasificacionBienesMueblesResponse> _serviceView;
        private readonly EGestionContext _context;

        public ClasificacionBienesMueblesAppService(
            GenericService<VwOrdenCompraFromClasificacionBien, ClasificacionBienesMueblesDto, ClasificacionBienesMueblesResponse> serviceView,
            EGestionContext context)
        {
            _serviceView = serviceView;
            _context = context;
        }

        public async Task<PagedResult<ClasificacionBienesMueblesResponse>> GetAllAsync()
        {
            return await GetAllPaginadoAsync(new PagedRequest
            {
                Page = 1,
                PageSize = 500,
                SortLabel = nameof(VwOrdenCompraFromClasificacionBien.PkidOrdenCompra),
                SortDirection = "Descending"
            });
        }

        public async Task<PagedResult<ClasificacionBienesMueblesResponse>> GetByIdAsync(int id)
        {
            var item = await _serviceView.GetByIdAsync(
                id,
                idPropertyName: nameof(VwOrdenCompraFromClasificacionBien.PkidOrdenCompra));

            if (item == null)
            {
                return Failure<ClasificacionBienesMueblesResponse>("Orden de compra no encontrada.", "NOT_FOUND");
            }

            await EnrichAsync(new List<ClasificacionBienesMueblesResponse> { item });

            return new PagedResult<ClasificacionBienesMueblesResponse>
            {
                Success = true,
                Message = "Orden de compra encontrada.",
                Code = "SUCCESS",
                Data = item,
                Items = new List<ClasificacionBienesMueblesResponse> { item },
                TotalCount = 1
            };
        }

        public Task<PagedResult<ClasificacionBienesMueblesResponse>> CreateAsync(
            ClasificacionBienesMueblesResponse response,
            int usuarioActual)
            => Task.FromResult(Failure<ClasificacionBienesMueblesResponse>(
                "La clasificacion de bienes muebles se genera desde ordenes de compra autorizadas.",
                "READ_ONLY"));

        public Task<PagedResult<ClasificacionBienesMueblesResponse>> UpdateAsync(
            int id,
            ClasificacionBienesMueblesResponse response,
            int usuarioActual)
            => Task.FromResult(Failure<ClasificacionBienesMueblesResponse>(
                "La clasificacion de bienes muebles no permite edicion directa.",
                "READ_ONLY"));

        public Task<PagedResult<bool>> DeleteAsync(int id)
            => Task.FromResult(Failure<bool>(
                "La clasificacion de bienes muebles no permite eliminacion directa.",
                "READ_ONLY"));

        public async Task<PagedResult<ClasificacionBienesMueblesResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            request ??= new PagedRequest();
            request.SortLabel = string.IsNullOrWhiteSpace(request.SortLabel)
                ? nameof(VwOrdenCompraFromClasificacionBien.PkidOrdenCompra)
                : request.SortLabel;

            var result = await _serviceView.GetAllPaginadoAsync(request);
            if (result.Success)
            {
                await EnrichAsync(result.Items);
                result.Message = "Ordenes de compra para clasificacion obtenidas correctamente.";
            }

            return result;
        }

        private async Task EnrichAsync(IList<ClasificacionBienesMueblesResponse>? items)
        {
            if (items == null || items.Count == 0)
            {
                return;
            }

            var ordenIds = items.Select(x => x.PkidOrdenCompra).Distinct().ToList();
            var detalles = await _context.OrdenCompraDetalles
                .AsNoTracking()
                .Where(x => ordenIds.Contains(x.FkidOrdenCompraOrco) && x.Activo)
                .Select(x => new { x.PkidOrdenCompraDetalle, x.FkidOrdenCompraOrco })
                .ToListAsync();

            var detalleIds = detalles.Select(x => x.PkidOrdenCompraDetalle).Distinct().ToList();
            var bienes = await _context.Biens
                .AsNoTracking()
                .Where(x => x.FkidDetalleOrdenCompraOrco.HasValue
                            && detalleIds.Contains(x.FkidDetalleOrdenCompraOrco.Value)
                            && x.Activo)
                .GroupBy(x => x.FkidDetalleOrdenCompraOrco!.Value)
                .Select(x => new { DetalleId = x.Key, Count = x.Count() })
                .ToDictionaryAsync(x => x.DetalleId, x => x.Count);

            var detallesByOrden = detalles
                .GroupBy(x => x.FkidOrdenCompraOrco)
                .ToDictionary(x => x.Key, x => x.ToList());

            foreach (var item in items)
            {
                if (detallesByOrden.TryGetValue(item.PkidOrdenCompra, out var detalleOrden))
                {
                    item.TotalDetalles = detalleOrden.Count;
                    item.TotalBienes = detalleOrden.Sum(x => bienes.TryGetValue(x.PkidOrdenCompraDetalle, out var count) ? count : 0);
                }

                var solicitado = item.Solicitado ?? 0m;
                var recibido = item.Recibido ?? 0m;
                item.PorcentajeRecibido = solicitado <= 0m ? 0m : Math.Round(Math.Min(100m, recibido / solicitado * 100m), 2);
            }
        }

        private static PagedResult<T> Failure<T>(string message, string code)
        {
            return new PagedResult<T>
            {
                Success = false,
                Message = message,
                Code = code,
                Items = new List<T>(),
                TotalCount = 0
            };
        }
    }
}
