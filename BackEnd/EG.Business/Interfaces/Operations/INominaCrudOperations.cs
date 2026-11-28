namespace EG.Business.Interfaces.Operations;
public interface INominaCrudOperations<TResponse>
 where TResponse : class
{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> CreateAsync(TResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> UpdateAsync(global::System.Int32 id, TResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
