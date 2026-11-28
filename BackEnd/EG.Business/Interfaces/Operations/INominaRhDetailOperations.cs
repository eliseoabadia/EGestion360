namespace EG.Business.Interfaces.Operations;
public interface INominaRhDetailOperations<TDto,TResponse>
 where TDto : class  where TResponse : class
{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetAllAsync(global::System.Int32? empresaId);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetByIdAsync(global::System.Int32 id, global::System.Int32? empresaId);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> CreateAsync(TDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> UpdateAsync(global::System.Int32 id, TDto dto, global::System.Int32 usuarioActual, global::System.Int32? empresaId);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual, global::System.Int32? empresaId);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<TResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request, global::System.Int32? empresaId);
}
