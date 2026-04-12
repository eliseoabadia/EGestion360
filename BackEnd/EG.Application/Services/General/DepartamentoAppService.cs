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
        private readonly IMapper _mapper;

        public DepartamentoAppService(
            GenericService<Departamento, DepartamentoDto, DepartamentoResponse> service,
            IMapper mapper)
        {
            _service = service;
            _mapper = mapper;
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
            var result = await _service.GetAllAsync();
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

            var result = await _service.GetByIdAsync(id, idPropertyName: "PkidDepartamento");

            if (result == null)
                throw new KeyNotFoundException($"Departamento {id} no encontrado");

            return result;
        }

        public async Task<PagedResult<DepartamentoResponse>> GetAllPaginadoAsync(PagedRequest request)
        {
            var result = await _service.GetAllPaginadoAsync(request);
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

        public async Task DeleteAsync(int id)
        {
            if (id <= 0) throw new ArgumentException("ID debe ser mayor a 0");

            await _service.DeleteAsync(id);
        }
    }
}