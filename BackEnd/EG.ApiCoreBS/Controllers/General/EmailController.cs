using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EmailController : ControllerBase
    {
        private readonly IEmailService _emailService;

        public EmailController(IEmailService emailService)
        {
            _emailService = emailService;
        }

        [HttpPost("send")]
        public async Task<ActionResult<PagedResult<EmailSendResponse>>> Send([FromBody] EmailMessageRequest request, CancellationToken cancellationToken)
        {
            var result = await _emailService.SendAsync(request, cancellationToken);
            return result.Success ? Ok(result) : BadRequest(result);
        }
    }
}
