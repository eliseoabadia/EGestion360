using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Tesoreria;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria
{
    public interface IProvisionPagoImporteAppService
    {
        Task<PagedResult<VwClcfacturaImporteResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
