using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Adquisicion;

namespace EG.Application.Interfaces.Adquisicion
{
    public interface IModalidadAppService
    {
        Task<PagedResult<ModalidadResponse>> GetAllAsync();
        Task<PagedResult<ModalidadResponse>> GetByIdAsync(int id);
        Task<PagedResult<ModalidadResponse>> CreateAsync(ModalidadResponse response, int usuarioActual);
        Task<PagedResult<ModalidadResponse>> UpdateAsync(int id, ModalidadResponse response, int usuarioActual);
        Task<PagedResult<bool>> DeleteAsync(int id);
        Task<PagedResult<ModalidadResponse>> GetAllPaginadoAsync(PagedRequest request);
    }
}
