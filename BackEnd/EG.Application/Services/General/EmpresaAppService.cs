using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Application.Services.General
{
    public class EmpresaAppService : IEmpresaAppService
    {
        private readonly GenericService<Empresa, EmpresaDto, EmpresaResponse> _service;
        private readonly GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> _serviceView;
        private readonly IMapper _mapper;

        public EmpresaAppService(
            GenericService<Empresa, EmpresaDto, EmpresaResponse> service,
            GenericService<VwEstadoEmpresa, EmpresaDto, EmpresaResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(e => e.EmpresaEstados);
            _service.AddRelationFilter("Empresa", new List<string> { "Nombre", "Rfc" });
        }

        public async Task<PagedResult<EmpresaResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<EmpresaResponse> GetByIdAsync(int id)
        {
            if (id <= 0)
                throw new ArgumentException("ID debe ser mayor a 0");

            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidEmpresa");

            if (result == null)
                throw new KeyNotFoundException($"Empresa con ID {id} no encontrada");

            return result;
        }

        public async Task<PagedResult<EmpresaResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(request);

            return new PagedResult<EmpresaResponse>
            {
                Success = true,
                Message = "Empresas obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<EmpresaResponse> CreateAsync(EmpresaDto dto, int usuarioActual)
        {
            if (dto == null)
                throw new ArgumentNullException(nameof(dto));

            if (string.IsNullOrWhiteSpace(dto.Nombre))
                throw new ArgumentException("Nombre de empresa es requerido");

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe una empresa activa con ese nombre");

            await _service.AddAsync(dto);

            return await GetByIdAsync(dto.PkidEmpresa);
        }

        public async Task<EmpresaResponse> UpdateAsync(int id, EmpresaDto dto, int usuarioActual)
        {
            if (id <= 0)
                throw new ArgumentException("ID debe ser mayor a 0");

            if (dto == null)
                throw new ArgumentNullException(nameof(dto));

            dto.PkidEmpresa = id;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otra empresa activa con ese nombre");

            await _service.UpdateAsync(id, dto);

            return await GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            if (id <= 0)
                throw new ArgumentException("ID debe ser mayor a 0");

            var empresa = await _service.GetByIdAsync(id, idPropertyName: "PkidEmpresa");
            if (empresa == null)
                throw new KeyNotFoundException($"Empresa {id} no encontrada");

            // 🔧 LÓGICA: Validar si puede eliminarse
            // Por ejemplo, verificar si tiene departamentos asociados
            
            await _service.DeleteAsync(id);
        }
    }
}