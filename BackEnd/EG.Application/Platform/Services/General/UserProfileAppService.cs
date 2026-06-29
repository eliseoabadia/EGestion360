using EG.Application.Interfaces.General;
using EG.Business.Interfaces;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General
{
    public class UserProfileAppService : IUserProfileAppService
    {
        private readonly IUserProfileService _service;
        private readonly IEmployeeService _serviceEmp;
        private readonly EGestionContext _context;

        public UserProfileAppService(IUserProfileService service, IEmployeeService serviceEmp, EGestionContext context)
        {
            _service = service;
            _serviceEmp = serviceEmp;
            _context = context;
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

        public async Task<PagedResult<bool>> ChangePasswordAsync(int id, ChangePasswordDto request, int currentUserId)
        {
            if (id <= 0 || id != currentUserId)
            {
                return Error("No puedes cambiar la contrasena de otro usuario.", ApiResponseCode.Unauthorized);
            }

            if (request == null ||
                string.IsNullOrWhiteSpace(request.CurrentPassword) ||
                string.IsNullOrWhiteSpace(request.NewPassword))
            {
                return Error("Captura la contrasena actual y la nueva contrasena.", ApiResponseCode.MissingRequiredFields);
            }

            if (request.NewPassword.Length < 6)
            {
                return Error("La nueva contrasena debe tener al menos 6 caracteres.", ApiResponseCode.InvalidData);
            }

            if (string.Equals(request.CurrentPassword, request.NewPassword, StringComparison.Ordinal))
            {
                return Error("La nueva contrasena debe ser diferente a la actual.", ApiResponseCode.InvalidData);
            }

            var user = await _context.AspNetUsers
                .FirstOrDefaultAsync(item => item.PkIdUsuario == id);

            if (user == null)
            {
                var usuario = await _context.Usuarios
                    .AsNoTracking()
                    .FirstOrDefaultAsync(item => item.PkIdUsuario == id);

                if (!string.IsNullOrWhiteSpace(usuario?.AspNetUserId))
                {
                    user = await _context.AspNetUsers
                        .FirstOrDefaultAsync(item => item.Id == usuario.AspNetUserId);
                }
            }

            if (user == null)
            {
                return Error("No se encontro la cuenta de acceso del usuario.", ApiResponseCode.NotFound);
            }

            var currentPasswordHash = CriptoSecurity.Encrypt(request.CurrentPassword);
            if (!string.Equals(user.PasswordHash, currentPasswordHash, StringComparison.Ordinal))
            {
                return Error("La contrasena actual no es correcta.", ApiResponseCode.InvalidData);
            }

            user.PasswordHash = CriptoSecurity.Encrypt(request.NewPassword);
            user.SecurityStamp = Guid.NewGuid().ToString("N");

            await _context.SaveChangesAsync();

            return new PagedResult<bool>
            {
                Success = true,
                Message = "Contrasena actualizada correctamente.",
                Code = ApiResponseCode.Success.ToCode(),
                Data = true,
                Items = new List<bool> { true },
                TotalCount = 1
            };
        }

        private static PagedResult<bool> Error(string message, ApiResponseCode code)
            => new()
            {
                Success = false,
                Message = message,
                Code = code.ToCode(),
                Data = false,
                TotalCount = 0
            };
    }
}
