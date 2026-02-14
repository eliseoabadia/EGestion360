using EG.Application.CommonModel;
using EG.Domain.DTOs.Requests;
using EG.Domain.DTOs.Requests.Auth;

namespace EG.Business.Interfaces
{
    public interface IAuthService
    {
        Task<LoginResponseDto> Login(LoginRequestDto loginRequest, JwtSettings jwtSettings);

    }
}