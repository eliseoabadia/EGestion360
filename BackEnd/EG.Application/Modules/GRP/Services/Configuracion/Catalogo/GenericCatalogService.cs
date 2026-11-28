using EG.Business.Services;

namespace EG.Application.Modules.GRP.Services.Configuracion.Catalogo;

public abstract class GenericCatalogService<TEntity, TDto, TResponse>(
    GenericService<TEntity, TDto, TResponse> service)
    : EG.Business.Services.Configuracion.Catalogo.GenericCatalogService<TEntity, TDto, TResponse>(service)
    where TEntity : class
    where TDto : class
    where TResponse : class;
