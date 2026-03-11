using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests;
using EG.Infraestructure.Models;

namespace EG.Business.Interfaces
{
    public interface IAuthService
    {

        Task<List<spGetClaimsByUserResult>> ObtenerClaimsUsuarioAsync(int usuarioId);

        Task<LoginInformationEmployeeResult> ValidarCredencialesAsync(LoginRequestDto loginRequest);
    }
}