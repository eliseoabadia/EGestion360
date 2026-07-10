using EG.Application.Interfaces.Contabilidad;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Contabilidad
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class PolizaController : ControllerBase
    {
        private const long MaxAiImportFileSize = 50L * 1024L * 1024L;
        private readonly IPolizaService _service;
        private readonly IUserContextService _userContext;

        public PolizaController(IPolizaService service, IUserContextService userContext)
        {
            _service = service;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> Create([FromBody] PolizaResponse response)
        {
            var result = await _service.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return CreatedAtAction(nameof(GetById), new { id = response.PkidPoliza }, result);
        }

        [HttpPost("ai-import/preview")]
        [RequestSizeLimit(MaxAiImportFileSize)]
        public async Task<ActionResult<PagedResult<PolizaAiImportPreviewResponse>>> PreviewAiImport([FromForm] PolizaAiImportUploadFormRequest request)
        {
            if (request.File == null || request.File.Length == 0)
            {
                return BadRequest(new PagedResult<PolizaAiImportPreviewResponse>
                {
                    Success = false,
                    Message = "El archivo es requerido.",
                    Code = "INVALID_FILE"
                });
            }

            if (request.File.Length > MaxAiImportFileSize)
            {
                return BadRequest(new PagedResult<PolizaAiImportPreviewResponse>
                {
                    Success = false,
                    Message = "El archivo supera el limite de 50 MB.",
                    Code = "FILE_TOO_LARGE"
                });
            }

            await using var stream = request.File.OpenReadStream();
            using var memory = new MemoryStream();
            await stream.CopyToAsync(memory);

            var empresaContexto = _userContext.TryGetCurrentEmpresaId();

            var header = new PolizaAiImportHeaderRequest
            {
                FkidEmpresaSis = empresaContexto ?? request.FkidEmpresaSis,
                FkidAnioSis = request.FkidAnioSis,
                Anio = request.Anio,
                FkidMesSis = request.FkidMesSis,
                Mes = request.Mes,
                FkidTipoPolizaSis = request.FkidTipoPolizaSis,
                TipoPoliza = request.TipoPoliza,
                ClavePoliza = request.ClavePoliza,
                NombrePoliza = request.NombrePoliza,
                FechaPoliza = request.FechaPoliza,
                PermitirModificar = request.PermitirModificar,
                Autorizado = request.Autorizado
            };

            var dto = new PolizaAiImportUploadRequest
            {
                NombreOriginal = request.File.FileName,
                TipoMime = string.IsNullOrWhiteSpace(request.File.ContentType)
                    ? "application/octet-stream"
                    : request.File.ContentType,
                TamanoBytes = request.File.Length,
                Contenido = memory.ToArray(),
                HeaderFallback = header
            };

            var result = await _service.PreviewAiImportAsync(dto, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("ai-import/confirm")]
        public async Task<ActionResult<PagedResult<PolizaAiImportPreviewResponse>>> ConfirmAiImport([FromBody] PolizaAiImportConfirmRequest request)
        {
            request.Header.FkidEmpresaSis = _userContext.TryGetCurrentEmpresaId() ?? request.Header.FkidEmpresaSis;
            var result = await _service.ConfirmAiImportAsync(request, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> Update(int id, [FromBody] PolizaResponse response)
        {
            var result = await _service.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
            }

            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _service.DeleteAsync(id, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
            }

            return Ok(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<PolizaResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _service.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }
    }

    public class PolizaAiImportUploadFormRequest
    {
        public int? FkidEmpresaSis { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? Anio { get; set; }
        public int? FkidMesSis { get; set; }
        public string? Mes { get; set; }
        public int? FkidTipoPolizaSis { get; set; }
        public string? TipoPoliza { get; set; }
        public string? ClavePoliza { get; set; }
        public string? NombrePoliza { get; set; }
        public DateTime? FechaPoliza { get; set; }
        public bool PermitirModificar { get; set; } = true;
        public bool Autorizado { get; set; }
        public IFormFile? File { get; set; }
    }
}
