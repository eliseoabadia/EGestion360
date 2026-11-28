namespace EG.Business.Interfaces.Operations;
public interface IDepositoOperations

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> AutorizarAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoPolizaResponse>> GetPolizaAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetIngresoAutorizadoLookupPaginadoAsync(global::System.Int32 page, global::System.Int32 pageSize, global::System.String? filter, global::System.Int32? idAnio);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetCLCFacturaLookupPaginadoAsync(global::System.Int32 page, global::System.Int32 pageSize, global::System.String? filter);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetTipoDoctoPagoLookupPaginadoAsync(global::System.Int32 page, global::System.Int32 pageSize, global::System.String? filter);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Common.GenericModel.LookupItem>> GetCuentaContableLookupPaginadoAsync(global::System.Int32 page, global::System.Int32 pageSize, global::System.String? filter);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> GetAllAsync();
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> GetByIdAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> CreateAsync(global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> UpdateAsync(global::System.Int32 id, global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse response, global::System.Int32 usuarioActual);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::System.Boolean>> DeleteAsync(global::System.Int32 id);
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.CuentasXPagar.DepositoResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request);
}
