using EG.ApiCoreBS.Services;
using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EmpresaController : ControllerBase
    {
        private readonly IEmpresaAppService _appService;
        private readonly IUserContextService _userContext;

        public EmpresaController(
            IEmpresaAppService appService,
            IUserContextService userContext)
        {
            _appService = appService;
            _userContext = userContext;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = "Empresa no encontrada",
                    Code = "NOTFOUND_COMPANY",
                    TotalCount = 0
                });

            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresa encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<EmpresaResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Create([FromBody] EmpresaDto dto)
        {
            var usuarioActual = _userContext.GetCurrentUserId();
            var result = await _appService.CreateAsync(dto, usuarioActual);
            return CreatedAtAction(nameof(GetById), new { id = result.PkidEmpresa }, result);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Update(int id, [FromBody] EmpresaDto dto)
        {
            var usuarioActual = _userContext.GetCurrentUserId();
            var result = await _appService.UpdateAsync(id, dto, usuarioActual);
            return Ok(result);
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Delete(int id)
        {
            var usuarioActual = _userContext.GetCurrentUserId();
            await _appService.DeleteAsync(id, usuarioActual);
            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresa eliminada correctamente",
                Code = "SUCCESS",
                TotalCount = 0
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            var result = await _appService.GetAllPaginadoAsync(_params);
            return Ok(result);
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> BuscarEmpresas([FromBody] BusquedaRequest request)
        {
            var result = await _appService.BuscarAsync(request);
            return Ok(result);
        }
    }
}
