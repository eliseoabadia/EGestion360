using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface IRequisicionPartidaOperations
{
    Task<PagedResult<RequisicionPartidaResponse>> GetAllAsync();
    Task<PagedResult<RequisicionPartidaResponse>> GetByIdAsync(int id);
    Task<PagedResult<RequisicionPartidaResponse>> CreateAsync(RequisicionPartidaResponse response, int usuarioActual);
    Task<PagedResult<RequisicionPartidaResponse>> UpdateAsync(int id, RequisicionPartidaResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<RequisicionPartidaResponse>> GetAllPaginadoAsync(PagedRequest request);
}
