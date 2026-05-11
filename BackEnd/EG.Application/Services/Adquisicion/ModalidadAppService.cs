using AutoMapper;
using EG.Application.Interfaces.Adquisicion;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Adquisicion
{
    public class ModalidadAppService : IModalidadAppService
    {
        private readonly GenericService<Modalidad, ModalidadDto, ModalidadResponse> _service;
        private readonly IMapper _mapper;

        public ModalidadAppService(
            GenericService<Modalidad, ModalidadDto, ModalidadResponse> service,
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
                    .Any(x => x.Descripcion.ToLower() == dto.Descripcion.ToLower() && x.PkidModalidad != id.Value && x.Activo);
            });
        }

        public async Task<PagedResult<ModalidadResponse>> GetAllAsync()
        {
            var result = await _service.GetAllAsync();
            return new PagedResult<ModalidadResponse>
            {
                Success = true,
                Message = "Modalidades obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<PagedResult<ModalidadResponse>> GetByIdAsync(int id)
        {
            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidModalidad");

            if (result == null)
                return new PagedResult<ModalidadResponse>
                {
                    Success = false,
                    Message = "Modalidad no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };

            return new PagedResult<ModalidadResponse>
            {
                Success = true,
                Message = "Modalidad encontrada",
                Code = "SUCCESS",
                Data = result,
                Items = new List<ModalidadResponse> { result },
                TotalCount = 1
            };
        }

        public async Task<PagedResult<ModalidadResponse>> CreateAsync(ModalidadResponse response, int usuarioActual)
        {
            try
            {
                var dto = _mapper.Map<ModalidadDto>(response);
                dto.UsuarioCreacion = usuarioActual;
                dto.FechaCreacion = DateTime.Now;
                dto.Activo = true;

                if (!await _service.CanAddAsync(dto))
                {
                    return new PagedResult<ModalidadResponse>
                    {
                        Success = false,
                        Message = "Ya existe una modalidad activa con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.AddAsync(dto);

                return new PagedResult<ModalidadResponse>
                {
                    Success = true,
                    Message = "Modalidad creada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ModalidadResponse>
                {
                    Success = false,
                    Message = $"Error al crear modalidad: {ex.Message}",
                    Code = "ERROR",
                    TotalCount = 0
                };
            }
        }

        public async Task<PagedResult<ModalidadResponse>> UpdateAsync(int id, ModalidadResponse response, int usuarioActual)
        {
            try
            {
                var dto = _mapper.Map<ModalidadDto>(response);
                dto.PkidModalidad = id;
                dto.UsuarioModificacion = usuarioActual;
                dto.FechaModificacion = DateTime.Now;

                if (!await _service.CanUpdateAsync(id, dto))
                {
                    return new PagedResult<ModalidadResponse>
                    {
                        Success = false,
                        Message = "Ya existe otra modalidad activa con esa descripción",
                        Code = "DUPLICATE",
                        TotalCount = 0
                    };
                }

                await _service.UpdateAsync(id, dto);

                return new PagedResult<ModalidadResponse>
                {
                    Success = true,
                    Message = "Modalidad actualizada correctamente",
                    Code = "SUCCESS",
                    TotalCount = 1
                };
            }
            catch (KeyNotFoundException)
            {
                return new PagedResult<ModalidadResponse>
                {
                    Success = false,
                    Message = $"Modalidad con ID {id} no encontrada",
                    Code = "NOT_FOUND",
                    TotalCount = 0
                };
            }
            catch (Exception ex)
            {
                return new PagedResult<ModalidadResponse>
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
                    Message = "Modalidad eliminada correctamente",
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
                    Message = $"Modalidad con ID {id} no encontrada",
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

        public async Task<PagedResult<ModalidadResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
            return new PagedResult<ModalidadResponse>
            {
                Success = true,
                Message = "Modalidades obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
