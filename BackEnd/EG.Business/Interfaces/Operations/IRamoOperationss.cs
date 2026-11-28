namespace EG.Business.Interfaces.Operations;
public interface IRamoOperationss

{
    global::System.Threading.Tasks.Task<global::System.Collections.Generic.IEnumerable<global::EG.Domain.DTOs.Responses.Presupuestales.RamoResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.RamoResponse> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Presupuestales.RamoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest pageRequest, global::System.Func<global::EG.Domain.DTOs.Responses.Presupuestales.RamoResponse,global::System.Boolean>? predicate = default);
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.RamoResponse> CreateAsync(global::EG.Domain.DTOs.Responses.Presupuestales.RamoResponse response, global::System.Int32 usuarioCreacion);
    global::System.Threading.Tasks.Task<global::EG.Domain.DTOs.Responses.Presupuestales.RamoResponse> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Presupuestales.RamoResponse response, global::System.Int32 usuarioModificacion);
    global::System.Threading.Tasks.Task<global::System.Boolean> DeleteAsync(global::System.Int32 id, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::System.Boolean> ExistsAsync(global::System.Int32 id);
}
