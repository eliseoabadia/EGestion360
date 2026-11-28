using System.Reflection;
using EG.Application.Interfaces.Nomina;
using EG.Business.Services;
using EG.Common;
using EG.Common.Enums;
using EG.Common.Exceptions;
using EG.Common.GenericModel;
using Mapster;
namespace EG.Application.Services.Nomina;
public abstract class NominaCrudAppService<TEntity, TDto, TResponse>(global::EG.Business.Services.Nomina.NominaCrudOperationsService<TEntity,TDto,TResponse> service) : global::EG.Application.Interfaces.Nomina.INominaCrudAppService<TResponse>
where TEntity : class
where TDto : class
where TResponse : class
{
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetAllAsync() => service.GetAllAsync();
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetByIdAsync(global::System.Int32 id) => service.GetByIdAsync(id);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> CreateAsync(TResponse response, global::System.Int32 usuarioActual) => service.CreateAsync(response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> UpdateAsync(global::System.Int32 id, TResponse response, global::System.Int32 usuarioActual) => service.UpdateAsync(id, response, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual) => service.DeleteAsync(id, usuarioActual);
    public global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request) => service.GetAllPaginadoAsync(request);
}
