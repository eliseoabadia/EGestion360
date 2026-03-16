using AutoMapper;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.Data.SqlClient;

namespace EG.Application.Services.General
{
    public class UsuarioSucursalAppService : IUsuarioSucursalAppService
    {
        private readonly GenericService<UsuarioSucursal, UsuarioSucursalDto, VwUsuarioSucursalResponse> _service;
        private readonly GenericService<VwUsuarioSucursal, UsuarioSucursalDto, VwUsuarioSucursalResponse> _serviceView;
        private readonly IRepositorySP<spEliminarUsuarioSucursalResult> _repositorySP;
        private readonly IMapper _mapper;

        public UsuarioSucursalAppService(
            GenericService<UsuarioSucursal, UsuarioSucursalDto, VwUsuarioSucursalResponse> service,
            GenericService<VwUsuarioSucursal, UsuarioSucursalDto, VwUsuarioSucursalResponse> serviceView,
            IRepositorySP<spEliminarUsuarioSucursalResult> repositorySP,
            IMapper mapper)
        {
            _service = service;
            _serviceView = serviceView;
            _repositorySP = repositorySP;
            _mapper = mapper;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(us => us.FkidUsuarioSisNavigation);
            _service.AddInclude(us => us.FkidSucursalSisNavigation);
            _service.AddRelationFilter("Usuario", new List<string> { "Nombre", "ApellidoPaterno", "Email" });
            _service.AddRelationFilter("Sucursal", new List<string> { "Nombre", "CodigoSucursal" });
        }

        public async Task<PagedResult<VwUsuarioSucursalResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Asignaciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<VwUsuarioSucursalResponse> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id);
        }

        public async Task<VwUsuarioSucursalResponse> GetByUsuarioAndSucursalAsync(int usuarioId, int sucursalId)
        {
            var todos = await _serviceView.GetAllAsync();
            return todos.FirstOrDefault(x => x.PkIdUsuario == usuarioId && x.IdSucursal == sucursalId);
        }

        public async Task<PagedResult<VwUsuarioSucursalResponse>> GetByUsuarioAsync(int usuarioId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.Where(x => x.PkIdUsuario == usuarioId && x.AsignacionActiva.Value).ToList();

            return new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Sucursales del usuario obtenidas correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            };
        }

        public async Task<PagedResult<VwUsuarioSucursalResponse>> GetBySucursalAsync(int sucursalId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.Where(x => x.IdSucursal == sucursalId && x.AsignacionActiva.Value).ToList();

            return new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Usuarios de la sucursal obtenidos correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            };
        }

        public async Task<PagedResult<VwUsuarioSucursalResponse>> GetGerentesBySucursalAsync(int sucursalId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.Where(x => x.IdSucursal == sucursalId && x.EsGerente.Value && x.AsignacionActiva.Value).ToList();

            return new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Gerentes de la sucursal obtenidos correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            };
        }

        public async Task<VwUsuarioSucursalResponse> AddAsync(VwUsuarioSucursalResponse _dto, int usuarioActual)
        {
            var result = await _serviceView.GetByIdAsync(_dto.PkIdUsuario);

            // Mapear y preparar el DTO
            var dto = _mapper.Map<UsuarioSucursalDto>(result);

            // Establecer valores por defecto
            dto.FkidSucursalSis = _dto.IdSucursal.Value;
            dto.FechaAsignacion = DateTime.Now;
            dto.Activo = true;

            await _service.AddAsync(dto);

            // Mapear y devolver el DTO
            return _mapper.Map<VwUsuarioSucursalResponse>(dto);
        }

        public async Task<bool> DeleteAsync(int usuarioId, int sucursalId, int usuarioActual)
        {
            var _resultListUserSuc = await _serviceView.GetAllPaginadoAsync(
                new PagedRequest { Page = 1, PageSize = 1000 },
                u => u.PkIdUsuario == usuarioId && u.IdSucursal == sucursalId);

            var _result = _resultListUserSuc.Items.FirstOrDefault();

            if (_result == null)
            {
                throw new Exception("Asignación no encontrada");
            }

            var parameters = new[]
            {
                new SqlParameter("@FkidUsuarioSis", usuarioId),
                new SqlParameter("@FkidSucursalSis", sucursalId),
                new SqlParameter("@UsuarioModificacion", usuarioActual)
            };

            var result = await _repositorySP.ExecuteStoredProcedureAsync<spEliminarUsuarioSucursalResult>(
                "SIS.spEliminarUsuarioSucursal", parameters);

            return result != null && result.Count() > 0;
        }

        public async Task<PagedResult<VwUsuarioSucursalResponse>> GetAllPaginadoAsync(PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(_params);

            return new PagedResult<VwUsuarioSucursalResponse>
            {
                Success = true,
                Message = "Asignaciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.Items,
                TotalCount = result.TotalCount
            };
        }
    }
}
