using Mapster;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class TipoDocumentoAppService : ITipoDocumentoAppService
    {
        private readonly GenericService<TipoDocumento, TipoDocumentoDto, TipoDocumentoResponse> _service;

        public TipoDocumentoAppService(
            GenericService<TipoDocumento, TipoDocumentoDto, TipoDocumentoResponse> service)
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
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidTipoDocumento != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<TipoDocumentoResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<TipoDocumentoResponse>
            {
                Success = true,
                Message = "Tipos de Documentos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PagedResult<TipoDocumentoResponse>> GetByIdAsync(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidTipoDocumento");

            if (result == null)
                return new PagedResult<TipoDocumentoResponse>
                {
                    Success = false,
                    Message = "Tipo de Documento no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };

            return new PagedResult<TipoDocumentoResponse>
            {
                Success = true,
                Message = "Tipo de Documento encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<TipoDocumentoResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<TipoDocumentoResponse>> CreateAsync(TipoDocumentoResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<TipoDocumentoDto>();
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return new PagedResult<TipoDocumentoResponse>
                    {
                        Success = false,
                        Message = "Ya existe un tipo de documento activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.AddAsync(dto);

                return new PagedResult<TipoDocumentoResponse>
                {
                    Success = true,
                    Message = "Tipo de Documento creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoDocumentoResponse>
                {
                    Success = false,
                    Message = $"Error al crear tipo de documento: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoDocumentoResponse>> UpdateAsync(int id, TipoDocumentoResponse response, int usuarioActual)
        {
            try
            {
                var dto = response.Adapt<TipoDocumentoDto>();
                dto.PkidTipoDocumento = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return new PagedResult<TipoDocumentoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro tipo de documento activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.UpdateAsync(id, dto);

                return new PagedResult<TipoDocumentoResponse>
                {
                    Success = true,
                    Message = "Tipo de Documento actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<TipoDocumentoResponse>
                {
                    Success = false,
                    Message = $"Tipo de Documento con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoDocumentoResponse>
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
                    Message = "Tipo de Documento eliminado correctamente",
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
                    Message = $"Tipo de Documento con ID {id} no encontrado",
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

        public async Task<PagedResult<TipoDocumentoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<TipoDocumentoResponse>
            {
                Success = true,
                Message = "Tipos de Documentos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
