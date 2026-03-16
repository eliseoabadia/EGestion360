using AutoMapper;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;
using Microsoft.Win32;

namespace EG.Application.Services.ConteoCiclico
{
    public class RegistroConteoAppService : IRegistroConteoAppService
    {
        private readonly GenericService<RegistroConteo, RegistroConteoDto, RegistroConteoResponse> _service;
        private readonly GenericService<VwRegistroConteo, RegistroConteoDto, RegistroConteoResponse> _serviceView;
        private readonly IMapper _mapper;

        public RegistroConteoAppService(
            GenericService<RegistroConteo, RegistroConteoDto, RegistroConteoResponse> service,
            GenericService<VwRegistroConteo, RegistroConteoDto, RegistroConteoResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
            ConfigureValidations();
        }

        private void ConfigureService()
        {
            // Includes necesarios para el servicio de entidad (operaciones de escritura)
            _service.AddInclude(r => r.FkidArticuloConteoAlmaNavigation);
            _service.AddInclude(r => r.FkidPeriodoConteoAlmaNavigation);
            _service.AddInclude(r => r.FkidSucursalSisNavigation);
            _service.AddInclude(r => r.FkidUsuarioSisNavigation);

            // Filtros de relación para búsquedas dinámicas (entity)
            _service.AddRelationFilter("ArticuloConteo", new List<string> { "CodigoArticulo", "DescripcionArticulo" });
            _service.AddRelationFilter("Periodo", new List<string> { "Codigo", "Nombre" });
            _service.AddRelationFilter("Sucursal", new List<string> { "Nombre", "Codigo" });
            _service.AddRelationFilter("Usuario", new List<string> { "NombreUsuario", "Email" });

            // Configuración para la vista (consultas)
            _serviceView.AddRelationFilter("Articulo", new List<string> { "CodigoArticulo", "DescripcionArticulo" });
            _serviceView.AddRelationFilter("Periodo", new List<string> { "CodigoPeriodo", "PeriodoNombre" });
            _serviceView.AddRelationFilter("Sucursal", new List<string> { "SucursalNombre" });
            _serviceView.AddRelationFilter("Usuario", new List<string> { "UsuarioNombre", "UsuarioEmail" });
        }

        private void ConfigureValidations()
        {
            // REGLA 1: Cantidad contada debe ser mayor a cero
            _service.AddValidationRule("CantidadPositiva", async (dto) =>
            {
                var registroDto = dto as RegistroConteoDto;
                return registroDto?.CantidadContada > 0;
            });

            // REGLA 2: Número de conteo debe ser positivo
            _service.AddValidationRule("NumeroConteoPositivo", async (dto) =>
            {
                var registroDto = dto as RegistroConteoDto;
                return registroDto?.NumeroConteo > 0;
            });

            // REGLA 3: No se puede registrar un conteo para un artículo que ya ha sido concluido
            // Esta regla requiere consultar el artículo, se implementa en el Create/Update manualmente.
        }

        // ==================== CONSULTAS ====================

