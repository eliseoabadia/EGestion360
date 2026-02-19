using AutoMapper;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class AspNetRolesController : ControllerBase
    {
        private readonly GenericService<AspNetRole, AspNetRoleDto, AspNetRoleResponse> _service;
        private readonly IMapper _mapper;

        public AspNetRolesController(
            GenericService<AspNetRole, AspNetRoleDto, AspNetRoleResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<AspNetRoleResponse>>> GetAll()
        {
            var result = await _service.GetAllAsync();
            return Ok(new PagedResult<AspNetRoleResponse>
            {
                Success = true,
                Message = "AspNetRole obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<AspNetRoleResponse>>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "Id");
            if (result == null)
                return NotFound(new PagedResult<AspNetRoleResponse>
                {
                    Success = false,
                    Message = "AspNetRole no encontrada",
                    Code = "NOTFOUND_ASPNETROLE",
                    TotalCount = 0
                });

            return Ok(new PagedResult<AspNetRoleResponse>
            {
                Success = true,
                Message = "AspNetRole encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<AspNetRoleResponse> { result },
                TotalCount = 1
            });
        }

        [HttpPost]
        public async Task<ActionResult> Create([FromBody] AspNetRoleDto AspNetRoleDto)
        {
            await _service.AddAsync(AspNetRoleDto);
            return Ok();
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, [FromBody] AspNetRoleDto AspNetRoleDto)
        {
            await _service.UpdateAsync(id, AspNetRoleDto);
            return Ok();
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return Ok();
        }
    }
}