using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EgresoProyectadoController : ControllerBase
    {
        private readonly IEgresoProyectadoAppService _appService;
        private readonly IUserContextService _userContext;

        public EgresoProyectadoController(
            IEgresoProyectadoAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (!result.Success)
                return NotFound(result);

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> Create([FromBody] EgresoProyectadoResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
                return BadRequest(result);

            return CreatedAtAction(nameof(GetById), new { id = response.PkidEgresoProyectado }, result);
        }

        [HttpPost("ai-import/preview")]
        [RequestSizeLimit(50 * 1024 * 1024)]
        public async Task<ActionResult<PagedResult<EgresoProyectadoAiImportPreviewResponse>>> PreviewAiImport([FromForm] EgresoProyectadoAiImportUploadFormRequest request)
        {
            if (request.File == null || request.File.Length == 0)
            {
                return BadRequest(new PagedResult<EgresoProyectadoAiImportPreviewResponse>
                {
                    Success = false,
                    Message = "El archivo es requerido.",
                    Code = "INVALID_FILE"
                });
            }

            await using var stream = request.File.OpenReadStream();
            using var memory = new MemoryStream();
            await stream.CopyToAsync(memory);

            var dto = new EgresoProyectadoAiImportUploadRequest
            {
                NombreOriginal = request.File.FileName,
                TipoMime = string.IsNullOrWhiteSpace(request.File.ContentType)
                    ? "application/octet-stream"
                    : request.File.ContentType,
                TamanoBytes = request.File.Length,
                Contenido = memory.ToArray(),
                HeaderFallback = new EgresoProyectadoAiImportHeaderRequest
                {
                    FkidAnioSis = request.FkidAnioSis,
                    Anio = request.Anio,
                    Fecha = request.Fecha
                }
            };

            var result = await _appService.PreviewAiImportAsync(dto, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("ai-import/confirm")]
        public async Task<ActionResult<PagedResult<EgresoProyectadoAiImportPreviewResponse>>> ConfirmAiImport([FromBody] EgresoProyectadoAiImportConfirmRequest request)
        {
            var result = await _appService.ConfirmAiImportAsync(request, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> Update(int id, [FromBody] EgresoProyectadoResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                if (result.Code == "NOT_FOUND")
                    return NotFound(result);

                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            if (!result.Success)
            {
                if (result.Code == "NOT_FOUND")
                    return NotFound(result);

                return BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpGet("GetFuenteFinanciamientoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetFuenteFinanciamientoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetFuenteFinanciamientoLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpGet("GetTipoGastoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetTipoGastoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetTipoGastoLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpGet("GetDigitoIdentificadorLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetDigitoIdentificadorLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetDigitoIdentificadorLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpGet("GetDestinoGastoLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetDestinoGastoLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetDestinoGastoLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpGet("GetPyLookupPaginado")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetPyLookupPaginado(int page = 1, int pageSize = 25, string? filter = null)
        {
            var result = await _appService.GetPyLookupPaginadoAsync(page, pageSize, filter);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<EgresoProyectadoResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _appService.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }
    }

    public class EgresoProyectadoAiImportUploadFormRequest
    {
        public int? FkidAnioSis { get; set; }
        public int? Anio { get; set; }
        public DateTime? Fecha { get; set; }
        public IFormFile? File { get; set; }
    }
}
