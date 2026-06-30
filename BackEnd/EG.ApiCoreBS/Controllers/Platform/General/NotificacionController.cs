using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class NotificacionController : ControllerBase
    {
        private readonly INotificacionAppService _service;
        private readonly IUserContextService _userContext;

        public NotificacionController(INotificacionAppService service, IUserContextService userContext)
        {
            _service = service;
            _userContext = userContext;
        }

        [HttpGet("resumen")]
        public async Task<ActionResult<PagedResult<NotificacionResumenResponse>>> GetResumen()
        {
            var result = await _service.GetResumenAsync(_userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpGet("mis")]
        public async Task<ActionResult<PagedResult<NotificacionUsuarioResponse>>> GetMisNotificaciones(
            [FromQuery] int take = 30,
            [FromQuery] bool soloPendientes = false)
        {
            var result = await _service.GetMisNotificacionesAsync(_userContext.GetCurrentUserId(), take, soloPendientes);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpGet("{id:long}/conversacion")]
        public async Task<ActionResult<PagedResult<NotificacionUsuarioResponse>>> GetConversacion(long id)
        {
            var result = await _service.GetConversacionAsync(id, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:long}/leer")]
        public async Task<ActionResult<PagedResult<bool>>> MarcarLeida(long id)
        {
            var result = await _service.MarcarLeidaAsync(id, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:long}/atender")]
        public async Task<ActionResult<PagedResult<bool>>> Atender(long id)
        {
            var result = await _service.AtenderAsync(id, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("{id:long}/responder")]
        public async Task<ActionResult<PagedResult<bool>>> Responder(long id, [FromBody] NotificacionResponderRequest request)
        {
            var result = await _service.ResponderAsync(id, _userContext.GetCurrentUserId(), request.Mensaje);
            return result.Success ? Ok(result) : BadRequest(result);
        }
    }
}
