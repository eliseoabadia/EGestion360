using AutoMapper;
using EG.Application.CommonModel;
using EG.Application.Interfaces;
using EG.Business.Interfaces;
using EG.Common;
using EG.Domain.DTOs.Requests;
using EG.Domain.DTOs.Requests.Auth;
using EG.Domain.Entities;
using EG.Domain.Interfaces;
using Microsoft.Data.SqlClient;


namespace EG.Business.Services
{
    public class AuthService(ITokenService tokenService, 
                IRepository<Usuario> userRepository, 
                IRepositorySP<LoginInformationEmployeeResult> repositorySP, 
                IMapper mapper) : IAuthService
    {
        private readonly ITokenService _tokenService = tokenService;
        private readonly IRepositorySP<LoginInformationEmployeeResult> _repositorySP = repositorySP;
        private readonly IRepository<Usuario> _repository = userRepository;
        private readonly IMapper _mapper = mapper;

        public async Task<LoginResponseDto> Login(LoginRequestDto loginRequest, JwtSettings jwtSettings)
        {
            string _password = CriptoSecurity.Encrypt(loginRequest.Password);

            LoginResponseDto resultUser = new LoginResponseDto();

            var user = await _repository.GetAllWithIncludes2Async(
                u => u.PayrollId == loginRequest.Email
            );

            if (user.Any())
            {

                int usuario = user.First().PkIdUsuario;

                var param1 = new SqlParameter("@PayrollID", loginRequest.Email);
                var result = await _repositorySP.ExecuteStoredProcedureAsync<LoginInformationEmployeeResult>("SIS.LoginInformationEmployee", param1);

                if (result.Any())
                {
                    var _usuarioSP = result.First();
                    if (_usuarioSP.PasswordHash == _password)
                    {

                        var paramU = new SqlParameter("@PkIdUser", _usuarioSP.PkIdUsuario);
                        var resultClaimsEnumerable = await _repositorySP.ExecuteStoredProcedureAsync<spGetClaimsByUserResult>("[SIS].[spGetClaimsByUser]", paramU);
                        var resultClaims = resultClaimsEnumerable.ToList();


                        resultUser = _tokenService.GenTokenkey(_usuarioSP.PkIdUsuario,_usuarioSP.PayrollID, _usuarioSP.NombreUsuario, _usuarioSP.Email, resultClaims, jwtSettings);
                        resultUser.IsAuthenticated = true;

                        return resultUser;
                    }
                }
            }


            return new LoginResponseDto { IsAuthenticated = false, AccessToken = string.Empty, Message = "Credenciales incorrectas" };
        }

    }
}