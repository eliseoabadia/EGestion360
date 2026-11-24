using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Common.Enums;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.Interfaces;

namespace EG.Application.Services.Patrimonio;

public sealed class ResguardoMovimientoAppService(IResguardoMovimientoQueries queries, IUserContextService userContext)
    : IResguardoMovimientoAppService
{
    public async Task<PagedResult<ResguardoMovimientoResponse>> GetAllAsync()
    {
        var page = await queries.GetAllAsync(userContext.GetCurrentEmpresaId(), userContext.GetCurrentAnioPresupuestalId());
        return Success(page);
    }

    public async Task<PagedResult<ResguardoMovimientoResponse>> GetByIdAsync(int id)
    {
        var item = await queries.GetByIdAsync(id, userContext.GetCurrentEmpresaId(), userContext.GetCurrentAnioPresupuestalId());
        if (item == null)
        {
            return new() { Success = false, Message = "Movimiento de resguardo no encontrado.", Code = ApiResponseCode.NotFound.ToCode() };
        }
        var result = Success(new ResguardoMovimientoPage([item], 1));
        result.Data = item;
        return result;
    }

    public async Task<PagedResult<ResguardoMovimientoResponse>> GetAllPaginadoAsync(PagedRequest request)
    {
        var filter = new ResguardoMovimientoFilter(request.Page, request.PageSize,
            request.SearchString ?? request.Filtro, request.SortLabel, request.SortDirection);
        var page = await queries.GetAllPaginadoAsync(filter, userContext.GetCurrentEmpresaId(), userContext.GetCurrentAnioPresupuestalId());
        return Success(page);
    }

    private static PagedResult<ResguardoMovimientoResponse> Success(ResguardoMovimientoPage page) => new()
    {
        Success = true,
        Message = "Movimientos de resguardo obtenidos correctamente.",
        Code = ApiResponseCode.Success.ToCode(),
        Items = page.Items,
        TotalCount = page.TotalCount
    };
}
