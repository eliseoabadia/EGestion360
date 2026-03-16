using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;


namespace EG.Application.Services.General
{
    public class AspNetRolesAppService : IAspNetRolesAppService
    {
        private readonly GenericService<AspNetRole, AspNetRoleDto, AspNetRoleResponse> _service;
        private readonly IMapper _mapper;

        public AspNetRolesAppService(
            GenericService<AspNetRole, AspNetRoleDto, AspNetRoleResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
        }

        public async Task<IEnumerable<AspNetRoleResponse>> GetAllAsync()
        {
            try
            {
                var result = await _service.GetAllAsync();
                return _mapper.Map<IEnumerable<AspNetRoleResponse>>(result);
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en GetAllAsync: {ex.Message}", ex);
                throw;
            }
        }

        public async Task<AspNetRoleResponse> GetByIdAsync(string id)
        {
            try
            {
                if (string.IsNullOrEmpty(id))
                    throw new ArgumentException("ID de rol inválido", nameof(id));

                var result = await _service.GetByIdAsync(int.Parse(id), idPropertyName: "Id");
                return _mapper.Map<AspNetRoleResponse>(result);
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en GetByIdAsync: {ex.Message}", ex);
                throw;
            }
        }

        public async Task<AspNetRoleResponse> CreateAsync(AspNetRoleResponse dto, int usuarioActual)
        {
            try
            {
                if (dto == null)
                    throw new ArgumentNullException(nameof(dto), "Los datos del rol son requeridos");

                if (string.IsNullOrWhiteSpace(dto.Name))
                    throw new ArgumentException("El nombre del rol es obligatorio");

                var dtoRequest = _mapper.Map<AspNetRoleDto>(dto);
                await _service.AddAsync(dtoRequest);

                return _mapper.Map<AspNetRoleResponse>(dtoRequest);
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en CreateAsync: {ex.Message}", ex);
                throw;
            }
        }

        public async Task<AspNetRoleResponse> UpdateAsync(string id, AspNetRoleResponse dto, int usuarioActual)
        {
            try
            {
                if (string.IsNullOrEmpty(id))
                    throw new ArgumentException("ID de rol inválido", nameof(id));

                if (dto == null)
                    throw new ArgumentNullException(nameof(dto), "Los datos del rol son requeridos");

                dto.Id = id;
                var dtoRequest = _mapper.Map<AspNetRoleDto>(dto);
                await _service.UpdateAsync(int.Parse(id),dtoRequest);

                return _mapper.Map<AspNetRoleResponse>(dtoRequest);
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en UpdateAsync: {ex.Message}", ex);
                throw;
            }
        }

        public async Task DeleteAsync(string id)
        {
            try
            {
                if (string.IsNullOrEmpty(id))
                    throw new ArgumentException("ID de rol inválido", nameof(id));

                var role = await _service.GetByIdAsync(int.Parse(id), idPropertyName: "Id");
                if (role == null)
                    throw new KeyNotFoundException("Rol no encontrado");

                await _service.DeleteAsync(int.Parse(id));
            }
            catch (Exception ex)
            {
                //Log4NetLogger.Error($"Error en DeleteAsync: {ex.Message}", ex);
                throw;
            }
        }
    }
}