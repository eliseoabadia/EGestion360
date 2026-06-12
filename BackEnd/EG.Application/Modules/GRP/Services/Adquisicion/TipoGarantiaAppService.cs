using Mapster;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class TipoGarantiaAppService : ITipoGarantiaAppService
    {
        private readonly GenericService<TipoGarantium, TipoGarantiaDto, TipoGarantiaResponse> _service;

        public TipoGarantiaAppService(
            GenericService<TipoGarantium, TipoGarantiaDto, TipoGarantiaResponse> service)
        {
            _service = service;
            ConfigureValidations();
        }

        private void ConfigureValidations()
        {
            _service.AddValidationRule("UniqueDescripcion", async (dto) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.Activo);
            });

            _service.AddValidationRuleWithId("UniqueDescripcionUpdate", async (dto, id) =>
            {
                return !_service.GetQueryWithIncludes()
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidTipoGarantia != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<TipoGarantiaResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<TipoGarantiaResponse>
            {
                Success = true,
                Message = "Tipos de Garantía obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PagedResult<TipoGarantiaResponse>> GetByIdAsync(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidTipoGarantia");

            if (result == null)
                return new PagedResult<TipoGarantiaResponse>
                {
                    Success = false,
                    Message = "Tipo de Garantía no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };

            return new PagedResult<TipoGarantiaResponse>
            {
                Success = true,
                Message = "Tipo de Garantía encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<TipoGarantiaResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<TipoGarantiaResponse>> CreateAsync(TipoGarantiaResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<TipoGarantiaDto>();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return new PagedResult<TipoGarantiaResponse>
                    {
                        Success = false,
                        Message = "Ya existe un tipo de garantía activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.AddAsync(dto);

                return new PagedResult<TipoGarantiaResponse>
                {
                    Success = true,
                    Message = "Tipo de Garantía creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoGarantiaResponse>
                {
                    Success = false,
                    Message = $"Error al crear tipo de garantía: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoGarantiaResponse>> UpdateAsync(int id, TipoGarantiaResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<TipoGarantiaDto>();
                dto.PkidTipoGarantia = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return new PagedResult<TipoGarantiaResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro tipo de garantía activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.UpdateAsync(id, dto);

                return new PagedResult<TipoGarantiaResponse>
                {
                    Success = true,
                    Message = "Tipo de Garantía actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<TipoGarantiaResponse>
                {
                    Success = false,
                    Message = $"Tipo de Garantía con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoGarantiaResponse>
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
                    Message = "Tipo de Garantía eliminado correctamente",
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
                    Message = $"Tipo de Garantía con ID {id} no encontrado",
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

        public async Task<PagedResult<TipoGarantiaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<TipoGarantiaResponse>
            {
                Success = true,
                Message = "Tipos de Garantía obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
