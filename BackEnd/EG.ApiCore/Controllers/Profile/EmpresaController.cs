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

        public EmpresaController(
            GenericService<Empresa, EmpresaDto, EmpresaResponse> service,
            GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> serviceView)
        {
            _service = service;
            _serviceView = serviceView;

            // Configurar includes y filtros para Empresa
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(d => d.EmpresaEstados);

            // Configurar propiedades de Empresa para búsqueda
            //_service.AddRelationFilter("FkidEmpresaSis", new List<string> { "Nombre", "Rfc" });
        }

        [HttpGet]
        public async Task<ActionResult<IEnumerable<EmpresaResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<EmpresaResponse>> GetById(int id)
        {
            var result = await _service.GetByIdAsync(id, query =>
                query.Include(d => d.EmpresaEstados)  // Incluir empresa
                     .Where(d => d.Activo == true));            // Solo activos

            return result == null ? NotFound() : Ok(result);
        }

        [HttpGet("activas")]
        public async Task<ActionResult<IEnumerable<EmpresaResponse>>> GetEmpresasActivas()
        {
            var result = await _service.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 },
                e => true);

            return Ok(result.Items);
        }

        [HttpPost]
        public async Task<ActionResult> Add(EmpresaDto dto)
        {
            await _service.AddAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = dto.PkidEmpresa }, dto);
        }

        [HttpPut("{id}")]
        public async Task<ActionResult> Update(int id, EmpresaDto dto)
        {
            await _service.UpdateAsync(id, dto);
            return NoContent();
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult> Delete(int id)
        {
            await _service.DeleteAsync(id);
            return NoContent();
        }

        [HttpPost("GetAllEmpresasPaginado")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> GetAllEmpresasPaginado(
            [FromBody] PagedRequest _params)
        {
            // Reiniciar configuración para cada llamada
            _serviceView.ClearConfiguration();
            ConfigureService();

            return Ok(await _serviceView.GetAllPaginadoAsync(_params));
        }

        [HttpPost("buscar")]
        public async Task<ActionResult<PagedResult<EmpresaResponse>>> BuscarEmpresas(
            [FromBody] BusquedaRequest request)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            return Ok(await _serviceView.GetAllPaginadoAsync(pagedRequest));
        }

        //[HttpPost("ToggleEstado/{id}")]
        //public async Task<ActionResult<bool>> ToggleEstado(int id)
        //{
        //    var empresa = await _service.GetByIdAsync(id);
        //    if (empresa == null)
        //        return NotFound();

        //    // Obtener la entidad completa para actualizar
        //    var empresaEntity = await _service.GetEntityByIdAsync(id);
        //    if (empresaEntity == null)
        //        return NotFound();

        //    // Cambiar el estado
        //    empresaEntity.Activo = !empresaEntity.Activo;

        //    // Actualizar fecha de modificación
        //    empresaEntity.FechaModificacion = DateTime.Now;
        //    // Nota: Aquí deberías obtener el usuario actual del contexto
        //    // empresaEntity.UsuarioModificacion = usuarioIdActual;

        //    await _service.UpdateEntityAsync(empresaEntity);

        //    return Ok(empresaEntity.Activo);
        //}

        //[HttpPut("UpdateEstado/{id}")]
        //public async Task<ActionResult> UpdateEstado(int id, [FromBody] EstadoRequest estadoRequest)
        //{
        //    var empresa = await _service.GetEntityByIdAsync(id);
        //    if (empresa == null)
        //        return NotFound();

        //    empresa.Activo = estadoRequest.Estado == "Activo";
        //    empresa.FechaModificacion = DateTime.Now;
        //    // empresaEntity.UsuarioModificacion = usuarioIdActual;

        //    await _service.UpdateEntityAsync(empresa);

        //    return NoContent();
        //}

        //[HttpGet("PorEstado/{estadoId}")]
        //public async Task<ActionResult<IEnumerable<EmpresaResponse>>> GetEmpresasPorEstado(int estadoId)
        //{
        //    _service.ClearConfiguration();
        //    ConfigureService();

        //    var result = await _service.GetAllPaginadoAsync(
        //        new PagedRequest { Page = 1, PageSize = 1000 },
        //        e => e.EmpresaEstados.Any(ee => ee.FkidEstado == estadoId));

        //    return Ok(result.Items);
        //}

        //[HttpGet("ConEstados")]
        //public async Task<ActionResult<IEnumerable<EmpresaConEstadosResponse>>> GetEmpresasConEstados()
        //{
        //    // Este endpoint devuelve empresas con sus estados relacionados
        //    _service.ClearConfiguration();

        //    // Incluir la relación con Estados
        //    _service.AddInclude(e => e.EmpresaEstados);
        //    _service.AddInclude(e => e.EmpresaEstados.Select(ee => ee.FkidEstadoNavigation));

        //    var empresas = await _service.GetAllAsync();

        //    // Mapear manualmente o crear un DTO específico
        //    var resultado = empresas.Select(e => new EmpresaConEstadosResponse
        //    {
        //        PkidEmpresa = e.PkidEmpresa,
        //        Nombre = e.EmpresaNombre,
        //        Rfc = e.Rfc,
        //        Activo = e.EmpresaActivo,
        //        Estados = e.EmpresaEstados?.Select(ee => new EstadoInfoResponse
        //        {
        //            PkidEstado = ee.FkidEstado,
        //            Nombre = ee.FkidEstadoNavigation?.Nombre
        //        }).ToList() ?? new List<EstadoInfoResponse>()
        //    });

        //    return Ok(resultado);
        //}
    }

    // Clases auxiliares para los endpoints específicos

}