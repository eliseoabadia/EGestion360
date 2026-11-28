namespace EG.Business.Interfaces.Operations;
public interface IChequeOperations

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> RegresarASolicitudSuficienciaAsync(global::System.Int32 id, global::System.String motivo);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.ChequeResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
