using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Authorize(AuthenticationSchemes = Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme)]
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UserProfileController : ControllerBase
    {
        private readonly IUserProfileAppService _appService;
        private readonly IUserContextService _userContext;

        public UserProfileController(IUserProfileAppService appService, IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet("GetProfileImage/{id}")]
        public async Task<ActionResult<PerfilUsuarioResponse>> GetProfileImage(int id)
        {
            var result = await _appService.GetProfileImageAsync(id);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpPost("CreateProfile")]
        [Authorize(Policy = "Sistema|Usuario|new")]
        public async Task<IActionResult> CreateProfile([FromBody] UsuarioDto user)
        {
            var result = await _appService.CreateProfileAsync(user);
            return Ok(result);
        }

        [HttpPost("SetProfile/{id}")]
        [Authorize(Policy = "Sistema|Usuario|update")]
        public async Task<IActionResult> SetProfile(int id, [FromBody] UsuarioDto user)
        {
            var result = await _appService.SetProfileAsync(id, user);
            return Ok(result);
        }

        [HttpPost("ChangePassword/{id}")]
        public async Task<ActionResult<PagedResult<bool>>> ChangePassword(int id, [FromBody] ChangePasswordDto request)
        {
            var result = await _appService.ChangePasswordAsync(id, request, _userContext.GetCurrentUserId());

            if (!result.Success)
            {
                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("DeleteProfile/{id}")]
        [Authorize(Policy = "Sistema|Usuario|delete")]
        public async Task<IActionResult> DeleteProfile(int id)
        {
            var result = await _appService.DeleteProfileAsync(id);
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<UsuarioResponse>> GetProfileUser(int id)
        {
            var result = await _appService.GetProfileUserAsync(id);
            return result == null ? NotFound() : Ok(result);
        }

        [HttpGet("")]
        [Authorize(Policy = "Sistema|Usuario|view")]
        public async Task<ActionResult<IList<UsuarioResponse>>> GetAllUser()
        {
            return Ok(await _appService.GetAllUsersAsync());
        }

        [HttpPost("GetAllUserPaginado")]
        [Authorize(Policy = "Sistema|Usuario|view")]
        public async Task<ActionResult<IList<UsuarioResponse>>> GetAllUserPaginado([FromBody] PagedRequest _params)
        {
            return Ok(await _appService.GetAllUsersPaginadoAsync(_params));
        }

        [HttpPost]
        [Authorize(Policy = "Sistema|MiPerfil|update")]
        [RequestSizeLimit(2 * 1024 * 1024)]
        public async Task<IActionResult> UploadImage(PerfilUsuarioResponse fotografia)
        {
            if (fotografia == null)
                return BadRequest("No se recibió archivo.");
            if (fotografia.FkidUsuarioSis != _userContext.GetCurrentUserId())
                return Forbid();
            await _appService.UploadImageAsync(fotografia);
            return Ok(new { Message = "Imagen guardada correctamente" });
        }
    }
}
