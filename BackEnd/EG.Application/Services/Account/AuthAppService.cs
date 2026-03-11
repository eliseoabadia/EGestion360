using EG.Application.Interfaces.Account;
using EG.Application.Interfaces;
using EG.Business.Interfaces;
using EG.Common.GenericModel;
using EG.Common.Enums;
using EG.Domain.DTOs.Requests;
using Microsoft.Extensions.Options;
using Microsoft.Extensions.Logging;

namespace EG.Application.Services.Account
{
    public class AuthAppService : IAuthAppService
    {
        private readonly IAuthService _authService; // Business - Datos y Claims
        private readonly ITokenService _tokenService; // Application - Generar JWT
        private readonly IOptions<JwtSettings> _jwtSettings;
        //private readonly Logger.Log4NetLogger _logger;

        public AuthAppService(
            IAuthService authService,
            ITokenService tokenService,
            IOptions<JwtSettings> jwtSettings)
        {
            _authService = authService ?? throw new ArgumentNullException(nameof(authService));
            _tokenService = tokenService ?? throw new ArgumentNullException(nameof(tokenService));
            _jwtSettings = jwtSettings ?? throw new ArgumentNullException(nameof(jwtSettings));
            //_logger = new Logger.Log4NetLogger(typeof(AuthAppService));
        }

        public async Task<LoginResponseDto> LoginAsync(LoginRequestDto loginRequest)
        {
            // 🔧 VALIDACIÓN INICIAL
            if (loginRequest == null)
                throw new ArgumentNullException(nameof(loginRequest), "Datos de login requeridos");

            if (string.IsNullOrWhiteSpace(loginRequest.Email))
                throw new ArgumentException("Email es requerido", nameof(loginRequest.Email));

            if (string.IsNullOrWhiteSpace(loginRequest.Password))
                throw new ArgumentException("Contraseña es requerida", nameof(loginRequest.Password));

            try
            {
                // 🔧 PASO 1: Validar credenciales (BUSINESS)
                var usuarioSP = await _authService.ValidarCredencialesAsync(loginRequest);

                if (usuarioSP == null)
                {
                    Console.WriteLine(
                        //LogLevelGRP.Warning,
                        $"Login fallido: Credenciales inválidas - {loginRequest.Email}",
                        (byte)SystemLogTypes.Warning,
                        "Login",
                        "0",
                        "");

                    return new LoginResponseDto
                    {
                        IsAuthenticated = false,
                        AccessToken = string.Empty,
                        Message = "Credenciales incorrectas"
                    };
                }

                // 🔧 PASO 2: Obtener claims del usuario (BUSINESS)
                var claims = await _authService.ObtenerClaimsUsuarioAsync(usuarioSP.PkIdUsuario);

                // 🔧 PASO 3: Generar token JWT (APPLICATION - ITokenService)
                var loginResponse = _tokenService.GenTokenkey(
                    usuarioSP.PkIdUsuario,
                    usuarioSP.PayrollID,
                    usuarioSP.NombreUsuario,
                    usuarioSP.Email,
                    claims,
                    _jwtSettings.Value);

                Console.WriteLine(
                    //LogLevelGRP.Info,
                    $"Login exitoso: {loginRequest.Email}",
                    (byte)SystemLogTypes.Information,
                    "Login",
                    usuarioSP.PkIdUsuario.ToString(),
                    "");

                return loginResponse;
            }
            catch (ArgumentNullException ex)
            {
                Console.WriteLine(
                    //LogLevelGRP.Error,
                    $"Error de validación: {ex.Message}",
                    (byte)SystemLogTypes.Error,
                    "Login",
                    "0",
                    ex.StackTrace ?? "");

                throw;
            }
            catch (ArgumentException ex)
            {
                Console.WriteLine(
                    //LogLevelGRP.Error,
                    $"Error de validación: {ex.Message}",
                    (byte)SystemLogTypes.Error,
                    "Login",
                    "0",
                    ex.StackTrace ?? "");

                throw;
            }
            catch (Exception ex)
            {
                Console.WriteLine(
                    //LogLevelGRP.Error,
                    $"Error en login: {ex.Message}",
                    (byte)SystemLogTypes.Error,
                    "Login",
                    "0",
                    ex.StackTrace ?? "");

                throw new InvalidOperationException("Error durante el proceso de login", ex);
            }
        }
    }
}