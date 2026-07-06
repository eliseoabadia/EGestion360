using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Application.Modules.GRP.Services.Configuracion.Catalogo;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria
{
    public class TipoCambioService : GenericCatalogService<TipoCambio, TipoCambioDto, TipoCambioResponse>, ITipoCambioService
    {
        public TipoCambioService(GenericService<TipoCambio, TipoCambioDto, TipoCambioResponse> service)
            : base(service)
        {
            service.AddInclude(entity => entity.FkidTipoMonedaTesNavigation);
            service.AddRelationFilter(
                nameof(TipoCambio.FkidTipoMonedaTesNavigation),
                [nameof(TipoMonedum.Descripcion), nameof(TipoMonedum.CodigoIso4217)]);
        }

        public override Task<PagedResult<TipoCambioResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            request.SortLabel = request.SortLabel switch
            {
                "MonedaDescripcion" => nameof(TipoMonedum.Descripcion),
                "MonedaCodigo" => nameof(TipoMonedum.CodigoIso4217),
                _ => request.SortLabel
            };

            return base.GetAllPaginadoAsync(request);
        }
    }
}
