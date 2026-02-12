using AutoMapper;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCore.Controllers.Profile
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class EmpresaController : ControllerBase
    {
        private readonly GenericService<Empresa, EmpresaDto, EmpresaResponse> _service;
        private readonly GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> _serviceView;
        private readonly IMapper _mapper;

        public EmpresaController(
            GenericService<Empresa, EmpresaDto, EmpresaResponse> service,
            GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(e => e.EmpresaEstados);
            _service.AddRelationFilter("Empresa", new List<string> { "Nombre", "Rfc" });
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<EmpresaResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(new { success = true, Items = result, TotalCount = result.Count() });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EmpresaResponse>> GetById(int id)
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidEmpresa");

            if (result == null)
                return NotFound(new { success = false, message = "Empresa no encontrada" });

            return Ok(result);
        }

        [HttpPost]
        public async Task<ActionResult> Add(EmpresaResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<EmpresaDto>(viewDto);

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new
                    {
                        success = false,
                        message = "Ya existe una empresa activa con ese nombre",
                        code = "DUPLICATE_EMPRESA"
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidEmpresa },
                    new { success = true, message = "Empresa creada correctamente", data = viewDto });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = $"Error al crear empresa: {ex.Message}" });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, EmpresaResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<EmpresaDto>(viewDto);
                dto.PkidEmpresa = id;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new
                    {
                        success = false,
                        message = "Ya existe otra empresa activa con ese nombre",
                        code = "DUPLICATE_EMPRESA"
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new { success = true, message = "Empresa actualizada correctamente" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { success = false, message = $"Empresa con ID {id} no encontrada" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = $"Error al actualizar: {ex.Message}" });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new { success = true, message = "Empresa eliminada correctamente" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = $"Error al eliminar: {ex.Message}" });
            }
        }

        [HttpPost("GetAllEmpresasPaginado")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAllEmpresasPaginado(
            [FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            return Ok(await _serviceView.GetAllPaginadoAsync(_params));
        }
    }

    // Clases auxiliares para los endpoints específicos

}