using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Patrimonio;

namespace EG.Business.Interfaces;

public interface IClasificacionBienesMueblesOperations
{
    Task<PagedResult<ClasificacionBienesMueblesResponse>> GetAllAsync();
    Task<PagedResult<ClasificacionBienesMueblesResponse>> GetByIdAsync(int id);
    Task<PagedResult<ClasificacionBienesMueblesResponse>> CreateAsync(ClasificacionBienesMueblesResponse response, int usuarioActual);
    Task<PagedResult<ClasificacionBienesMueblesResponse>> UpdateAsync(int id, ClasificacionBienesMueblesResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<ClasificacionBienesMueblesResponse>> GetAllPaginadoAsync(PagedRequest request);
}
