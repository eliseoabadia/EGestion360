using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Almacen;

public interface IFamiliaService
{
    // ==================== CONSULTAS ====================
    Task<PagedResult<FamiliaResponse>> GetAllAsync();
    Task<FamiliaResponse> GetByIdAsync(int id);
    Task<PagedResult<FamiliaResponse>> GetAllPaginadoAsync(PagedRequest pageRequest);

    // ==================== ESCRITURA ====================
    Task<FamiliaResponse> CreateAsync(FamiliaDto dto, int usuarioActual);
    Task<FamiliaResponse> UpdateAsync(int id, FamiliaDto dto, int usuarioActual);
    Task<bool> DeleteAsync(int id, int usuarioActual);
}
