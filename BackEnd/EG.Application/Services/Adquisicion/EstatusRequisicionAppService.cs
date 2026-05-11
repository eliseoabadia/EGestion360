using AutoMapper;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class EstatusRequisicionAppService : IEstatusRequisicionAppService
    {
        private readonly GenericService<EstatusRequisicion, EstatusRequisicionDto, EstatusRequisicionResponse> _service;
        private readonly IMapper _mapper;

        public EstatusRequisicionAppService(
            GenericService<EstatusRequisicion, EstatusRequisicionDto, EstatusRequisicionResponse> service,
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
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidEstatusRequisicion != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<EstatusRequisicionResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisición obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PagedResult<EstatusRequisicionResponse>> GetByIdAsync(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidEstatusRequisicion");

            if (result == null)
                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = false,
                    Message = "Estatus de Requisición no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };

            return new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisición encontrado",
                Code = "SUCCESS",
                Data = result,
                Items = new List<EstatusRequisicionResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<EstatusRequisicionResponse>> CreateAsync(EstatusRequisicionResponse response, int usuarioActual)
        {
            try
            {
                var dto = _mapper.Map<EstatusRequisicionDto>(response);
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return new PagedResult<EstatusRequisicionResponse>
                    {
                        Success = false,
                        Message = "Ya existe un estatus de requisición activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.AddAsync(dto);

                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = true,
                    Message = "Estatus de Requisición creado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = false,
                    Message = $"Error al crear estatus de requisición: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<EstatusRequisicionResponse>> UpdateAsync(int id, EstatusRequisicionResponse response, int usuarioActual)
        {
            try
            {
                var dto = _mapper.Map<EstatusRequisicionDto>(response);
                dto.PkidEstatusRequisicion = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return new PagedResult<EstatusRequisicionResponse>
                    {
                        Success = false,
                        Message = "Ya existe otro estatus de requisición activo con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.UpdateAsync(id, dto);

                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = true,
                    Message = "Estatus de Requisición actualizado correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<EstatusRequisicionResponse>
                {
                    Success = false,
                    Message = $"Estatus de Requisición con ID {id} no encontrado",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<EstatusRequisicionResponse>
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
                    Message = "Estatus de Requisición eliminado correctamente",
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
                    Message = $"Estatus de Requisición con ID {id} no encontrado",
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

        public async Task<PagedResult<EstatusRequisicionResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<EstatusRequisicionResponse>
            {
                Success = true,
                Message = "Estatus de Requisición obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
