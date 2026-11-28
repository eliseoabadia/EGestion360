using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface ISolicitudSuficienciaOperations
{
    Task<PagedResult<SolicitudSuficienciaResponse>> GetAllAsync();
    Task<PagedResult<SolicitudSuficienciaResponse>> GetByIdAsync(int id);
    Task<PagedResult<SolicitudSuficienciaResponse>> CreateAsync(SolicitudSuficienciaResponse response, int usuarioActual);
    Task<PagedResult<SolicitudSuficienciaResponse>> UpdateAsync(int id, SolicitudSuficienciaResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<SolicitudSuficienciaResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<SolicitudSuficienciaResponse>> GenerarDesdeRequisicionAsync(
            SolicitudSuficienciaGenerarRequest request,
            int usuarioActual);
}
