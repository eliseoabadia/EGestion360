using EG.Application.CommonModel;
using EG.Business.Interfaces;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.Api.Controllers.Account
{
    [Authorize(AuthenticationSchemes = Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme)]
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UserProfileController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(UserProfileController));
        private readonly IUserProfileService _service;
        private readonly IEmployeeService _serviceEmp;
        private readonly IAuthService _currentUser;

        public UserProfileController(IUserProfileService service, IAuthService currentUser, IEmployeeService serviceEmp)
        {
            _service = service;
            _currentUser = currentUser;
            _serviceEmp = serviceEmp;
        }

        [HttpGet("GetProfileImage/{id}")]
        public async Task<ActionResult<PerfilUsuarioResponse>> GetProfileImage(int id)
        {
            var _profile = await _service.GetUsuarioByIdAsync(id);
            return _profile == null ? NotFound() : Ok(_profile);
        }

        [HttpPost("CreateProfile")]
        public async Task<IActionResult> CreateProfile([FromBody] UsuarioDto user)
        {
            var _profile = await _serviceEmp.AddEmployeeAsync(user);
            return Ok(_profile);
        }

        [HttpPost("SetProfile/{id}")]
        public async Task<IActionResult> SetProfile(int id, [FromBody] UsuarioDto user)
        {
            var _profile = await _serviceEmp.UpdateEmployeeAsync(id, user);
            return Ok(_profile);
        }

        [HttpPost("DeleteProfile/{id}")]
        public async Task<IActionResult> DeleteProfile(int id)
        {
            var _profile = await _serviceEmp.DeleteEmployeeAsync(id);
            return Ok(_profile);
        }


        [HttpGet("{id}")]
        public async Task<ActionResult<UsuarioResponse>> GetProfileUser(int id)
        {
            return Ok(await _serviceEmp.GetEmployeeByIdAsync(id));
        }

        [HttpGet("")]
        public async Task<ActionResult<IList<UsuarioResponse>>> GetAllUser()
        {
            return Ok(await _serviceEmp.GetAllUsersAsync());
        }

        [HttpPost("GetAllUserPaginado")]
        public async Task<ActionResult<IList<UsuarioResponse>>> GetAllUserPaginado([FromBody] PagedRequest _params)
        {
            return Ok(await _serviceEmp.GetAllUsuariosPaginadoAsync(_params));
        }

        [HttpPost]
        [RequestSizeLimit(2 * 1024 * 1024)] // 2MB
        public async Task<IActionResult> UploadImage(PerfilUsuarioResponse fotografia)
        {
            if (fotografia == null)
                return BadRequest("No se recibió archivo.");
            await _service.UpdateUserUsuarioAsync(fotografia.FkidUsuarioSis, fotografia);

            return Ok(new { Message = "Imagen guardada correctamente" });
        }

    }

}
