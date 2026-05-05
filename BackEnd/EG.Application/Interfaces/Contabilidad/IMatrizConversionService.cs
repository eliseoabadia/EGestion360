using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad
{
    public interface IMatrizConversionService
    {
        Task<IEnumerable<MatrizConversionResponse>> GetAllAsync();
        Task<MatrizConversionResponse?> GetByIdAsync(int id);
        Task<MatrizConversionResponse> AddAsync(MatrizConversionDto dto, int usuarioId);
        Task UpdateAsync(int id, MatrizConversionDto dto, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<MatrizConversionResponse>> GetAllPaginadoAsync(PagedRequest request, Dictionary<string, object>? additionalFilters = null);
        Task<bool> CanAddAsync(MatrizConversionDto dto);
        Task<bool> CanUpdateAsync(int id, MatrizConversionDto dto);
        Task<bool> ExisteRegistroAsync(int anioSis, int programaPres, int partidaSis);
    }
}
