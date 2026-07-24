using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Planeacion
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EstudioMercadoDetalleController : ControllerBase
    {
        private readonly IEstudioMercadoDetalleService _service;
        private readonly IUserContextService _userContext;

        public EstudioMercadoDetalleController(IEstudioMercadoDetalleService service, IUserContextService userContext)
        {
            _service = service;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EstudioMercadoDetalleResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EstudioMercadoDetalleResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EstudioMercadoDetalleResponse>>> Create([FromBody] EstudioMercadoDetalleResponse response)
        {
            var result = await _service.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            return CreatedAtAction(nameof(GetById), new { id = response.PkidEstudioMercadoDetalle }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EstudioMercadoDetalleResponse>>> Update(int id, [FromBody] EstudioMercadoDetalleResponse response)
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
        public async Task<ActionResult<PagedResult<EstudioMercadoDetalleResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<EstudioMercadoDetalleResponse>>> Buscar([FromBody] BusquedaRequest request)
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

        [HttpPost("paaas-detalles-lookup")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetPaaasDetallesLookup([FromBody] PagedRequest request)
        {
            var result = await _service.GetPaaasDetallesLookupAsync(request);
            return Ok(result);
        }

        [HttpPost("paaas-lookup")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetPaaasLookup([FromBody] PagedRequest request)
        {
            var result = await _service.GetPaaasLookupAsync(request);
            return Ok(result);
        }

        [HttpPost("paaas-detalles")]
        public async Task<ActionResult<PagedResult<EstudioMercadoPaaasDetalleResponse>>> GetPaaasDetalles([FromBody] PagedRequest request)
        {
            var result = await _service.GetPaaasDetallesAsync(request);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpGet("paaas-detalle/{paaasDetalleId}")]
        public async Task<ActionResult<PagedResult<EstudioMercadoDetalleSeedResponse>>> GetPaaasDetalleSeed(int paaasDetalleId)
        {
            var result = await _service.GetPaaasDetalleSeedAsync(paaasDetalleId);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost("batch")]
        public async Task<ActionResult<PagedResult<EstudioMercadoDetalleResponse>>> CreateBatch([FromBody] EstudioMercadoDetalleBatchRequest request)
        {
            var result = await _service.CreateBatchAsync(request, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("cotizaciones/solicitar")]
        public async Task<ActionResult<PagedResult<EstudioMercadoCotizacionSolicitudResponse>>> CreateSolicitudesCotizacion([FromBody] EstudioMercadoCotizacionRequest request)
        {
            var result = await _service.CreateSolicitudesCotizacionAsync(request, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpGet("cotizaciones/solicitudes/{estudioMercadoId}")]
        public async Task<ActionResult<PagedResult<EstudioMercadoCotizacionSolicitudResponse>>> GetSolicitudesCotizacion(int estudioMercadoId)
        {
            var result = await _service.GetSolicitudesCotizacionAsync(estudioMercadoId);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("cotizaciones/solicitudes/{estudioMercadoId}/enviar-correo")]
        public async Task<ActionResult<PagedResult<EstudioMercadoCotizacionSolicitudResponse>>> SendSolicitudesCotizacionEmail(int estudioMercadoId, [FromQuery] int? estudioMercadoDetalleId)
        {
            var result = await _service.SendSolicitudesCotizacionEmailAsync(
                estudioMercadoId,
                estudioMercadoDetalleId,
                _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("cotizaciones/solicitudes/{estudioMercadoId}/rechazar-envio")]
        public async Task<ActionResult<PagedResult<EstudioMercadoCotizacionSolicitudResponse>>> RejectSolicitudesCotizacionEmail(
            int estudioMercadoId,
            [FromQuery] int? estudioMercadoDetalleId,
            [FromBody] string? motivo = null)
        {
            var result = await _service.RejectSolicitudesCotizacionEmailAsync(
                estudioMercadoId,
                estudioMercadoDetalleId,
                _userContext.GetCurrentUserId(),
                motivo);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpGet("cotizaciones/recepcion/{estudioMercadoId}")]
        public async Task<ActionResult<PagedResult<EstudioMercadoCotizacionRecepcionResponse>>> GetRecepcionCotizaciones(int estudioMercadoId, [FromQuery] int? proveedorId)
        {
            var result = await _service.GetRecepcionCotizacionesAsync(estudioMercadoId, proveedorId);
            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("cotizaciones/recepcion")]
        public async Task<ActionResult<PagedResult<EstudioMercadoCotizacionRecepcionResponse>>> SaveRecepcionCotizaciones([FromBody] EstudioMercadoCotizacionRecepcionRequest request)
        {
            var result = await _service.SaveRecepcionCotizacionesAsync(request, _userContext.GetCurrentUserId());
            return result.Success ? Ok(result) : BadRequest(result);
        }
    }
}
