using EG.Application.Interfaces.Account;
using EG.Application.Interfaces;
using EG.Business.Interfaces;
using EG.Common;
using EG.Common.GenericModel;
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
        private readonly ILogger<AuthAppService> _logger;

        public AuthAppService(
            IAuthService authService,
            ITokenService tokenService,
            IOptions<JwtSettings> jwtSettings,
            ILogger<AuthAppService> logger)
        {
            _authService = authService ?? throw new ArgumentNullException(nameof(authService));
            _tokenService = tokenService ?? throw new ArgumentNullException(nameof(tokenService));
            _jwtSettings = jwtSettings ?? throw new ArgumentNullException(nameof(jwtSettings));
            _logger = logger ?? throw new ArgumentNullException(nameof(logger));
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
                    _logger.LogWarning("Login fallido por credenciales invalidas para {Email}", loginRequest.Email);

                    return new LoginResponseDto
                    {
                        IsAuthenticated = false,
                        AccessToken = string.Empty,
                        Message = "Credenciales incorrectas"
                    };
                }

// 🔧 PASO 2: Generar token JWT (los permisos se cargan por separado)
var loginResponse = _tokenService.GenTokenkey(
    usuarioSP.PkIdUsuario,
    usuarioSP.PayrollID,
    usuarioSP.NombreUsuario,
    usuarioSP.Email,
    usuarioSP.FkidEmpresaSis,
    _jwtSettings.Value);

                _logger.LogInformation(
                    "Login exitoso para {Email}. UsuarioId={UsuarioId}",
                    loginRequest.Email,
                    usuarioSP.PkIdUsuario);

                return loginResponse;
            }
            catch (ArgumentNullException ex)
            {
                _logger.LogWarning(ex, "Solicitud de login invalida");

                throw;
            }
            catch (ArgumentException ex)
            {
                _logger.LogWarning(ex, "Solicitud de login invalida para {Email}", loginRequest.Email);

                throw;
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Error tecnico durante login para {Email}", loginRequest.Email);

                throw new InvalidOperationException(UserFacingMessages.UnexpectedError, ex);
            }
        }
    }
}
