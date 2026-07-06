using Mapster;
using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General
{
    public class DepartamentoAppService : IDepartamentoAppService
    {
        private readonly GenericService<Departamento, DepartamentoDto, DepartamentoResponse> _service;
        private readonly GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> _serviceView;
        private readonly EGestionContext _context;

        public DepartamentoAppService(
            GenericService<Departamento, DepartamentoDto, DepartamentoResponse> service,
            GenericService<VwEmpresaDepartamanto, DepartamentoDto, DepartamentoResponse> serviceView,
            EGestionContext context)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
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

            var result = await _context.Departamentos
                .AsNoTracking()
                .Include(x => x.FkidEmpresaSisNavigation)
                .Include(x => x.UsuarioCreacionNavigation)
                    .ThenInclude(x => x.FkidPersonaNomNavigation)
                .Where(x => x.PkidDepartamento == id && x.Activo)
                .Select(x => new DepartamentoResponse
                {
                    PkidDepartamento = x.PkidDepartamento,
                    PkidEmpresa = x.FkidEmpresaSis,
                    EmpresaNombre = x.FkidEmpresaSisNavigation != null ? x.FkidEmpresaSisNavigation.Nombre : string.Empty,
                    Rfc = x.FkidEmpresaSisNavigation != null ? x.FkidEmpresaSisNavigation.Rfc : string.Empty,
                    DepartamentoNombre = x.Nombre ?? string.Empty,
                    Descripcion = x.Descripcion ?? string.Empty,
                    NivelJerarquico = x.NivelJerarquico,
                    DepartamentoActivo = x.Activo,
                    EmpresaActivo = x.FkidEmpresaSisNavigation != null && x.FkidEmpresaSisNavigation.Activo,
                    FechaCreacion = x.FechaCreacion,
                    UsuarioCreacion = x.UsuarioCreacion,
                    FechaModificacion = x.FechaModificacion,
                    UsuarioModificacion = x.UsuarioModificacion,
                    UsuarioCreacionNombre = x.UsuarioCreacionNavigation != null &&
                        x.UsuarioCreacionNavigation.FkidPersonaNomNavigation != null
                            ? $"{x.UsuarioCreacionNavigation.FkidPersonaNomNavigation.Nombre} {x.UsuarioCreacionNavigation.FkidPersonaNomNavigation.Paterno}".Trim()
                            : string.Empty
                })
                .FirstOrDefaultAsync();

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

            var nombre = response.DepartamentoNombre.Trim();
            if (response.PkidEmpresa <= 0)
                throw new ArgumentException("Empresa es requerida");

            var empresaActiva = await _context.Empresas
                .AsNoTracking()
                .AnyAsync(x => x.PkidEmpresa == response.PkidEmpresa && x.Activo);
            if (!empresaActiva)
                throw new KeyNotFoundException("Empresa no encontrada o inactiva");

            var duplicate = await _context.Departamentos
                .AsNoTracking()
                .AnyAsync(x =>
                    x.Activo &&
                    x.FkidEmpresaSis == response.PkidEmpresa &&
                    x.Nombre == nombre);
            if (duplicate)
                throw new InvalidOperationException("Ya existe un departamento activo con ese nombre");

            var entity = new Departamento
            {
                FkidEmpresaSis = response.PkidEmpresa,
                Nombre = nombre,
                Descripcion = response.Descripcion?.Trim(),
                NivelJerarquico = response.NivelJerarquico,
                Activo = true,
                FechaCreacion = DateTime.Now,
                UsuarioCreacion = usuarioActual
            };

            _context.Departamentos.Add(entity);
            await _context.SaveChangesAsync();

            return await GetByIdAsync(entity.PkidDepartamento);
        }

        public async Task<DepartamentoResponse> UpdateAsync(int id, DepartamentoResponse response, int usuarioActual)
        {
            if (id <= 0) throw new ArgumentException("ID debe ser mayor a 0");
            if (response == null) throw new ArgumentNullException(nameof(response));
            if (string.IsNullOrWhiteSpace(response.DepartamentoNombre))
                throw new ArgumentException("Nombre de departamento es requerido");
            if (response.PkidEmpresa <= 0)
                throw new ArgumentException("Empresa es requerida");

            var entity = await _context.Departamentos
                .FirstOrDefaultAsync(x => x.PkidDepartamento == id && x.Activo);
            if (entity == null)
                throw new KeyNotFoundException($"Departamento {id} no encontrado");

            var empresaActiva = await _context.Empresas
                .AsNoTracking()
                .AnyAsync(x => x.PkidEmpresa == response.PkidEmpresa && x.Activo);
            if (!empresaActiva)
                throw new KeyNotFoundException("Empresa no encontrada o inactiva");

            var nombre = response.DepartamentoNombre.Trim();
            var duplicate = await _context.Departamentos
                .AsNoTracking()
                .AnyAsync(x =>
                    x.PkidDepartamento != id &&
                    x.Activo &&
                    x.FkidEmpresaSis == response.PkidEmpresa &&
                    x.Nombre == nombre);
            if (duplicate)
                throw new InvalidOperationException("Ya existe otro departamento activo con ese nombre");

            entity.FkidEmpresaSis = response.PkidEmpresa;
            entity.Nombre = nombre;
            entity.Descripcion = response.Descripcion?.Trim();
            entity.NivelJerarquico = response.NivelJerarquico;
            entity.Activo = response.DepartamentoActivo;
            entity.FechaModificacion = DateTime.Now;
            entity.UsuarioModificacion = usuarioActual;

            await _context.SaveChangesAsync();
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

            var departamento = await _context.Departamentos
                .AsNoTracking()
                .Where(d => d.PkidDepartamento == id)
                .Select(d => new
                {
                    d.PkidDepartamento,
                    d.Nombre,
                    d.Activo
                })
                .FirstOrDefaultAsync();

            if (departamento == null)
                throw new KeyNotFoundException($"Departamento con ID {id} no encontrado");

            if (!departamento.Activo)
                throw new InvalidOperationException($"El departamento \"{departamento.Nombre}\" ya se encuentra inactivo");

            var usuariosActivos = await _context.UsuarioDepartamentos
                .AsNoTracking()
                .CountAsync(ud => ud.FkidDepartamentoSis == id && ud.Activo);

            if (usuariosActivos > 0)
            {
                throw new InvalidOperationException(
                    $"No se puede eliminar el departamento \"{departamento.Nombre}\" porque tiene {usuariosActivos} usuario(s) asignado(s) activos.");
            }

            var fechaModificacion = DateTime.Now;
            var affectedRows = await _context.Departamentos
                .Where(d => d.PkidDepartamento == id && d.Activo)
                .ExecuteUpdateAsync(setters => setters
                    .SetProperty(d => d.Activo, false)
                    .SetProperty(d => d.FechaModificacion, fechaModificacion));

            if (affectedRows <= 0)
                throw new InvalidOperationException($"No se pudo eliminar el departamento \"{departamento.Nombre}\" porque no se actualizo ningun registro");

            var stillActive = await _context.Departamentos
                .AsNoTracking()
                .AnyAsync(d => d.PkidDepartamento == id && d.Activo);

            if (stillActive)
                throw new InvalidOperationException($"No fue posible dar de baja el departamento \"{departamento.Nombre}\"; el registro sigue activo en la base de datos");
        }
    }
}
