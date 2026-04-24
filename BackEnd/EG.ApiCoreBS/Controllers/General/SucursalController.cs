using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace EG.ApiCoreBS.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class SucursalController : ControllerBase
    {
        private readonly ISucursalAppService _appService;

        public SucursalController(ISucursalAppService appService)
        {
            _appService = appService;
        }

        [HttpGet]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> GetAll()
        {
            var result = await _appService.GetAllAsync();
            return Ok(result);
        }

        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> GetById(int id)
        {
            var result = await _appService.GetByIdAsync(id);
            if (result == null)
                return NotFound(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = "Sucursal no encontrada",
                    Code = "NOTFOUND_SUCURSAL",
                    TotalCount = 0
                });

            return Ok(new PagedResult<SucursalResponse>
            {
                Success = true,
                Message = "Sucursal encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<SucursalResponse> { result },
                TotalCount = 1
            });
        }

        [HttpGet("empresa/{empresaId}")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> GetByEmpresaId(int empresaId)
        {
            var result = await _appService.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 });

            return Ok(new PagedResult<SucursalResponse>
            {
                Success = true,
                Message = "Sucursales por empresa obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }

        [HttpPost]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> Create([FromBody] SucursalResponse response)
        {
            try
            {
                var dto = new SucursalDto
                {
                    FkidEmpresaSis = response.FkidEmpresaSis,
                    FkidEstadoSis = response.FkidEstadoSis,
                    Nombre = response.Nombre,
                    CodigoSucursal = response.CodigoSucursal,
                    Alias = response.Alias,
                    FkidTipoSucursal = response.FkidTipoSucursal,
                    FkidMonedaLocalSis = response.FkidMonedaLocalSis,
                    Direccion = response.Direccion,
                    Colonia = response.Colonia,
                    Ciudad = response.Ciudad,
                    CodigoPostal = response.CodigoPostal,
                    TelefonoPrincipal = response.TelefonoPrincipal,
                    TelefonoSecundario = response.TelefonoSecundario,
                    Email = response.Email,
                    HorarioApertura = response.HorarioApertura,
                    HorarioCierre = response.HorarioCierre,
                    EsMatriz = response.EsMatriz,
                    EsActiva = response.EsActiva,
                    Latitud = response.Latitud,
                    Longitud = response.Longitud,
                    Activo = response.Activo
                };
                var result = await _appService.CreateAsync(dto, response.UsuarioCreacion);
                return CreatedAtAction(nameof(GetById), new { id = result.PkidSucursal },
                    new PagedResult<SucursalResponse>
                    {
                        Success = true,
                        Message = "Sucursal creada correctamente",
                        Code = "SUCCESS",
                        TotalCount = 1
                    });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = $"Error al crear sucursal: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> Update(int id, [FromBody] SucursalResponse response)
        {
            try
            {
                var dto = new SucursalDto
                {
                    FkidEmpresaSis = response.FkidEmpresaSis,
                    FkidEstadoSis = response.FkidEstadoSis,
                    Nombre = response.Nombre,
                    CodigoSucursal = response.CodigoSucursal,
                    Alias = response.Alias,
                    FkidTipoSucursal = response.FkidTipoSucursal,
                    FkidMonedaLocalSis = response.FkidMonedaLocalSis,
                    Direccion = response.Direccion,
                    Colonia = response.Colonia,
                    Ciudad = response.Ciudad,
                    CodigoPostal = response.CodigoPostal,
                    TelefonoPrincipal = response.TelefonoPrincipal,
                    TelefonoSecundario = response.TelefonoSecundario,
                    Email = response.Email,
                    HorarioApertura = response.HorarioApertura,
                    HorarioCierre = response.HorarioCierre,
                    EsMatriz = response.EsMatriz,
                    EsActiva = response.EsActiva,
                    Latitud = response.Latitud,
                    Longitud = response.Longitud,
                    Activo = response.Activo
                };
                await _appService.UpdateAsync(id, dto, response.UsuarioModificacion ?? 0);
                return Ok(new PagedResult<SucursalResponse>
                {
                    Success = true,
                    Message = "Sucursal actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        [HttpDelete("{id}")]
        public async Task<ActionResult<PagedResult<SucursalResponse>>> Delete(int id)
        {
            try
            {
                await _appService.DeleteAsync(id);
                return Ok(new PagedResult<SucursalResponse>
                {
                    Success = true,
                    Message = "Sucursal eliminada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<SucursalResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }
    }
}