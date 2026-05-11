using AutoMapper;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class ArticuloAppService : IArticuloAppService
    {
        private readonly GenericService<Articulo, ArticuloDto, ArticuloResponse> _service;
        private readonly IMapper _mapper;

        public ArticuloAppService(
            GenericService<Articulo, ArticuloDto, ArticuloResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueClave", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueClaveUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Clave.ToLower() == dto.Clave.ToLower() && x.PkidArticulo != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<ArticuloResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<ArticuloResponse>
            {
                Success = true,
                Message = "Artículos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PagedResult<ArticuloResponse>> GetByIdAsync(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidArticulo");

            if (result == null)
                return new PagedResult<ArticuloResponse>
                {
                    Success = false,
                    Message = "Artículo no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };

            return new PagedResult<ArticuloResponse>
            {
                Success = true,
                Message = "Artículo encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ArticuloResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<ArticuloResponse>> CreateAsync(ArticuloResponse response, int usuarioActual)
        {
            try
            {
                var dto = _mapper.Map<ArticuloDto>(response);
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return new PagedResult<ArticuloResponse>
                    {
                        Success = false,
                        Message = "Ya existe un artículo activo con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.AddAsync(dto);

                return new PagedResult<ArticuloResponse>
                {
                    Success = true,
                    Message = "Artículo creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ArticuloResponse>
                {
                    Success = false,
                    Message = $"Error al crear artículo: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ArticuloResponse>> UpdateAsync(int id, ArticuloResponse response, int usuarioActual)
        {
            try
            {
                var dto = _mapper.Map<ArticuloDto>(response);
                dto.PkidArticulo = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return new PagedResult<ArticuloResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro artículo activo con esa clave",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.UpdateAsync(id, dto);

                return new PagedResult<ArticuloResponse>
                {
                    Success = true,
                    Message = "Artículo actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<ArticuloResponse>
                {
                    Success = false,
                    Message = $"Artículo con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ArticuloResponse>
                {
                    Success = false,
                    Message = $"Error al actualizar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<bool>> DeleteAsync(int id)
        {
            try
            {
                await _service.DeleteAsync(id);
                return new PagedResult<bool>
                {
                    Success = true,
                    Message = "Artículo eliminado correctamente",
                    Code = "SUCCESS",
                    Data = true,
                    Items = new List<bool> { true },
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Artículo con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<bool>
                {
                    Success = false,
                    Message = $"Error al eliminar: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ArticuloResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<ArticuloResponse>
            {
                Success = true,
                Message = "Artículos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
