using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Application.Services.General
{
    public class DepartamentoAppService : IDepartamentoAppService
    {
        private readonly GenericService<Departamento, DepartamentoDto, DepartamentoResponse> _service;
        private readonly GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> _serviceView;
        private readonly IMapper _mapper;

        public DepartamentoAppService(
            GenericService<Departamento, DepartamentoDto, DepartamentoResponse> service,
            GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> serviceView,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(d => d.FkidEmpresaSisNavigation);
            _service.AddRelationFilter("Empresa", new List<string> { "Nombre" });
        }

        public async Task<PagedResult<DepartamentoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<DepartamentoResponse> GetByIdAsync(int id)
        {
            if (id <= 0)
                throw new ArgumentException("ID debe ser mayor a 0");

            var result = await _serviceView.GetByIdAsync(id, idPropertyName: "PkidDepartamento");

            if (result == null)
                throw new KeyNotFoundException($"Departamento {id} no encontrado");

            return result;
        }

        public async Task<PagedResult<DepartamentoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(request);
            return new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<PagedResult<DepartamentoResponse>> GetAllByEmpresaAsync(int empresaId)
        {
            if (empresaId <= 0)
                throw new ArgumentException("Empresa ID debe ser mayor a 0");

            var parametros = new Dictionary<string, object> { ["empresaId"] = empresaId };
            var request = new PagedRequest
            {
                Page = 1,
                PageSize = 10000,
                SortLabel = "Nombre",
                SortDirection = "Ascending",
                AdditionalFilters = parametros
            };

            return await GetAllPaginadoAsync(request);
        }

        public async Task<DepartamentoResponse> CreateAsync(DepartamentoDto dto, int usuarioActual)
        {
            if (dto == null || string.IsNullOrWhiteSpace(dto.Nombre))
                throw new ArgumentException("Nombre de departamento es requerido");

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un departamento activo con ese nombre");

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidDepartamento);
        }

        public async Task<DepartamentoResponse> UpdateAsync(int id, DepartamentoDto dto, int usuarioActual)
        {
            if (id <= 0) throw new ArgumentException("ID debe ser mayor a 0");
            if (dto == null) throw new ArgumentNullException(nameof(dto));

            dto.PkidDepartamento = id;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro departamento activo con ese nombre");

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task DeleteAsync(int id)
        {
            if (id <= 0) throw new ArgumentException("ID debe ser mayor a 0");

            await _service.DeleteAsync(id);
        }
    }
}