using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IPaisAppService
    {
        Task<PagedResult<PaiseDto>> GetAllAsync();
        Task<PaiseDto> GetByIdAsync(int id);
        Task<PaiseDto> CreateAsync(PaiseDto dto);
        Task<PaiseDto> UpdateAsync(int id, PaiseDto dto);
        Task<bool> DeleteAsync(int id);
    }
}