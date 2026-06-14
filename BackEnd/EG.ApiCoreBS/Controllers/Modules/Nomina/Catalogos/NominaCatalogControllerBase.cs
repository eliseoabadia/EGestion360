using EG.Application.Interfaces.Nomina;
using EG.Common;
using EG.Common.Enums;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Modules.Nomina.Catalogos
{
    [ApiController]
    [Authorize]
    public abstract class NominaCatalogControllerBase<TResponse> : ControllerBase where TResponse : class
    {
        private readonly INominaCrudAppService<TResponse> _appService;
        private readonly IUserContextService _userContext;
        private readonly string _entityName;
        private readonly Logger.Log4NetLogger _logger;

        protected NominaCatalogControllerBase(
            INominaCrudAppService<TResponse> appService,
            IUserContextService userContext,
            string entityName)
        {
            _appService = appService;
            _userContext = userContext;
            _entityName = entityName;
            _logger = new Logger.Log4NetLogger(GetType());
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAll()
        {
            try
            {
                return Ok(await _appService.GetAllAsync());
            }
            catch (Exception ex)
            {
                LogException("obtener", ex);
                return BadRequest(Failure<TResponse>(UserFacingMessages.OperationFailed($"obtener {_entityName}")));
            }
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (!result.Success && result.Code == "NOT_FOUND")
            {
                return NotFound(result);
            }

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<TResponse>>> Create([FromBody] TResponse response)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.CreateAsync(response, usuarioActual);
                return result.Success ? Ok(result) : BadRequest(result);
            }
            catch (Exception ex)
            {
                LogException("crear", ex);
                return BadRequest(Failure<TResponse>(UserFacingMessages.OperationFailed($"crear {_entityName}")));
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<TResponse>>> Update(int id, [FromBody] TResponse response)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.UpdateAsync(id, response, usuarioActual);
                if (!result.Success && result.Code == "NOT_FOUND")
                {
                    return NotFound(result);
                }

                return result.Success ? Ok(result) : BadRequest(result);
            }
            catch (Exception ex)
            {
                LogException("actualizar", ex);
                return BadRequest(Failure<TResponse>(UserFacingMessages.OperationFailed($"actualizar {_entityName}")));
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<bool>>> Delete(int id)
        {
            try
            {
                var usuarioActual = _userContext.GetCurrentUserId();
                var result = await _appService.DeleteAsync(id, usuarioActual);
                if (!result.Success && result.Code == "NOT_FOUND")
                {
                    return NotFound(result);
                }

                return result.Success ? Ok(result) : BadRequest(result);
            }
            catch (Exception ex)
            {
                LogException("eliminar", ex);
                return BadRequest(new PagedResult<bool>
                {
                    Success = false,
                    Message = UserFacingMessages.OperationFailed($"eliminar {_entityName}"),
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<TResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            try
            {
                return Ok(await _appService.GetAllPaginadoAsync(request));
            }
            catch (Exception ex)
            {
                LogException("obtener paginado", ex);
                return BadRequest(Failure<TResponse>(UserFacingMessages.OperationFailed($"obtener {_entityName}")));
            }
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<TResponse>>> Buscar([FromBody] BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            return await GetAllPaginado(pagedRequest);
        }

        private PagedResult<TResult> Failure<TResult>(string message) => new()
        {
            Success = false,
            Message = message,
            Code = "ERROR",
            TotalCount = 0
        };

        private void LogException(string operation, Exception ex)
        {
            _logger.LogMessage(
                LogLevelGRP.Error,
                $"Error al {operation} {_entityName}: {ex}",
                (byte)SystemLogTypes.Error,
                GetType().Name,
                string.Empty,
                string.Empty);
        }
    }
}