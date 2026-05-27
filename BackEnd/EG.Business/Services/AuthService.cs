using Mapster;
using EG.Business.Interfaces;
using EG.Common;
using EG.Common.Enums;
using EG.Domain.DTOs.Requests;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;

namespace EG.Business.Services
{
    public class AuthService : IAuthService
    {
        private readonly IRepository<Usuario> _repository;
        private readonly IRepositorySP<LoginInformationEmployeeResult> _repositorySP;
        private readonly IRepositorySP<spGetClaimsByUserResult> _repositoryClaimsSP;

        public AuthService(
            IRepository<Usuario> userRepository,
            IRepositorySP<LoginInformationEmployeeResult> repositorySP,
            IRepositorySP<spGetClaimsByUserResult> repositoryClaimsSP)
        {
            _repository = userRepository ?? throw new ArgumentNullException(nameof(userRepository));
            _repositorySP = repositorySP ?? throw new ArgumentNullException(nameof(repositorySP));
            _repositoryClaimsSP = repositoryClaimsSP ?? throw new ArgumentNullException(nameof(repositoryClaimsSP));
        }

        /// <summary>
        /// Valida las credenciales del usuario y obtiene sus datos
        /// </summary>
        public async Task<LoginInformationEmployeeResult> ValidarCredencialesAsync(LoginRequestDto loginRequest)
        {
            if (loginRequest == null)
                throw new ArgumentNullException(nameof(loginRequest));

            if (string.IsNullOrWhiteSpace(loginRequest.Email) || string.IsNullOrWhiteSpace(loginRequest.Password))
                return null;

            try
            {
                // 🔧 OBTENER INFORMACIÓN DEL USUARIO DESDE BD
                var param = new SqlParameter("@PayrollID", loginRequest.Email);
                var result = await _repositorySP.ExecuteStoredProcedureAsync<LoginInformationEmployeeResult>(
                    "SIS.LoginInformationEmployee",
                    param);

                if (!result.Any())
                    return null;

                var usuarioSP = result.First();

                // 🔧 VALIDAR CONTRASEÑA ENCRIPTADA
                string encryptedPassword = CriptoSecurity.Encrypt(loginRequest.Password);
                
                if (usuarioSP.PasswordHash != encryptedPassword)
                    return null; // Contraseña incorrecta

                var usuario = await _repository.GetByIdAsync(usuarioSP.PkIdUsuario);
                usuarioSP.FkidEmpresaSis = usuario?.FkidEmpresaSis;

                return usuarioSP;
            }
            catch (Exception ex)
            {
                Console.WriteLine(
                    //LogLevelGRP.Error,
                    $"Error validando credenciales: {ex.Message}",
                    (byte)SystemLogTypes.Error,
                    "ValidarCredenciales",
                    "0",
                    ex.StackTrace ?? "");

                throw;
            }
        }

        /// <summary>
        /// Obtiene los claims del usuario desde la base de datos
        /// </summary>
        public async Task<List<spGetClaimsByUserResult>> ObtenerClaimsUsuarioAsync(int usuarioId)
        {
            if (usuarioId <= 0)
                throw new ArgumentException("Usuario ID debe ser mayor a 0", nameof(usuarioId));

            try
            {
                bool esParaLogin = true;
                // 🔧 PARÁMETROS PARA EL SP
                var parameters = new[]
                {
                    new SqlParameter("@PkIdUser", usuarioId),
                    new SqlParameter("@EsParaLogin", esParaLogin)
                };

                var resultClaims = await _repositorySP.ExecuteStoredProcedureAsync<spGetClaimsByUserResult>(
                    "[SIS].[spGetClaimsByUser]",
                    parameters);

                return resultClaims?.ToList() ?? new List<spGetClaimsByUserResult>();
            }
            catch (Exception ex)
            {
                Console.WriteLine(
                    //LogLevelGRP.Error,
                    $"Error obteniendo claims: {ex.Message}",
                    (byte)SystemLogTypes.Error,
                    "ObtenerClaimsUsuario",
                    usuarioId.ToString(),
                    ex.StackTrace ?? "");

                throw;
            }
        }
    }
}
