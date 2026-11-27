using System.Linq.Expressions;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Extensions.Logging;

namespace EG.Business.Services.Adquisicion;

public sealed class OrdenCompraReadService(
    IRepository<VwOrdenCompra> repository,
    IUserContextService userContext,
    EGestionContext context,
    ILogger<GenericService<VwOrdenCompra, OrdenCompraDto, OrdenCompraResponse>> logger)
    : GenericService<VwOrdenCompra, OrdenCompraDto, OrdenCompraResponse>(repository, userContext, logger)
{
    public override IQueryable<VwOrdenCompra> GetQueryWithIncludes(Expression<Func<VwOrdenCompra, bool>>? whereCondition = null) =>
        base.GetQueryWithIncludes(whereCondition).Where(OrdenCompraReadScope.ForYear(
            context, _userContext!.GetCurrentEmpresaId(), _userContext.GetCurrentAnioPresupuestalId()));
}
