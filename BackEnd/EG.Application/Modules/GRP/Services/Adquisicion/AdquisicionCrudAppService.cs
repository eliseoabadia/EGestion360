using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;

namespace EG.Application.Services.Adquisicion;

public abstract class AdquisicionCrudAppService<TEntity, TView, TDto, TResponse>(
    GenericService<TEntity, TDto, TResponse> service,
    GenericService<TView, TDto, TResponse> serviceView,
    string idPropertyName, string entityName, Action<TDto, int> setId)
    : AdquisicionCrudOperationsService<TEntity, TView, TDto, TResponse>(service, serviceView, idPropertyName, entityName, setId),
      IAdquisicionCrudAppService<TResponse>
    where TEntity : class
    where TView : class
    where TDto : class
    where TResponse : class;
