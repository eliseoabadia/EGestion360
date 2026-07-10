using EG.Application.Interfaces.DocumentRag;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.DocumentRag;
using EG.Domain.DTOs.Responses.DocumentRag;
using EG.Domain.Interfaces;
using EG.Domain.Platform.Settings;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Options;

namespace EG.ApiCoreBS.Controllers.Platform.DocumentRag
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DocumentRagController(
        IDocumentRagAppService service,
        IUserContextService userContext,
        IOptions<DocumentRagSettings> settings) : ControllerBase
    {
        private const long MaxRequestFileSize = 50L * 1024L * 1024L;

        [HttpPost("sessions")]
        public async Task<ActionResult<PagedResult<DocumentRagSessionResponse>>> CreateSession([FromBody] DocumentRagSessionRequest request)
        {
            request.FkidEmpresaSis = userContext.TryGetCurrentEmpresaId() ?? request.FkidEmpresaSis;
            return Ok(await service.CreateSessionAsync(request, userContext.GetCurrentUserId()));
        }

        [HttpGet("sessions/{sessionId:guid}")]
        public async Task<ActionResult<PagedResult<DocumentRagSessionResponse>>> GetSession(Guid sessionId)
            => Ok(await service.GetSessionAsync(sessionId, userContext.GetCurrentUserId()));

        [HttpPost("documents")]
        [RequestSizeLimit(MaxRequestFileSize)]
        public async Task<ActionResult<PagedResult<DocumentRagDocumentResponse>>> Upload([FromForm] DocumentRagUploadFormRequest request)
        {
            if (request.File == null || request.File.Length == 0)
            {
                return BadRequest(new PagedResult<DocumentRagDocumentResponse>
                {
                    Success = false,
                    Message = "El archivo es requerido.",
                    Code = "INVALID_FILE"
                });
            }

            var configuredMaxBytes = Math.Max(1, settings.Value.MaxFileSizeMB) * 1024L * 1024L;
            var maxFileSize = Math.Min(MaxRequestFileSize, configuredMaxBytes);
            if (request.File.Length > maxFileSize)
            {
                return BadRequest(new PagedResult<DocumentRagDocumentResponse>
                {
                    Success = false,
                    Message = $"El archivo supera el limite de {maxFileSize / 1024L / 1024L} MB.",
                    Code = "FILE_TOO_LARGE"
                });
            }

            await using var stream = request.File.OpenReadStream();
            using var memory = new MemoryStream();
            await stream.CopyToAsync(memory);

            var empresaContexto = userContext.TryGetCurrentEmpresaId();

            var dto = new DocumentRagUploadRequest
            {
                SessionId = request.SessionId,
                Modulo = request.Modulo ?? "RAG",
                SubModulo = request.SubModulo,
                Controlador = request.Controlador,
                Servicio = request.Servicio,
                EntidadId = request.EntidadId,
                FkidEmpresaSis = empresaContexto ?? request.FkidEmpresaSis,
                Titulo = request.Titulo,
                Descripcion = request.Descripcion,
                NombreOriginal = request.File.FileName,
                TipoMime = string.IsNullOrWhiteSpace(request.File.ContentType)
                    ? "application/octet-stream"
                    : request.File.ContentType,
                TamanoBytes = request.File.Length,
                Contenido = memory.ToArray()
            };

            return Ok(await service.UploadAsync(dto, userContext.GetCurrentUserId()));
        }

        [HttpPost("ask")]
        public async Task<ActionResult<PagedResult<DocumentRagAskResponse>>> Ask([FromBody] DocumentRagAskRequest request)
            => Ok(await service.AskAsync(request, userContext.GetCurrentUserId()));

        [HttpGet("sessions/{sessionId:guid}/history")]
        public async Task<ActionResult<PagedResult<DocumentRagHistoryItemResponse>>> GetHistory(Guid sessionId)
            => Ok(await service.GetHistoryAsync(sessionId, userContext.GetCurrentUserId()));

        [HttpDelete("sessions/{sessionId:guid}")]
        public async Task<ActionResult<PagedResult<bool>>> ReleaseSession(Guid sessionId)
            => Ok(await service.ReleaseSessionAsync(sessionId, userContext.GetCurrentUserId()));
    }

    public class DocumentRagUploadFormRequest
    {
        public Guid SessionId { get; set; }
        public string? Modulo { get; set; }
        public string? SubModulo { get; set; }
        public string? Controlador { get; set; }
        public string? Servicio { get; set; }
        public long? EntidadId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public string? Titulo { get; set; }
        public string? Descripcion { get; set; }
        public IFormFile? File { get; set; }
    }
}
