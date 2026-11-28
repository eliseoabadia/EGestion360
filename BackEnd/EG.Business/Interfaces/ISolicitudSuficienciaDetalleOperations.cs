using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Business.Interfaces;

public interface ISolicitudSuficienciaDetalleOperations
{
    Task<PagedResult<SolicitudSuficienciaDetalleResponse>> GetAllAsync();
    Task<PagedResult<SolicitudSuficienciaDetalleResponse>> GetByIdAsync(int id);
    Task<PagedResult<SolicitudSuficienciaDetalleResponse>> CreateAsync(SolicitudSuficienciaDetalleResponse response, int usuarioActual);
    Task<PagedResult<SolicitudSuficienciaDetalleResponse>> UpdateAsync(int id, SolicitudSuficienciaDetalleResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<SolicitudSuficienciaDetalleResponse>> GetAllPaginadoAsync(PagedRequest request);
}
