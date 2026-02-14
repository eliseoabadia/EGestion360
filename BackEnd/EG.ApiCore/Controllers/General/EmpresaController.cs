using AutoMapper;
using EG.Application.CommonModel;
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
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetById(int id)
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidEmpresa");

            if (result == null)
                return NotFound(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = "Empresa no encontrada",
                    Code = "NOTFOUND_EMPRESA",
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
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Add([FromBody] EmpresaResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<EmpresaDto>(viewDto);

                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new PagedResult<EmpresaResponse>
                    {
                        Success = false,
                        Message = "Ya existe una empresa activa con ese nombre",
                        Code = "DUPLICATE_EMPRESA",
                        TotalCount = 0
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidEmpresa },
                    new PagedResult<EmpresaResponse>
                    {
                        Success = true,
                        Message = "Empresa creada correctamente",
                        Code = "SUCCESS",
                        Data = viewDto,
                        Items = new List<EmpresaResponse> { viewDto },
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = $"Error al crear empresa: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Update(int id, [FromBody] EmpresaResponse viewDto)
        {
            try
            {
                var dto = _mapper.Map<EmpresaDto>(viewDto);
                dto.PkidEmpresa = id;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new PagedResult<EmpresaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra empresa activa con ese nombre",
                        Code = "DUPLICATE_EMPRESA",
                        TotalCount = 0
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresa actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = $"Empresa con ID {id} no encontrada",
                    Code = "NOTFOUND_EMPRESA",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> Delete(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return Ok(new PagedResult<EmpresaResponse>
                {
                    Success = true,
                    Message = "Empresa eliminada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<EmpresaResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPost("GetAllEmpresasPaginado")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAllEmpresasPaginado([FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(_params);

            return Ok(new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        // Clases auxiliares para los endpoints específicos

    }
}