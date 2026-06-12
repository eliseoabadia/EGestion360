using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Application.Interfaces.Contabilidad
{
    public interface IContaTipoDoctoPagoService
    {
        Task<IEnumerable<ContaTipoDoctoPagoResponse>> GetAllAsync();
        Task<ContaTipoDoctoPagoResponse?> GetByIdAsync(int id);
        Task<ContaTipoDoctoPagoResponse> CreateAsync(ContaTipoDoctoPagoResponse response, int usuarioId);
        Task<ContaTipoDoctoPagoResponse?> UpdateAsync(int id, ContaTipoDoctoPagoResponse response, int usuarioId);
        Task DeleteAsync(int id);
        Task<PagedResult<ContaTipoDoctoPagoResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
