using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Business.Interfaces;

public interface IAlmacenOperations
{
    Task<PagedResult<AlmacenResponse>> GetAllAsync();
    Task<PagedResult<AlmacenResponse>> GetByIdAsync(int id);
    Task<PagedResult<AlmacenResponse>> CreateAsync(AlmacenResponse response, int usuarioActual);
    Task<PagedResult<AlmacenResponse>> UpdateAsync(int id, AlmacenResponse response, int usuarioActual);
    Task<PagedResult<bool>> DeleteAsync(int id);
    Task<PagedResult<AlmacenResponse>> GetAllPaginadoAsync(PagedRequest request);
    Task<PagedResult<AlmacenResponse>> CreateSalidaAjusteAsync(int origenId, AlmacenResponse response, int usuarioActual);
}
