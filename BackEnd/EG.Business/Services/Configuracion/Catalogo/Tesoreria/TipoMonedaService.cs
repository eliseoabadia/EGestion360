using EG.Business.Services.Adquisicion;
using EG.Business.Services.PresupuestoModificado;
using Microsoft.EntityFrameworkCore;
using EG.Business.Services.Configuracion.Catalogo;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Services.Configuracion.Catalogo.Tesoreria
{
    public class TipoMonedaServiceOperations : GenericCatalogService<TipoMonedum, TipoMonedaDto, TipoMonedaResponse>, global::EG.Business.Interfaces.Operations.ITipoMonedaService
    {
        public TipoMonedaServiceOperations(GenericService<TipoMonedum, TipoMonedaDto, TipoMonedaResponse> service) : base(service)
        {
            service.AddInclude(entity => entity.FkidPaisSisNavigation);
            service.AddRelationFilter(nameof(TipoMonedum.FkidPaisSisNavigation), [nameof(Paise.Nombre)]);
        }

        public override async Task<PagedResult<TipoMonedaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            await EnsurePesoMexicanoAsync();
            request.SortLabel = request.SortLabel == "PaisNombre" ? nameof(Paise.Nombre) : request.SortLabel;
            return await base.GetAllPaginadoAsync(request);
        }

        private async Task EnsurePesoMexicanoAsync()
        {
            var moneda = await Service.GetQueryWithIncludes(x => x.CodigoIso4217 == "MXN").FirstOrDefaultAsync();
            if (moneda != null)
            {
                return;
            }

            await Service.AddAsync(new TipoMonedaDto { FkidPaisSis = 1, Descripcion = "Peso Mexicano", CodigoIso4217 = "MXN", Simbolo = "$", Decimales = 2, Activo = true });
        }
    }
}