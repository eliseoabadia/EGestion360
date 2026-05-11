using AutoMapper;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class TipoContratoAppService : ITipoContratoAppService
    {
        private readonly GenericService<TipoContrato, TipoContratoDto, TipoContratoResponse> _service;
        private readonly IMapper _mapper;

        public TipoContratoAppService(
            GenericService<TipoContrato, TipoContratoDto, TipoContratoResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
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
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidTipoContrato != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<TipoContratoResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<TipoContratoResponse>
            {
                Success = true,
                Message = "Tipos de Contrato obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PagedResult<TipoContratoResponse>> GetByIdAsync(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidTipoContrato");

            if (result == null)
                return new PagedResult<TipoContratoResponse>
                {
                    Success = false,
                    Message = "Tipo de Contrato no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };

            return new PagedResult<TipoContratoResponse>
            {
                Success = true,
                Message = "Tipo de Contrato encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<TipoContratoResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<TipoContratoResponse>> CreateAsync(TipoContratoResponse response, int usuarioActual)
        {
            try
            {
                var dto = _mapper.Map<TipoContratoDto>(response);
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return new PagedResult<TipoContratoResponse>
                    {
                        Success = false,
                        Message = "Ya existe un tipo de contrato activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.AddAsync(dto);

                return new PagedResult<TipoContratoResponse>
                {
                    Success = true,
                    Message = "Tipo de Contrato creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoContratoResponse>
                {
                    Success = false,
                    Message = $"Error al crear tipo de contrato: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<TipoContratoResponse>> UpdateAsync(int id, TipoContratoResponse response, int usuarioActual)
        {
            try
            {
                var dto = _mapper.Map<TipoContratoDto>(response);
                dto.PkidTipoContrato = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return new PagedResult<TipoContratoResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro tipo de contrato activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.UpdateAsync(id, dto);

                return new PagedResult<TipoContratoResponse>
                {
                    Success = true,
                    Message = "Tipo de Contrato actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<TipoContratoResponse>
                {
                    Success = false,
                    Message = $"Tipo de Contrato con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<TipoContratoResponse>
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
                    Message = "Tipo de Contrato eliminado correctamente",
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
                    Message = $"Tipo de Contrato con ID {id} no encontrado",
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

        public async Task<PagedResult<TipoContratoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<TipoContratoResponse>
            {
                Success = true,
                Message = "Tipos de Contrato obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
