using System.Linq.Expressions;
using EG.Infraestructure.Models;

namespace EG.Business.Services.Adquisicion;

public static class OrdenCompraReadScope
{
    public static Expression<Func<VwOrdenCompra, bool>> ForYear(EGestionContext context, int companyId, int yearId)
        => order => order.FkidEmpresaSis == companyId && context.Requisicions.Any(requisition =>
            requisition.PkidRequisicion == order.FkidRequisicionOrco && requisition.Activo &&
            requisition.FkidEmpresaSis == companyId && requisition.FkidAnioSis == yearId);
}
