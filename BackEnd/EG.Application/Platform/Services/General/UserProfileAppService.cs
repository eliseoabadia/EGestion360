using EG.Application.Interfaces.General;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;

namespace EG.Application.Services.General
{
    public class UserProfileAppService : IUserProfileAppService
    {
        private readonly IUserProfileService _service;
        private readonly IEmployeeService _serviceEmp;

        public UserProfileAppService(IUserProfileService service, IEmployeeService serviceEmp)
        {
            _service = service;
            _serviceEmp = serviceEmp;
        }

        public async Task<PerfilUsuarioResponse> GetProfileImageAsync(int id)
        {
            var profile = await _service.GetUsuarioByIdAsync(id);
            if (profile == null) return null;

            return new PerfilUsuarioResponse
            {
                FkidUsuarioSis = profile.FkidUsuarioSis,
                Fotografia = profile.Fotografia
            };
        }

        public async Task<bool> CreateProfileAsync(UsuarioDto user)
        {
            return await _serviceEmp.AddEmployeeAsync(user);
        }

        public async Task<bool> SetProfileAsync(int id, UsuarioDto user)
        {
            return await _serviceEmp.UpdateEmployeeAsync(id, user);
        }

        public async Task<bool> DeleteProfileAsync(int id)
        {
            return await _serviceEmp.DeleteEmployeeAsync(id);
        }

        public async Task<UsuarioResponse> GetProfileUserAsync(int id)
        {
            return await _serviceEmp.GetEmployeeByIdAsync(id);
        }

        public async Task<IList<UsuarioResponse>> GetAllUsersAsync()
        {
            return await _serviceEmp.GetAllUsersAsync();
        }

        public async Task<PagedResult<UsuarioResponse>> GetAllUsersPaginadoAsync(PagedRequest _params)
        {
            return await _serviceEmp.GetAllUsuariosPaginadoAsync(_params);
        }

        public async Task UploadImageAsync(PerfilUsuarioResponse fotografia)
        {
            await _service.UpdateUserUsuarioAsync(fotografia.FkidUsuarioSis, fotografia);
        }
    }
}
