using EG.Application.Interfaces.General;
using EG.Business.Services;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General
{
    public class UsuarioSucursalAppService : IUsuarioSucursalAppService
    {
        private readonly GenericService<UsuarioSucursal, UsuarioSucursalDto, UsuarioSucursalResponse> _service;
        private readonly GenericService<VwUsuarioSucursal, UsuarioSucursalDto, UsuarioSucursalResponse> _serviceView;
        private readonly EGestionContext _context;

        public UsuarioSucursalAppService(
            GenericService<UsuarioSucursal, UsuarioSucursalDto, UsuarioSucursalResponse> service,
            GenericService<VwUsuarioSucursal, UsuarioSucursalDto, UsuarioSucursalResponse> serviceView,
            EGestionContext context)
        {
            _service = service;
            _serviceView = serviceView;
            _context = context;
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
            var result = await _serviceView.GetQueryWithIncludes(x => x.PkIdUsuario == usuarioId && x.AsignacionActiva)
                .Select(x => new UsuarioSucursalResponse
                {
                    PkIdUsuario = x.PkIdUsuario,
                    AspNetUserId = x.AspNetUserId,
                    IdEmpresa = x.IdEmpresa,
                    Nombre = x.Nombre,
                    ApellidoPaterno = x.ApellidoPaterno,
                    ApellidoMaterno = x.ApellidoMaterno,
                    NombreCompleto = x.NombreCompleto,
                    Iniciales = x.Iniciales,
                    InicialesNombre = x.InicialesNombre,
                    PayrollId = x.PayrollId,
                    CodigoPostalUsuario = x.CodigoPostal,
                    TelefonoUsuario = x.Telefono,
                    Direccion1 = x.Direccion1,
                    Direccion2 = x.Direccion2,
                    Email = x.Email,
                    NumeroSocial = x.NumeroSocial,
                    Gafete = x.Gafete,
                    Sexo = x.Sexo,
                    SexoDescripcion = x.SexoDescripcion,
                    FechaIngreso = x.FechaIngreso,
                    FechaIngresoFormat = x.FechaIngresoFormat,
                    AntigüedadAños = x.AntiguedadAnios,
                    IdIdiomaPreferido = x.IdIdiomaPreferido,
                    IdiomaPreferido = x.IdiomaPreferido,
                    IdMonedaPreferida = x.IdMonedaPreferida,
                    MonedaPreferida = x.MonedaPreferida,
                    SimboloMoneda = x.SimboloMoneda,
                    EsAdministrador = x.EsAdministrador,
                    UsuarioActivo = x.UsuarioActivo,
                    PkidEmpresa = x.PkidEmpresa,
                    NombreEmpresa = x.NombreEmpresa,
                    RfcEmpresa = x.RfcEmpresa,
                    RazonSocialEmpresa = x.RazonSocialEmpresa,
                    GiroEmpresa = x.GiroEmpresa,
                    IdMonedaBaseEmpresa = x.IdMonedaBaseEmpresa,
                    MonedaBaseEmpresa = x.MonedaBaseEmpresa,
                    SimboloMonedaBase = x.SimboloMonedaBase,
                    EmpresaFechaCreacion = x.EmpresaFechaCreacion,
                    IdSucursal = x.IdSucursal,
                    NombreSucursal = x.NombreSucursal,
                    CodigoSucursal = x.CodigoSucursal,
                    DireccionSucursal = x.DireccionSucursal,
                    EsMatriz = x.EsMatriz,
                    PuedeAcceder = x.PuedeAcceder,
                    PuedeConfigurar = x.PuedeConfigurar,
                    PuedeOperar = x.PuedeOperar,
                    PuedeReportes = x.PuedeReportes,
                    EsGerente = x.EsGerente,
                    EsSupervisor = x.EsSupervisor,
                    AsignacionActiva = x.AsignacionActiva,
                    EsJefeEnSucursal = x.EsJefeEnSucursal,
                    FechaCreacion = x.FechaCreacion,
                    UsuarioCreacion = x.UsuarioCreacion,
                    FechaModificacion = x.FechaModificacion,
                    UsuarioModificacion = x.UsuarioModificacion,
                    IdPersona = x.IdPersona,
                    ClavePersona = x.ClavePersona,
                    PersonaNombre = x.PersonaNombre,
                    PersonaPaterno = x.PersonaPaterno,
                    PersonaMaterno = x.PersonaMaterno,
                    NombreCompletoPersona = x.NombreCompletoPersona,
                    Rfc = x.Rfc,
                    Curp = x.Curp,
                    EmailPersona = x.EmailPersona,
                    TelefonoParticular = x.TelefonoParticular,
                    TelefonoMovil = x.TelefonoMovil,
                    IdEmpresaPersona = x.IdEmpresaPersona
                })
                .ToListAsync();

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
            if (_dto == null)
                throw new ArgumentNullException(nameof(_dto), "Los datos de la asignacion son requeridos");

            if (_dto.PkIdUsuario <= 0)
                throw new ArgumentException("Debe seleccionar un usuario valido");

            if (_dto.IdSucursal <= 0)
                throw new ArgumentException("Debe seleccionar una sucursal valida");

            var now = DateTime.Now;
            var entity = await _context.UsuarioSucursals
                .FirstOrDefaultAsync(x => x.FkidUsuarioSis == _dto.PkIdUsuario && x.FkidSucursalSis == _dto.IdSucursal);

            if (entity == null)
            {
                entity = new UsuarioSucursal
                {
                    FkidUsuarioSis = _dto.PkIdUsuario,
                    FkidSucursalSis = _dto.IdSucursal,
                    FechaAsignacion = now,
                    FechaCreacion = now,
                    UsuarioCreacion = usuarioActual
                };

                _context.UsuarioSucursals.Add(entity);
            }
            else
            {
                entity.FechaModificacion = now;
                entity.UsuarioModificacion = usuarioActual;
            }

            entity.Activo = true;
            entity.FechaFinAsignacion = null;
            entity.PuedeAcceder = true;
            entity.PuedeOperar = _dto.PuedeOperar || (!_dto.PuedeConfigurar && !_dto.PuedeReportes);
            entity.PuedeConfigurar = _dto.PuedeConfigurar;
            entity.PuedeReportes = _dto.PuedeReportes;
            entity.EsGerente = _dto.EsGerente;
            entity.EsSupervisor = _dto.EsSupervisor;

            var affected = await _context.SaveChangesAsync();
            if (affected <= 0)
                throw new InvalidOperationException("No se guardo la asignacion del usuario a la sucursal");

            var isActive = await _context.UsuarioSucursals
                .AsNoTracking()
                .AnyAsync(x => x.FkidUsuarioSis == _dto.PkIdUsuario && x.FkidSucursalSis == _dto.IdSucursal && x.Activo);

            if (!isActive)
                throw new InvalidOperationException("La asignacion no quedo activa en la base de datos");

            return await GetByUsuarioAndSucursalAsync(_dto.PkIdUsuario, _dto.IdSucursal)
                ?? new UsuarioSucursalResponse
                {
                    PkIdUsuario = _dto.PkIdUsuario,
                    IdSucursal = _dto.IdSucursal,
                    AsignacionActiva = true,
                    PuedeAcceder = true,
                    PuedeOperar = entity.PuedeOperar,
                    PuedeConfigurar = entity.PuedeConfigurar,
                    PuedeReportes = entity.PuedeReportes,
                    EsGerente = entity.EsGerente,
                    EsSupervisor = entity.EsSupervisor
                };
        }

        public async Task<bool> DeleteAsync(int usuarioId, int sucursalId, int usuarioActual)
        {
            var entity = await _context.UsuarioSucursals
                .FirstOrDefaultAsync(x => x.FkidUsuarioSis == usuarioId && x.FkidSucursalSis == sucursalId);

            if (entity == null || !entity.Activo)
                throw new Exception("Asignacion no encontrada o ya se encuentra inactiva");

            entity.Activo = false;
            entity.FechaFinAsignacion = DateTime.Now;
            entity.FechaModificacion = DateTime.Now;
            entity.UsuarioModificacion = usuarioActual;

            var affected = await _context.SaveChangesAsync();
            if (affected <= 0)
                throw new InvalidOperationException("No se actualizo la asignacion en la base de datos");

            var stillActive = await _context.UsuarioSucursals
                .AsNoTracking()
                .AnyAsync(x => x.FkidUsuarioSis == usuarioId && x.FkidSucursalSis == sucursalId && x.Activo);

            if (stillActive)
                throw new InvalidOperationException("La asignacion sigue activa en la base de datos");

            return true;

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
