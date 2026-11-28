namespace EG.Business.Interfaces.Operations;
public interface IBienDisponibleBajaOperations

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.BienDisponibleBajaResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.BienDisponibleBajaResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.BienDisponibleBajaResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.Patrimonio.BienDisponibleBajaResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.BienDisponibleBajaResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.Patrimonio.BienDisponibleBajaResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Patrimonio.BienDisponibleBajaResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
