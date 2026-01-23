namespace EG.Builder.Templates;
public static class ControllerTemplate
{
    public static string Controller =
@"using EG.Application.DTOs;
using EG.Application.DTOs.General;
using EG.Application.Interfaces.Auth;
using EG.Application.Interfaces.Configuration;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.Api.Controllers.Account
{
    [Authorize(AuthenticationSchemes = Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme)]
    [Route(""api/[controller]"")]
    [ApiController]
    [Authorize]
    public class TABLENAMEController : ControllerBase
    {
        private readonly Logger.Log4NetLogger _logger = new Logger.Log4NetLogger(typeof(TABLENAMEController));
        private readonly ITABLENAMEService _service;

        public TABLENAMEController(ITABLENAMEService service)
        {
            _service = service;
        }

        [HttpPost(""CreateTABLENAME"")]
        public async Task<IActionResult> CreateTABLENAME([FromBody]  TABLENAMEDto item)
        {
            var _item = await _service.AddTABLENAMEAsync(item);
            return Ok(_item);
        }

        [HttpPost(""SetTABLENAME/{id}"")]
        public async Task<IActionResult> SetTABLENAME(int id, [FromBody] TABLENAMEDto item)
        {
            var _item = await _service.UpdateTABLENAMEAsync(id, item);
            return Ok(_item);
        }

        [HttpPost(""DeleteTABLENAME/{id}"")]
        public async Task<IActionResult> DeleteTABLENAME(int id)
        {
            var _item = await _service.DeleteTABLENAMEAsync(id);
            return Ok(_item);
        }


        [HttpGet(""{id}"")]
        public async Task<ActionResult<TABLENAMEResponse>> GetTABLENAMEByIdAsync(int id)
        {
            return Ok(await _service.GetTABLENAMEByIdAsync(id));
        }

        [HttpGet("""")]
        public async Task<ActionResult<IList<TABLENAMEResponse>>> GetAllTABLENAMEAsync()
        {
            return Ok(await _service.GetAllTABLENAMEAsync());
        }

        [HttpGet(""GetAllTABLENAMEsPaginadoAsync"")]
        public async Task<ActionResult<IList<TABLENAMEResponse>>> GetAllTABLENAMEsPaginadoAsync(int page,
                int pageSize,
                string filtro,
                string sortLabel,
                string sortDirection)
        {
            return Ok(await _service.GetAllTABLENAMEsPaginadoAsync(page, pageSize, filtro, sortLabel, sortDirection));
        }
}

";

    public static string IController =
@"using EG.WebApp.Models.Configuration;
using Microsoft.AspNetCore.Components.Forms;

namespace EG.WebApp.Contracs.Configuration
{
    public interface ITABLENAMEService
    {
        Task<IActionResult> CreateTABLENAME([FromBody]  TABLENAMEDto item);
        Task<IActionResult> SetTABLENAME(int id, [FromBody] TABLENAMEDto item);
        Task<IActionResult> DeleteTABLENAME(int id);
        Task<ActionResult<TABLENAMEResponse>> GetTABLENAMEByIdAsync(int id);
        Task<ActionResult<IList<TABLENAMEResponse>>> GetAllTABLENAMEAsync();

        Task<ActionResult<IList<TABLENAMEResponse>>> GetAllTABLENAMEsPaginadoAsync(int page,
                int pageSize,
                string filtro,
                string sortLabel,
                string sortDirection);
    }
}

";
}

