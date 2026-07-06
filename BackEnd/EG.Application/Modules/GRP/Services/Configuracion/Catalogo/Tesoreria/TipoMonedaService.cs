using Microsoft.EntityFrameworkCore;
using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Application.Modules.GRP.Services.Configuracion.Catalogo;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria
{
    public class TipoMonedaService : GenericCatalogService<TipoMonedum, TipoMonedaDto, TipoMonedaResponse>, ITipoMonedaService
    {
        public TipoMonedaService(GenericService<TipoMonedum, TipoMonedaDto, TipoMonedaResponse> service)
            : base(service)
        {
            service.AddInclude(entity => entity.FkidPaisSisNavigation);
            service.AddRelationFilter(nameof(TipoMonedum.FkidPaisSisNavigation), [nameof(Paise.Nombre)]);
        }

        public override async Task<PagedResult<TipoMonedaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            await EnsurePesoMexicanoAsync();
            request.SortLabel = request.SortLabel == "PaisNombre"
                ? nameof(Paise.Nombre)
                : request.SortLabel;

            return await base.GetAllPaginadoAsync(request);
        }

        private async Task EnsurePesoMexicanoAsync()
        {
            var moneda = await Service.GetQueryWithIncludes(x => x.CodigoIso4217 == "MXN")
                .FirstOrDefaultAsync();

            if (moneda != null)
            {
                return;
            }

            await Service.AddAsync(new TipoMonedaDto
            {
                FkidPaisSis = 1,
                Descripcion = "Peso Mexicano",
                CodigoIso4217 = "MXN",
                Simbolo = "$",
                Decimales = 2,
                Activo = true
            });
        }
    }
}
