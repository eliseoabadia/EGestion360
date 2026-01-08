using EG.Business.Interfaces;
using EG.Domain.DTOs.Requests;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;
namespace EG.ApiCore.Controllers.Account
{
    [Authorize(AuthenticationSchemes = Microsoft.AspNetCore.Authentication.JwtBearer.JwtBearerDefaults.AuthenticationScheme)]
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NavigateController : ControllerBase
    {
        private readonly INavigateService _service;
        private readonly ILogger<NavigateController> _logger;

        public NavigateController(INavigateService service, ILogger<NavigateController> logger)
        {
            _service = service;
            _logger = logger;
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<spNodeMenuResponse>> GetMenu(int id)
        {
            var sw = Stopwatch.StartNew();
            _logger.LogInformation("GetMenu START id={Id}", id);
            try
            {
                var _menu = await _service.GetMenuAsync(id);
                sw.Stop();
                //_logger.LogInformation("GetMenu END id={Id} elapsedMs={Ms} items={Count}", id, sw.ElapsedMilliseconds);
                return _menu == null ? NotFound() : Ok(_menu);
            }
            catch (Exception ex)
            {
                sw.Stop();
                _logger.LogError(ex, "GetMenu ERROR id={Id} elapsedMs={Ms}", id, sw.ElapsedMilliseconds);
                throw;
            }
        }

        [HttpPost("ping")]
        public async Task<bool> Ping([FromBody] LoginRequestDto loginRequest)
        {
            loginRequest.Email = "";
            return true;
        }
    }

}
