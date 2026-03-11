using EG.Domain.DTOs.Requests;

namespace EG.Application.Interfaces.Account
{
    public interface IAuthAppService
    {
        /// <summary>
        /// Realiza el login del usuario: valida credenciales, obtiene claims y genera JWT
        /// </summary>
        Task<LoginResponseDto> LoginAsync(LoginRequestDto loginRequest);
    }
}