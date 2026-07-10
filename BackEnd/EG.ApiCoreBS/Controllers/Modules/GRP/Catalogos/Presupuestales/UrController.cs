using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.Catalogos.Presupuestales
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UrController : ControllerBase
    {
        private readonly GenericService<Ur, UrDto, UrResponse> _service;

        public UrController(GenericService<Ur, UrDto, UrResponse> service)
        {
            _service = service;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<UrResponse>>> GetAll()
        {
            var items = (await _service.GetAllAsync()).ToList();
            return Ok(new PagedResult<UrResponse>
            {
                Success = true,
                Message = "UR obtenidas correctamente",
                Code = "SUCCESS",
                Items = items,
                TotalCount = items.Count
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<UrResponse>>> GetById(int id)
        {
            var item = await _service.GetByIdAsync(id);
            if (item == null)
            {
                return NotFound(new PagedResult<UrResponse>
                {
                    Success = false,
                    Message = "UR no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                });
            }

            return Ok(new PagedResult<UrResponse>
            {
                Success = true,
                Message = "UR encontrada",
                Code = "SUCCESS",
                Data = item,
                Items = new List<UrResponse> { item },
                TotalCount = 1
            });
        }

        [HttpPost("GetAllPaginado")]
        public async Task<ActionResult<PagedResult<UrResponse>>> GetAllPaginado([FromBody] PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return Ok(result);
        }
    }
}
