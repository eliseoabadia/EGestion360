namespace EG.Business.Interfaces.Operations;
public interface INominaRhLookupOperations

{
    global::System.Threading.Tasks.Task<global::EG.Common.GenericModel.PagedResult<global::EG.Domain.DTOs.Responses.Nomina.NominaRhLookupResponse>> GetAllPaginadoAsync(global::EG.Common.GenericModel.PagedRequest request, global::System.Int32? empresaId);
}
