using AutoMapper;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.RazorPages;
using Microsoft.EntityFrameworkCore;

namespace EG.ApiCore.Controllers.Profile
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class DepartamentoController : ControllerBase
    {
        private readonly GenericService<Departamento, DepartamentoDto, DepartamentoResponse> _service;
        private readonly GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> _serviceView;
        private readonly IMapper _mapper;

        public DepartamentoController(
            GenericService<Departamento, DepartamentoDto, DepartamentoResponse> service,
            GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;

            ConfigureService();
        }

        private void ConfigureService()
        {
            // ❌ INCORRECTO - Estás incluyendo el FK, no la navegación
            // _service.AddInclude(d => d.FkidEmpresaSis);

            // ✅ CORRECTO - Incluye la propiedad de navegación completa
            _service.AddInclude(d => d.FkidEmpresaSisNavigation); // Ajusta el nombre real de la propiedad

            // O si la propiedad de navegación se llama "Empresa"
            _service.AddInclude(d => d.FkidEmpresaSisNavigation);

            // Configurar propiedades de Empresa para búsqueda
            _service.AddRelationFilter("Empresa", new List<string> { "Nombre", "Rfc" }); // Usa el mismo nombre
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Validar nombre único por empresa para CREACIÓN
            _service.AddValidationRule("UniqueDepartmentPerCompany", async (dto) =>
            {
                var deptoDto = dto as DepartamentoDto;
                if (deptoDto == null) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(d => d.FkidEmpresaSis == deptoDto.FkidEmpresaSis &&
                             d.Nombre.ToLower() == deptoDto.Nombre.ToLower() &&
                             d.Activo);

                return !exists;
            });

            // REGLA 2: Validar nombre único por empresa para ACTUALIZACIÓN (excluyendo el actual)
            _service.AddValidationRuleWithId("UniqueDepartmentPerCompanyUpdate", async (dto, id) =>
            {
                var deptoDto = dto as DepartamentoDto;
                if (deptoDto == null || !id.HasValue) return true;

                var exists = _service.GetQueryWithIncludes()
                    .Any(d => d.FkidEmpresaSis == deptoDto.FkidEmpresaSis &&
                             d.Nombre.ToLower() == deptoDto.Nombre.ToLower() &&
                             d.PkidDepartamento != id.Value &&
                             d.Activo);

                return !exists;
            });

            // REGLA 3: Validar que el nombre no esté vacío y tenga al menos 3 caracteres
            _service.AddValidationRule("ValidNameLength", async (dto) =>
            {
                var deptoDto = dto as DepartamentoDto;
                return !string.IsNullOrWhiteSpace(deptoDto?.Nombre) && deptoDto.Nombre.Length >= 3;
            });

            // REGLA 4: Validar que la empresa sea válida
            _service.AddValidationRule("ValidCompany", async (dto) =>
            {
                var deptoDto = dto as DepartamentoDto;
                return deptoDto?.FkidEmpresaSis > 0;
            });
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(new { success = true, Items = result, TotalCount = result.Count() });
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetById(int id)
        {
            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidDepartamento");

            if (result == null)
                return NotFound(new { success = false, message = "Departamento no encontrado" });

            return Ok(new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Data = result, // objeto único
                Items = new List<DepartamentoResponse> { result }, // colección con un solo elemento
                TotalCount = 1
            });
        }

        [HttpGet("empresa/{empresaId}")]
        public async Task<ActionResult<IEnumerable<DepartamentoResponse>>> GetByEmpresaId(int empresaId)
        {
            var result = await _service.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 },
                d => d.FkidEmpresaSis == empresaId);

            return Ok(new { success = true, Items = result.Items, TotalCount = result.TotalCount });
        }

        [HttpPost]
        public async Task<ActionResult> Add(VwEmpresaDepartamanto viewDto)
        {
            try
            {
                var dto = _mapper.Map<DepartamentoDto>(viewDto);

                // ============ VALIDAR ANTES DE AGREGAR ============
                if (!await _service.CanAddAsync(dto))
                {
                    return Conflict(new
                    {
                        success = false,
                        message = "Ya existe un departamento activo con ese nombre en esta empresa",
                        code = "DUPLICATE_DEPARTMENT"
                    });
                }

                await _service.AddAsync(dto);

                return CreatedAtAction(nameof(GetById), new { id = dto.PkidDepartamento },
                    new { success = true, message = "Departamento creado correctamente", data = viewDto });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = $"Error al crear departamento: {ex.Message}" });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, VwEmpresaDepartamanto viewDto)
        {
            try
            {
                var dto = _mapper.Map<DepartamentoDto>(viewDto);
                dto.PkidDepartamento = id; // Asegurar que el ID sea correcto

                // ============ VALIDAR ANTES DE ACTUALIZAR ============
                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return Conflict(new
                    {
                        success = false,
                        message = "Ya existe otro departamento activo con ese nombre en esta empresa",
                        code = "DUPLICATE_DEPARTMENT"
                    });
                }

                await _service.UpdateAsync(id, dto);

                return Ok(new { success = true, message = "Departamento actualizado correctamente" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { success = false, message = $"Departamento con ID {id} no encontrado" });
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
                return Ok(new { success = true, message = "Departamento eliminado correctamente" });
            }
            catch (KeyNotFoundException)
            {
                return NotFound(new { success = false, message = $"Departamento con ID {id} no encontrado" });
            }
            catch (Exception ex)
            {
                return BadRequest(new { success = false, message = $"Error al eliminar: {ex.Message}" });
            }
        }

        [HttpPost("GetAllDepartamentosPaginado")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetAllDepartamentosPaginado(
            [FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService(); // Esto también reconfigura las validaciones

            var result = await _serviceView.GetAllPaginadoAsync(_params);
            return Ok(new { success = true, Items = result.Items, TotalCount = result.TotalCount });
        }

        [HttpPost("GetAllDepartamentosPaginadoPorEmpresa/{empresaId}")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> GetAllDepartamentosPaginadoPorEmpresa(
            int empresaId,
            [FromBody] PagedRequest _params)
        {
            _service.ClearConfiguration();
            ConfigureService();

            var result = await _service.GetAllPaginadoAsync(
                _params,
                d => d.FkidEmpresaSis == empresaId);

            return Ok(new { success = true, Items = result.Items, TotalCount = result.TotalCount });
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<DepartamentoResponse>>> BuscarDepartamentos(
            [FromBody] BusquedaRequest request)
        {
            _service.ClearConfiguration();
            ConfigureService();

            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _service.GetAllPaginadoAsync(pagedRequest);
            return Ok(new { success = true, Items = result.Items, TotalCount = result.TotalCount });
        }

        // Método adicional para validación manual (útil para frontend)
        [HttpPost("validar")]
        public async Task<ActionResult> ValidarDepartamento([FromBody] VwEmpresaDepartamanto viewDto)
        {
            var dto = _mapper.Map<DepartamentoDto>(viewDto);

            var isValid = await _service.CanAddAsync(dto);

            if (!isValid)
            {
                return Ok(new
                {
                    isValid = false,
                    message = "Ya existe un departamento activo con ese nombre en esta empresa"
                });
            }

            return Ok(new { isValid = true, message = "El nombre está disponible" });
        }
    }
}