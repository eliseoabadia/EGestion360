using Mapster;
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
        private readonly GenericService<UsuarioSucursal, UsuarioSucursalDto, UsuarioSucursalResponse> _service;
        private readonly GenericService<VwUsuarioSucursal, UsuarioSucursalDto, UsuarioSucursalResponse> _serviceView;
        private readonly IRepositorySP<spEliminarUsuarioSucursalResult> _repositorySP;

        public UsuarioSucursalAppService(
            GenericService<UsuarioSucursal, UsuarioSucursalDto, UsuarioSucursalResponse> service,
            GenericService<VwUsuarioSucursal, UsuarioSucursalDto, UsuarioSucursalResponse> serviceView,
            IRepositorySP<spEliminarUsuarioSucursalResult> repositorySP)
        {
            _service = service;
            _serviceView = serviceView;
            _repositorySP = repositorySP;
            ConfigureService();
        }

        private void ConfigureService()
        {
            _service.AddInclude(us => us.FkidUsuarioSisNavigation);
            _service.AddInclude(us => us.FkidSucursalSisNavigation);
            _service.AddRelationFilter("Usuario", new List<string> { "Nombre", "ApellidoPaterno", "Email" });
            _service.AddRelationFilter("Sucursal", new List<string> { "Nombre", "CodigoSucursal" });
        }

        public async Task<PagedResult<UsuarioSucursalResponse>> GetAllAsync()
        {
            var result = await _serviceView.GetAllAsync();
            return new PagedResult<UsuarioSucursalResponse>
            {
                Success = true,
                Message = "Asignaciones obtenidas correctamente",
                Code = "SUCCESS",
                Items = result.ToList(),
                TotalCount = result.Count()
            };
        }

        public async Task<UsuarioSucursalResponse> GetByIdAsync(int id)
        {
            return await _serviceView.GetByIdAsync(id);
        }

        public async Task<UsuarioSucursalResponse> GetByUsuarioAndSucursalAsync(int usuarioId, int sucursalId)
        {
            var todos = await _serviceView.GetAllAsync();
            return todos.FirstOrDefault(x => x.PkIdUsuario == usuarioId && x.IdSucursal == sucursalId);
        }

        public async Task<PagedResult<UsuarioSucursalResponse>> GetByUsuarioAsync(int usuarioId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.Where(x => x.PkIdUsuario == usuarioId && x.AsignacionActiva).ToList();

            return new PagedResult<UsuarioSucursalResponse>
            {
                Success = true,
                Message = "Sucursales del usuario obtenidas correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            };
        }

        public async Task<PagedResult<UsuarioSucursalResponse>> GetBySucursalAsync(int sucursalId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.Where(x => x.IdSucursal == sucursalId && x.AsignacionActiva).ToList();

            return new PagedResult<UsuarioSucursalResponse>
            {
                Success = true,
                Message = "Usuarios de la sucursal obtenidos correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            };
        }

        public async Task<PagedResult<UsuarioSucursalResponse>> GetGerentesBySucursalAsync(int sucursalId)
        {
            var todos = await _serviceView.GetAllAsync();
            var result = todos.Where(x => x.IdSucursal == sucursalId && x.EsGerente && x.AsignacionActiva).ToList();

            return new PagedResult<UsuarioSucursalResponse>
            {
                Success = true,
                Message = "Gerentes de la sucursal obtenidos correctamente",
                Code = "SUCCESS",
                Items = result,
                TotalCount = result.Count
            };
        }

        public async Task<UsuarioSucursalResponse> AddAsync(UsuarioSucursalResponse _dto, int usuarioActual)
        {
            var result = await _serviceView.GetByIdAsync(_dto.PkIdUsuario);

            // Mapear y preparar el DTO
            var dto = result.Adapt<UsuarioSucursalDto>();

            // Establecer valores por defecto
            dto.FkidSucursalSis = _dto.IdSucursal;
            dto.FechaAsignacion = DateTime.Now;
            dto.Activo = true;

            await _service.AddAsync(dto);

            // Mapear y devolver el DTO
            return dto.Adapt<UsuarioSucursalResponse>();
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

        public async Task<PagedResult<UsuarioSucursalResponse>> GetAllPaginadoAsync(PagedRequest _params)
        {
            _serviceView.ClearConfiguration();
            ConfigureService();

            var result = await _serviceView.GetAllPaginadoAsync(_params);

            return new PagedResult<UsuarioSucursalResponse>
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
