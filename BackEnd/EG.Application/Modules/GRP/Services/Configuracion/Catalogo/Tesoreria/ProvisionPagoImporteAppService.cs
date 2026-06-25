using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria
{
    public class ProvisionPagoImporteAppService(
        GenericService<VwClcfacturaImporte, VwClcfacturaImporteResponse, VwClcfacturaImporteResponse> service)
        : IProvisionPagoImporteAppService
    {
        public async Task<PagedResult<VwClcfacturaImporteResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await service.GetAllPaginadoAsync(request);

            return new PagedResult<VwClcfacturaImporteResponse>
            {
                Success = result.Success,
                Message = result.Success
                    ? "Provision del pago obtenida correctamente"
                    : result.Message,
                Code = result.Success ? "SUCCESS" : "ERROR",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
