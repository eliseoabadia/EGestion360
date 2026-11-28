using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IRequisicionOperations
{
    Task<PagedResult<EG.Domain.DTOs.Responses.General.UsuarioAreaResponse>> GetRequestersAsync();
    Task<PagedResult<RequisicionResponse>> GetAllAsync();
    Task<PagedResult<RequisicionResponse>> GetByIdAsync(int id);
    Task<PagedResult<RequisicionResponse>> CreateAsync(RequisicionResponse response, int usuarioActual);
    Task<PagedResult<RequisicionResponse>> UpdateAsync(int id, RequisicionResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<RequisicionResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<EG.Common.GenericModel.PagedResult<bool>> DeleteAsync(int id, int usuarioActual);
}
