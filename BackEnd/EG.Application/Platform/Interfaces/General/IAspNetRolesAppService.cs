using EG.Domain.DTOs.Responses.General;

namespace EG.Application.Interfaces.General
{
    public interface IAspNetRolesAppService
    {
        Task<IEnumerable<AspNetRoleResponse>> GetAllAsync();
        Task<AspNetRoleResponse> GetByIdAsync(string id);
        Task<AspNetRoleResponse> CreateAsync(AspNetRoleResponse dto, int usuarioActual);
        Task<AspNetRoleResponse> UpdateAsync(string id, AspNetRoleResponse dto, int usuarioActual);
        Task DeleteAsync(string id);
    }
}