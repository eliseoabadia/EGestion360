using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad
{
    public interface ICierreMensualService
    {
        Task<PagedResult<CierreMensualResponse>> GetAllAsync();
        Task<PagedResult<CierreMensualResponse>> GetByIdAsync(int id);
        Task<PagedResult<CierreMensualResponse>> GetAllPaginadoAsync(PagedRequest request);
        Task<PagedResult<CierreMensualResponse>> GetEstadoAsync();
        Task<PagedResult<CierreMensualResponse>> AplicarCierreMensualAsync(int usuarioActual);
    }
}
