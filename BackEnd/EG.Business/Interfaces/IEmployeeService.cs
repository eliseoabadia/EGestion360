using EG.Application.CommonModel;
using EG.Dommain.DTOs.Responses;

namespace EG.Business.Interfaces
{
    public interface IEmployeeService
    {
        Task<IList<UsuarioResponse?>> GetAllUsersAsync();

        Task<PagedResult<UsuarioResponse>> GetAllUsuariosPaginadoAsync(PagedRequest _params);

        Task<UsuarioResponse?> GetEmployeeByIdAsync(int empId);

        Task<bool> AddEmployeeAsync(UsuarioDto dto);

        Task<bool> UpdateEmployeeAsync(int empId, UsuarioDto dto);

        Task<bool> DeleteEmployeeAsync(int empId);
    }
}