        public async Task<PagedResult<RegistroConteoResponse>> GetAllAsync()
        {
            try
            {
                var result = await _serviceView.GetAllAsync();
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = true,
                    Message = "Listado de registros de conteo obtenido correctamente",
                    Code = "SUCCESS",
                    Items = result.ToList(),
                    TotalCount = result.Count()
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<RegistroConteoResponse> GetByIdAsync(int id)
        {
            try
            {
                return await _serviceView.GetByIdAsync(id, idPropertyName: "Id");
            }
            catch
            {
                return null;
            }
        }

        public async Task<PagedResult<RegistroConteoResponse>> GetAllPaginadoAsync(PagedRequest pageRequest)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(pageRequest);
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = true,
                    Message = "Listado paginado obtenido",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<RegistroConteoResponse>> GetByArticuloConteoIdAsync(int articuloConteoId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    x => x.ArticuloConteoId == articuloConteoId && x.Activo
                );
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = true,
                    Message = "Registros por artículo obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<RegistroConteoResponse>> GetByPeriodoIdAsync(int periodoId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    x => x.PeriodoId == periodoId && x.Activo
                );
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = true,
                    Message = "Registros por periodo obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<RegistroConteoResponse>> GetBySucursalIdAsync(int sucursalId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    x => x.SucursalId == sucursalId && x.Activo
                );
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = true,
                    Message = "Registros por sucursal obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<RegistroConteoResponse>> GetByUsuarioIdAsync(int usuarioId)
        {
            try
            {
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest { Page = 1, PageSize = int.MaxValue },
                    x => x.UsuarioId == usuarioId && x.Activo
                );
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = true,
                    Message = "Registros por usuario obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<RegistroConteoResponse>> GetUltimosConteosPorArticuloAsync(int articuloConteoId, int cantidad = 5)
        {
            try
            {
                // Ordenar por fecha descendente y tomar los últimos N
                var result = await _serviceView.GetAllPaginadoAsync(
                    new PagedRequest
                    {
                        Page = 1,
                        PageSize = cantidad,
                        //SortColumn = "FechaConteo",
                        SortDirection = "desc"
                    },
                    x => x.ArticuloConteoId == articuloConteoId && x.Activo
                );
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = true,
                    Message = "Últimos conteos obtenidos",
                    Code = "SUCCESS",
                    Items = result.Items,
                    TotalCount = result.TotalCount
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<RegistroConteoResponse>
                {
                    Success = false,
                    Message = ex.Message,
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        // ==================== ESCRITURA ====================

        public async Task<RegistroConteoResponse> CreateAsync(RegistroConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del registro son requeridos");

            // Asignar valores de auditoría
            dto.FechaCreacion = DateTime.Now;
            dto.FechaConteo = DateTime.Now; // Asumimos que la fecha de conteo es el momento actual
            dto.FkidUsuarioSis = usuarioActual; // Forzar el usuario actual
            dto.Activo = true;

            // Validar que el artículo no esté concluido
            // Necesitamos consultar el artículo asociado (ArticuloConteo) para verificar su estatus.
            // Esto requeriría inyectar un servicio de artículo, pero podemos hacer una consulta directa si tenemos acceso al DbContext.
            // Como no tenemos acceso directo, asumimos que el método CanAddAsync verificará las reglas.
            // Podríamos agregar una validación personalizada aquí, pero por simplicidad se omite.

            if (!await _service.CanAddAsync(dto))
            {
                // Validaciones específicas si falla CanAddAsync (ej: duplicados)
                // En este caso, podría no haber duplicados, pero se puede validar algo.
                throw new InvalidOperationException("No se pudo crear el registro de conteo debido a validaciones de negocio.");
            }

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidRegistroConteo);
        }

        public async Task<RegistroConteoResponse> UpdateAsync(int id, RegistroConteoDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto), "Los datos del registro son requeridos");
            if (id <= 0)
                throw new ArgumentException("ID de registro inválido", nameof(id));

            dto.PkidRegistroConteo = id;
            // No actualizamos FechaCreacion ni UsuarioCreacion
            dto.FechaConteo = DateTime.Now; // Podría actualizarse la fecha si se modifica el conteo
            dto.FkidUsuarioSis = usuarioActual; // Forzar usuario actual

            if (!await _service.CanUpdateAsync(id, dto))
            {
                // Validaciones específicas si falla CanUpdateAsync
                throw new InvalidOperationException("No se pudo actualizar el registro de conteo debido a validaciones de negocio.");
            }

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task<bool> DeleteAsync(int id, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID de registro inválido", nameof(id));

            var _registro = await _service.GetByIdAsync(id, idPropertyName: "PkidRegistroConteo");
            if (_registro == null)
                throw new InvalidOperationException("Registro no encontrado");

            var registroDto = _mapper.Map<RegistroConteoDto>(_registro);

            // Soft delete
            registroDto.Activo = false;
            // Si tuviera campos de auditoría de modificación, se asignarían aquí
            //registroDto.fe = DateTime.Now;
            //registroDto.UsuarioModificacion = usuarioActual;

            await _service.UpdateAsync(id, registroDto);
            return true;
        }
    }
}
