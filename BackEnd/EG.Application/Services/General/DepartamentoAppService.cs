using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;

namespace EG.Application.Services.General
{
    public class DepartamentoAppService : IDepartamentoAppService
    {
        private readonly GenericService<Departamento, DepartamentoDto, DepartamentoResponse> _service;
        private readonly GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> _serviceView;
        private readonly IMapper _mapper;
        private readonly IRepository<Departamento> _repository;

        public DepartamentoAppService(
            GenericService<Departamento, DepartamentoDto, DepartamentoResponse> service,
            GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> serviceView,
            IMapper mapper,
            IRepository<Departamento> repository)
        {
            _service = service;
            _serviceView = serviceView;
            _mapper = mapper;
            _repository = repository;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(d => d.FkidEmpresaSisNavigation);
            _service.AddInclude(d => d.FkidSucursalSisNavigation);
            _service.AddInclude(d => d.UsuarioCreacionNavigation);
            _service.AddRelationFilter("FkidEmpresaSisNavigation", new List<string> { "Nombre" });
        }

        public async Task<PagedResult<DepartamentoResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Message = "Departamentos obtenidos correctamente",
                Code = "SUCCESS",
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
            var result = await _serviceView.GetAllPaginadoAsync(request);
            return new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Message = "Departamentos obtenidos correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<PagedResult<DepartamentoResponse>> GetAllByEmpresaAsync(int empresaId)
        {
            if (empresaId <= 0)
                throw new ArgumentException("Empresa ID debe ser mayor a 0");

            var result = await _service.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 10000, SortLabel = "Nombre", SortDirection = "asc" },
                d => d.FkidEmpresaSis == empresaId);

            return new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task<DepartamentoResponse> CreateAsync(DepartamentoResponse response, int usuarioActual)
        {
            if (response == null || string.IsNullOrWhiteSpace(response.DepartamentoNombre))
                throw new ArgumentException("Nombre de departamento es requerido");

            var dto = _mapper.Map<DepartamentoDto>(response);
            dto.UsuarioCreacion = usuarioActual;
            dto.FechaCreacion = DateTime.Now;
            dto.Activo = true;

            if (!await _service.CanAddAsync(dto))
                throw new InvalidOperationException("Ya existe un departamento activo con ese nombre");

            await _service.AddAsync(dto);
            return await GetByIdAsync(dto.PkidDepartamento);
        }

        public async Task<DepartamentoResponse> UpdateAsync(int id, DepartamentoResponse response, int usuarioActual)
        {
            if (id <= 0) throw new ArgumentException("ID debe ser mayor a 0");
            if (response == null) throw new ArgumentNullException(nameof(response));

            var dto = _mapper.Map<DepartamentoDto>(response);
            dto.PkidDepartamento = id;
            dto.UsuarioModificacion = usuarioActual;
            dto.FechaModificacion = DateTime.Now;

            if (!await _service.CanUpdateAsync(id, dto))
                throw new InvalidOperationException("Ya existe otro departamento activo con ese nombre");

            await _service.UpdateAsync(id, dto);
            return await GetByIdAsync(id);
        }

        public async Task<PagedResult<DepartamentoResponse>> BuscarAsync(BusquedaRequest request)
        {
            var pagedRequest = new PagedRequest
            {
                Page = request.Page,
                PageSize = request.PageSize,
                Filtro = request.TerminoBusqueda,
                SortLabel = request.SortLabel,
                SortDirection = request.SortDirection
            };

            var result = await _serviceView.GetAllPaginadoAsync(pagedRequest);

            return new PagedResult<DepartamentoResponse>
            {
                Success = true,
                Message = "Departamentos filtrados correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }

        public async Task DeleteAsync(int id)
        {
            if (id <= 0) throw new ArgumentException("ID debe ser mayor a 0");

            var hasChildren = await _repository.HasActiveChildrenAsync<UsuarioDepartamento>("FkidDepartamentoSis", id);
            if (hasChildren)
                throw new InvalidOperationException("No se puede eliminar el departamento porque tiene usuarios asignados activos");

            await _repository.SoftDeleteAsync(id);
        }
    }
}