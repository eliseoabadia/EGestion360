using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Nomina;

namespace EG.Application.Interfaces.Nomina;

public interface INominaRhDetailAppService<TDto, TResponse>
    where TDto : class
    where TResponse : class
{
    Task<PagedResult<TResponse>> GetAllAsync(int? empresaId);

    Task<PagedResult<TResponse>> GetByIdAsync(int id, int? empresaId);

    Task<PagedResult<TResponse>> CreateAsync(TDto dto, int usuarioActual, int? empresaId);

    Task<PagedResult<TResponse>> UpdateAsync(int id, TDto dto, int usuarioActual, int? empresaId);

    Task<PagedResult<bool>> DeleteAsync(int id, int usuarioActual, int? empresaId);

    Task<PagedResult<TResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId);
}

public interface INominaRhLookupAppService
{
    Task<PagedResult<NominaRhLookupResponse>> GetAllPaginadoAsync(PagedRequest request, int? empresaId);
}
