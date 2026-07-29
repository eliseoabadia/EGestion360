using EG.Application.Interfaces.Patrimonio;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCoreBS.Controllers.Patrimonio
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class BienController : ControllerBase
    {
        private readonly IBienAppService _appService;
        private readonly IUserContextService _userContext;
        private readonly EGestionContext _context;
        private readonly IAuthorizationService _authorization;

        public BienController(
            IBienAppService appService,
            IUserContextService userContext,
            EGestionContext context,
            IAuthorizationService authorization)
        {
            _appService = appService;
            _userContext = userContext;
            _context = context;
            _authorization = authorization;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            return result.Success ? Ok(result) : NotFound(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<BienResponse>>> Create([FromBody] BienResponse response)
        {
            var result = await _appService.CreateAsync(response, _userContext.GetCurrentUserId());
            if (!result.Success)
            {
                return BadRequest(result);
            }

            var id = result.Data?.PkidBien ?? response.PkidBien;
            return CreatedAtAction(nameof(GetById), new { id }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> Update(int id, [FromBody] BienResponse response)
        {
            var result = await _appService.UpdateAsync(id, response, _userContext.GetCurrentUserId());
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            var result = await _appService.DeleteAsync(id);
            if (result.Success)
            {
                return Ok(result);
            }

            return result.Code == "NOT_FOUND" ? NotFound(result) : BadRequest(result);
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _appService.GetAllPaginadoAsync(request);
            return Ok(result);
        }

        [HttpPost("generar-desde-detalle/{detalleOrdenCompraId:int}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> GenerarDesdeDetalle(int detalleOrdenCompraId)
        {
            if (!await CanOperateClassificationAsync()) return Forbid();
            var result = await _appService.GenerarDesdeDetalleOrdenCompraAsync(
                detalleOrdenCompraId,
                _userContext.GetCurrentUserId());

            return result.Success ? Ok(result) : BadRequest(result);
        }

        [HttpPost("registrar-recepcion/{detalleOrdenCompraId:int}")]
        public async Task<ActionResult<PagedResult<BienResponse>>> RegistrarRecepcion(
            int detalleOrdenCompraId,
            [FromBody] RecepcionDetalleOrdenCompraRequest request)
        {
            if (!await CanOperateClassificationAsync()) return Forbid();
            var result = await _appService.RegistrarRecepcionAsync(
                detalleOrdenCompraId,
                request.CantidadRecibida,
                _userContext.GetCurrentUserId());

            return result.Success ? Ok(result) : BadRequest(result);
        }

        private async Task<bool> CanOperateClassificationAsync() =>
            (await _authorization.AuthorizeAsync(
                User,
                null,
                "Patrimonio|Clasificacion_Bienes_Muebles|update")).Succeeded;

        [HttpPost("tipos-bien-capitulo-5000")]
        public async Task<ActionResult<PagedResult<LookupItem>>> GetTiposBienCapitulo5000([FromBody] PagedRequest request)
        {
            var query = _context.TipoBiens.AsNoTracking().Where(x => x.Activo &&
                x.FkidPartidaContaNavigation.Activo && x.FkidPartidaContaNavigation.Clave.StartsWith("5"));
            if (!string.IsNullOrWhiteSpace(request.Filtro))
            {
                var filter = request.Filtro.Trim();
                query = query.Where(x => x.CodigoClave.Contains(filter) || x.Descripcion.Contains(filter));
            }
            var page = Math.Max(1, request.Page);
            var pageSize = request.PageSize <= 0 ? 25 : request.PageSize;
            var total = await query.CountAsync();
            var items = await query.OrderBy(x => x.CodigoClave).Skip((page - 1) * pageSize).Take(pageSize)
                .Select(x => new LookupItem { Id = x.PkidTipoBien, Text = x.CodigoClave + " - " + x.Descripcion }).ToListAsync();
            return Ok(new PagedResult<LookupItem> { Success = true, Code = "SUCCESS", Message = "Tipos patrimoniales", Items = items, TotalCount = total });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<BienResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SearchString = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _appService.GetAllPaginadoAsync(pagedRequest);
            return Ok(result);
        }
    }
}
