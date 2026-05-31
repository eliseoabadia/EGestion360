using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.SoporteDocumental;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.SoporteDocumental;
using EG.Domain.DTOs.Responses.SoporteDocumental;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.SoporteDocumental
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class SoporteDocumentalController(
        ISoporteDocumentalAppService service,
        IUserContextService userContext) : ControllerBase
    {
        [HttpPost("entidad")]
        public async Task<ActionResult<PagedResult<DocumentoResponse>>> ObtenerPorEntidad([FromBody] DocumentoEntidadRequest request)
        {
            request.FkidEmpresaSis ??= userContext.TryGetCurrentEmpresaId();
            return Ok(await service.ObtenerPorEntidadAsync(request));
        }

        [HttpPost("resumen")]
        public async Task<ActionResult<PagedResult<DocumentoResumenResponse>>> ObtenerResumen([FromBody] DocumentoEntidadRequest request)
        {
            request.FkidEmpresaSis ??= userContext.TryGetCurrentEmpresaId();
            return Ok(await service.ObtenerResumenAsync(request));
        }

        [HttpPost("upload")]
        [RequestSizeLimit(50 * 1024 * 1024)]
        public async Task<ActionResult<PagedResult<DocumentoResponse>>> Guardar([FromForm] DocumentoUploadFormRequest request)
        {
            if (request.File == null || request.File.Length == 0)
            {
                return BadRequest(new PagedResult<DocumentoResponse>
                {
                    Success = false,
                    Message = "El archivo es requerido.",
                    Code = "INVALID_FILE"
                });
            }

            if (request.File.Length > 50 * 1024 * 1024)
            {
                return BadRequest(new PagedResult<DocumentoResponse>
                {
                    Success = false,
                    Message = "El archivo supera el limite de 50 MB.",
                    Code = "FILE_TOO_LARGE"
                });
            }

            await using var stream = request.File.OpenReadStream();
            using var memory = new MemoryStream();
            await stream.CopyToAsync(memory);

            var dto = new DocumentoUploadRequest
            {
                Modulo = request.Modulo,
                SubModulo = request.SubModulo,
                Controlador = request.Controlador,
                Servicio = request.Servicio,
                EntidadId = request.EntidadId,
                FkidEmpresaSis = request.FkidEmpresaSis ?? userContext.TryGetCurrentEmpresaId(),
                Titulo = request.Titulo,
                Descripcion = request.Descripcion,
                NombreOriginal = request.File.FileName,
                TipoMime = request.File.ContentType,
                TamanoBytes = request.File.Length,
                Contenido = memory.ToArray()
            };

            return Ok(await service.GuardarAsync(dto, userContext.GetCurrentUserId()));
        }

        [HttpGet("{id:long}/download")]
        public async Task<IActionResult> Descargar(long id)
        {
            var document = await service.ObtenerContenidoAsync(id);
            if (document == null)
                return NotFound();

            return File(document.Contenido, document.TipoMime, document.NombreOriginal);
        }

        [HttpDelete("{id:long}")]
        public async Task<ActionResult<PagedResult<bool>>> Eliminar(long id)
            => Ok(await service.EliminarAsync(id, userContext.GetCurrentUserId()));

        [HttpGet("{id:long}/anotaciones")]
        public async Task<ActionResult<PagedResult<DocumentoAnotacionResponse>>> ObtenerAnotaciones(long id, [FromQuery] bool incluirInactivos = false)
            => Ok(await service.ObtenerAnotacionesAsync(id, incluirInactivos));

        [HttpPost("anotaciones")]
        public async Task<ActionResult<PagedResult<DocumentoAnotacionResponse>>> CrearAnotacion([FromBody] DocumentoAnotacionCrearRequest request)
            => Ok(await service.CrearAnotacionAsync(request, userContext.GetCurrentUserId()));

        [HttpDelete("anotaciones/{id:long}")]
        public async Task<ActionResult<PagedResult<bool>>> EliminarAnotacion(long id)
            => Ok(await service.EliminarAnotacionAsync(id, userContext.GetCurrentUserId()));
    }

    public class DocumentoUploadFormRequest
    {
        public string Modulo { get; set; } = string.Empty;
        public string? SubModulo { get; set; }
        public string? Controlador { get; set; }
        public string? Servicio { get; set; }
        public long EntidadId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public string? Titulo { get; set; }
        public string? Descripcion { get; set; }
        public IFormFile? File { get; set; }
    }
}
