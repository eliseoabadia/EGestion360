using EG.Application.Interfaces.Configuracion.Catalogo.Almacen;
using EG.Application.Modules.GRP.Services.Configuracion.Catalogo;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Almacen
{
    public class UnidadesService(GenericService<Unidade, UnidadeDto, UnidadeResponse> service)
        : GenericCatalogService<Unidade, UnidadeDto, UnidadeResponse>(service), IUnidadesService
    {
        public Task<List<LookupItem>> GetLookupAsync()
            => GetLookupAsync(item => item.PkidUnidades, item => item.Descripcion);

        public Task<PagedResult<LookupItem>> GetLookupPaginadoAsync(int page, int pageSize, string? filter)
            => GetLookupPaginadoAsync(page, pageSize, filter, item => item.PkidUnidades, item => item.Descripcion);
    }
}
