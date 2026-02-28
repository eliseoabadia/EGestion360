using AutoMapper;
using EG.ApiCore.Services;
using EG.Application.CommonModel;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Domain.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Data.SqlClient;


namespace EG.ApiCore.Controllers.General
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize]
    public class UsuarioSucursalController : ControllerBase
    {
        private readonly IUserContextService _userContext;
        private readonly IRepositorySP<spEliminarUsuarioSucursalResult> _repositorySP;
        private readonly GenericService<UsuarioSucursal, UsuarioSucursalDto, VwUsuarioSucursalResponse> _service;
        private readonly GenericService<VwUsuarioSucursal, UsuarioSucursalDto, VwUsuarioSucursalResponse> _serviceView;
        private readonly IMapper _mapper;

        public UsuarioSucursalController(
            GenericService<UsuarioSucursal, UsuarioSucursalDto, VwUsuarioSucursalResponse> service,
            GenericService<VwUsuarioSucursal, UsuarioSucursalDto, VwUsuarioSucursalResponse> serviceView,
            IRepositorySP<spEliminarUsuarioSucursalResult> repositorySP,
            IMapper mapper,
            IUserContextService userContext)
        {
            _service = service;
            _serviceView = serviceView;
            _repositorySP = repositorySP;
            _userContext = userContext;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(us => us.FkidUsuarioSisNavigation);
            _service.AddInclude(us => us.FkidSucursalSisNavigation);
            _service.AddRelationFilter("Usuario", new List<string> { "Nombre", "ApellidoPaterno", "Email" });
            _service.AddRelationFilter("Sucursal", new List<string> { "Nombre", "CodigoSucursal" });
        }

        /// <summary>
        /// Obtiene todas las asignaciones usuario-sucursal
        /// </summary>
        [HttpGet]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetAll()
        {
            var result = await _serviceView.GetAllAsync();
            return Ok(new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Asignaciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            });
        }

        /// <summary>
        /// Obtiene una asignación específica por ID
        /// </summary>
        [HttpGet("{id}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetById(int id)
        {
            var result = await _serviceView.GetByIdAsync(id);

            if (result == null)
                return NotFound(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = "Asignación no encontrada",
                    Code = "NOTFOUND_ASIGNACION",
                    TotalCount = 0
                });

            return Ok(new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Asignación encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<VwUsuarioSucursalResponse> { result },
                TotalCount = 1
            });
        }

        /// <summary>
        /// Obtiene una asignación específica por usuario y sucursal
        /// </summary>
        [HttpGet("usuario/{usuarioId}/sucursal/{sucursalId}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetByUsuarioAndSucursal(int usuarioId, int sucursalId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.FirstOrDefault(x => x.PkIdUsuario == usuarioId && x.IdSucursal == sucursalId);

            if (result == null)
                return NotFound(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = "Asignación no encontrada",
                    Code = "NOTFOUND_ASIGNACION",
                    TotalCount = 0
                });

            return Ok(new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Asignación encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<VwUsuarioSucursalResponse> { result },
                TotalCount = 1
            });
        }

        /// <summary>
        /// Obtiene todas las sucursales asignadas a un usuario
        /// </summary>
        [HttpGet("usuario/{usuarioId}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetByUsuario(int usuarioId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.Where(x => x.PkIdUsuario == usuarioId && x.AsignacionActiva.Value).ToList();

            return Ok(new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Sucursales del usuario obtenidas correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            });
        }

        /// <summary>
        /// Obtiene todos los usuarios asignados a una sucursal
        /// </summary>
        [HttpGet("sucursal/{sucursalId}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetBySucursal(int sucursalId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.Where(x => x.IdSucursal == sucursalId && x.AsignacionActiva.Value).ToList();

            return Ok(new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Usuarios de la sucursal obtenidos correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            });
        }

        /// <summary>
        /// Obtiene los gerentes de una sucursal
        /// </summary>
        [HttpGet("sucursal/{sucursalId}/gerentes")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetGerentesBySucursal(int sucursalId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.Where(x => x.IdSucursal == sucursalId && x.EsGerente.Value && x.AsignacionActiva.Value).ToList();

            return Ok(new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Gerentes de la sucursal obtenidos correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            });
        }

        /// <summary>
        /// Asigna un usuario a una sucursal
        /// </summary>
        [HttpPost]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> Add([FromBody] VwUsuarioSucursalResponse _dto)
        {
            try
            {
                var result = await _serviceView.GetByIdAsync(_dto.PkIdUsuario);

                // Mapear y preparar el DTO
                var dto = _mapper.Map<UsuarioSucursalDto>(result);
                // Verificar si ya existe la asignación
                //var existentes = await _service.GetAllAsync();
                //var existe = existentes.Any(x => x.PkIdUsuario == dto.FkidUsuarioSis &&
                //                                 x.IdSucursal == dto.FkidSucursalSis &&
                //                                 x.UsuarioActivo);

                //if (existe)
                //{
                //    return Conflict(new PagedResult<VwUsuarioSucursalResponse>
                //    {
                //        Success = false,
                //        Message = "El usuario ya está asignado a esta sucursal",
                //        Code = "DUPLICATE_ASIGNACION",
                //        TotalCount = 0
                //    });
                //}

                // Establecer valores por defecto
                dto.FkidSucursalSis = _dto.IdSucursal.Value;
                dto.FechaAsignacion = DateTime.Now;
                dto.Activo = true;

                await _service.AddAsync(dto);

                // Mapear y preparar el DTO
                var viewDto = _mapper.Map<VwUsuarioSucursalResponse>(dto);

                return Ok(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = true,
                    Message = "¡Usuario asignado correctamente a la sucursal!",
                    Code = "SUCCESS",
                    Data = viewDto,
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al asignar usuario: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Actualiza una asignación
        /// </summary>
        [HttpPut("{id}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> Update(int id, [FromBody] VwUsuarioSucursalResponse _dto)
        {
            try
            {
                // Mapear y preparar el DTO
                //var dto = _mapper.Map<UsuarioSucursalDto>(_dto);

                //await _service.UpdateAsync(id, dto);
                var parameters = new[]
                {
                    new SqlParameter("@FkidUsuarioSis", id),
                    new SqlParameter("@FkidSucursalSis", _dto.IdSucursal),
                    new SqlParameter("@UsuarioModificacion", _userContext.GetCurrentUserId())
                };
                var result = await _repositorySP.ExecuteStoredProcedureAsync<spEliminarUsuarioSucursalResult>("SIS.spEliminarUsuarioSucursal", parameters);

                // Mapear y preparar el DTO
                //var viewDto = _mapper.Map<VwUsuarioSucursalResponse>(dto);

                return Ok(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = true,
                    Message = "¡Se elimina la sucursal al suaurio!",
                    Code = "SUCCESS",
                    Data = _dto,
                    TotalCount = 1
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar asignación: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        /// <summary>
        /// Elimina una asignación (baja física)
        /// </summary>
        [HttpDelete("{usuarioId}/{sucursalId}")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> Delete(int usuarioId, int sucursalId)
        {
            try
            {
                var _resultListUserSuc = await _serviceView.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 },
                u => u.PkIdUsuario == usuarioId && u.IdSucursal == sucursalId);

                var _result = _resultListUserSuc.Items.FirstOrDefault();

                // Mapear y preparar el DTO
                var dto = _mapper.Map<UsuarioSucursalDto>(_result);

                if (dto == null)
                {
                    return NotFound(new PagedResult<VwUsuarioSucursalResponse>
                    {
                        Success = false,
                        Message = "Asignación no encontrada",
                        Code = "NOT_FOUND",
                        TotalCount = 0
                    });
                }

                var parameters = new[]
                {
                    new SqlParameter("@FkidUsuarioSis", usuarioId),
                    new SqlParameter("@FkidSucursalSis", sucursalId),
                    new SqlParameter("@UsuarioModificacion", _userContext.GetCurrentUserId())
                };
                var result = await _repositorySP.ExecuteStoredProcedureAsync<spEliminarUsuarioSucursalResult>("SIS.spEliminarUsuarioSucursal", parameters);

                return Ok(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = true,
                    Message = "Asignación eliminada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 0
                });
            }
            catch (Exception ex)
            {
                return BadRequest(new PagedResult<VwUsuarioSucursalResponse>
                {
                    Success = false,
                    Message = $"Error al eliminar asignación: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                });
            }
        }

        ///// <summary>
        ///// Desactiva una asignación (baja lógica)
        ///// </summary>
        //[HttpPatch("{id}/desactivar")]
        //public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> Desactivar(int id)
        //{
        //    try
        //    {
        //        var existente = await _service.GetByIdAsync(id);
        //        if (existente == null)
        //        {
        //            return NotFound(new PagedResult<VwUsuarioSucursalResponse>
        //            {
        //                Success = false,
        //                Message = "Asignación no encontrada",
        //                Code = "NOTFOUND_ASIGNACION",
        //                TotalCount = 0
        //            });
        //        }

        //        existente.UsuarioActivo = false;
        //        existente.Fecha = DateTime.Now;

        //        var result = await _service.UpdateAsync(id, existente);

        //        return Ok(new PagedResult<VwUsuarioSucursalResponse>
        //        {
        //            Success = true,
        //            Message = "Asignación desactivada correctamente",
        //            Code = "SUCCESS",
        //            Data = result,
        //            TotalCount = 1
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return BadRequest(new PagedResult<VwUsuarioSucursalResponse>
        //        {
        //            Success = false,
        //            Message = $"Error al desactivar asignación: {ex.Message}",
        //            Code = "ERROR",
        //            TotalCount = 0
        //        });
        //    }
        //}

        ///// <summary>
        ///// Reactiva una asignación previamente desactivada
        ///// </summary>
        //[HttpPatch("{id}/reactivar")]
        //public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> Reactivar(int id)
        //{
        //    try
        //    {
        //        var existente = await _service.GetByIdAsync(id);
        //        if (existente == null)
        //        {
        //            return NotFound(new PagedResult<VwUsuarioSucursalResponse>
        //            {
        //                Success = false,
        //                Message = "Asignación no encontrada",
        //                Code = "NOTFOUND_ASIGNACION",
        //                TotalCount = 0
        //            });
        //        }

        //        existente.Activo = true;
        //        existente.FechaFinAsignacion = null;

        //        var result = await _service.UpdateAsync(id, existente);

        //        return Ok(new PagedResult<VwUsuarioSucursalResponse>
        //        {
        //            Success = true,
        //            Message = "Asignación reactivada correctamente",
        //            Code = "SUCCESS",
        //            Data = result,
        //            TotalCount = 1
        //        });
        //    }
        //    catch (Exception ex)
        //    {
        //        return BadRequest(new PagedResult<VwUsuarioSucursalResponse>
        //        {
        //            Success = false,
        //            Message = $"Error al reactivar asignación: {ex.Message}",
        //            Code = "ERROR",
        //            TotalCount = 0
        //        });
        //    }
        //}

        /// <summary>
        /// Obtiene todas las asignaciones paginadas
        /// </summary>
        [HttpPost("paginado")]
        public async Task<ActionResult<PagedResult<VwUsuarioSucursalResponse>>> GetAllPaginado([FromBody] PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(_params);

            return Ok(new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Asignaciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            });
        }
    }
}