using EG.Application.Interfaces.General;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Application.Services.General;

public class UsuarioDepartamentoAppService : IUsuarioDepartamentoAppService
{
    private readonly EGestionContext _context;

    public UsuarioDepartamentoAppService(EGestionContext context)
    {
        _context = context;
    }

    public async Task<PagedResult<UsuarioDepartamentoResponse>> GetByUsuarioAsync(int usuarioId)
    {
        try
        {
            if (usuarioId <= 0)
            {
                return Error("Debe seleccionar un usuario valido", "VALIDATION");
            }

            var result = await GetDepartamentosUsuarioAsync(usuarioId);
            return Success(result, "Departamentos del usuario obtenidos correctamente");
        }
        catch (Exception ex)
        {
            return Error($"Error al obtener departamentos del usuario: {ex.Message}");
        }
    }

    public async Task<PagedResult<UsuarioDepartamentoResponse>> AsignarAsync(
        UsuarioDepartamentoAsignacionRequest request,
        int usuarioActual)
    {
        try
        {
            if (request.UsuarioId <= 0 || request.DepartamentoId <= 0)
            {
                return Error("Debe seleccionar un usuario y un departamento validos", "VALIDATION");
            }

            var usuario = await _context.Usuarios
                .AsNoTracking()
                .FirstOrDefaultAsync(x => x.PkIdUsuario == request.UsuarioId && x.Activo);

            if (usuario == null)
            {
                return Error("El usuario seleccionado no existe o no esta activo", "NOT_FOUND");
            }

            var departamento = await _context.Departamentos
                .AsNoTracking()
                .Include(x => x.FkidEmpresaSisNavigation)
                .FirstOrDefaultAsync(x => x.PkidDepartamento == request.DepartamentoId && x.Activo);

            if (departamento == null)
            {
                return Error("El departamento seleccionado no existe o no esta activo", "NOT_FOUND");
            }

            var tieneEmpresaPrincipal = usuario.FkidEmpresaSis == departamento.FkidEmpresaSis;
            var tieneSucursalEmpresa = await _context.UsuarioSucursals
                .AsNoTracking()
                .Include(x => x.FkidSucursalSisNavigation)
                .AnyAsync(x =>
                    x.FkidUsuarioSis == request.UsuarioId &&
                    x.Activo &&
                    x.FkidSucursalSisNavigation.FkidEmpresaSis == departamento.FkidEmpresaSis);

            if (!tieneEmpresaPrincipal && !tieneSucursalEmpresa)
            {
                return Error("Primero asigna el usuario a la empresa o sucursal del departamento", "VALIDATION");
            }

            var now = DateTime.Now;
            var asignacion = await _context.UsuarioDepartamentos
                .OrderByDescending(x => x.Activo)
                .ThenByDescending(x => x.FechaAsignacion)
                .FirstOrDefaultAsync(x =>
                    x.FkidUsuarioSis == request.UsuarioId &&
                    x.FkidDepartamentoSis == request.DepartamentoId);

            if (asignacion == null)
            {
                asignacion = new UsuarioDepartamento
                {
                    FkidUsuarioSis = request.UsuarioId,
                    FkidDepartamentoSis = request.DepartamentoId,
                    FechaAsignacion = now,
                    FechaCreacion = now,
                    UsuarioCreacion = usuarioActual
                };

                _context.UsuarioDepartamentos.Add(asignacion);
            }
            else
            {
                asignacion.FechaModificacion = now;
                asignacion.UsuarioModificacion = usuarioActual;
            }

            asignacion.EsJefe = request.EsJefe;
            asignacion.Activo = true;
            asignacion.FechaFinAsignacion = null;

            await _context.SaveChangesAsync();

            var result = await GetDepartamentosUsuarioAsync(request.UsuarioId);
            return Success(result, "Departamento asignado correctamente");
        }
        catch (Exception ex)
        {
            return Error($"Error al asignar departamento: {ex.Message}");
        }
    }

    public async Task<PagedResult<UsuarioDepartamentoResponse>> EliminarAsync(
        int usuarioId,
        int departamentoId,
        int usuarioActual)
    {
        try
        {
            var asignacion = await _context.UsuarioDepartamentos
                .OrderByDescending(x => x.FechaAsignacion)
                .FirstOrDefaultAsync(x =>
                    x.FkidUsuarioSis == usuarioId &&
                    x.FkidDepartamentoSis == departamentoId &&
                    x.Activo);

            if (asignacion == null)
            {
                return Error("La asignacion de departamento no existe o ya esta inactiva", "NOT_FOUND");
            }

            asignacion.Activo = false;
            asignacion.FechaFinAsignacion = DateTime.Now;
            asignacion.FechaModificacion = DateTime.Now;
            asignacion.UsuarioModificacion = usuarioActual;

            await _context.SaveChangesAsync();

            var result = await GetDepartamentosUsuarioAsync(usuarioId);
            return Success(result, "Departamento retirado correctamente");
        }
        catch (Exception ex)
        {
            return Error($"Error al retirar departamento: {ex.Message}");
        }
    }

    private async Task<List<UsuarioDepartamentoResponse>> GetDepartamentosUsuarioAsync(int usuarioId)
    {
        var rows = await _context.UsuarioDepartamentos
            .AsNoTracking()
            .Include(x => x.FkidUsuarioSisNavigation)
                .ThenInclude(x => x.FkidPersonaNomNavigation)
            .Include(x => x.FkidDepartamentoSisNavigation)
                .ThenInclude(x => x.FkidEmpresaSisNavigation)
            .Where(x =>
                x.FkidUsuarioSis == usuarioId &&
                x.Activo &&
                x.FkidDepartamentoSisNavigation.Activo)
            .OrderBy(x => x.FkidDepartamentoSisNavigation.FkidEmpresaSisNavigation.Nombre)
            .ThenBy(x => x.FkidDepartamentoSisNavigation.Nombre)
            .ToListAsync();

        return rows.Select(ToResponse).ToList();
    }

    private static UsuarioDepartamentoResponse ToResponse(UsuarioDepartamento entity)
    {
        var usuario = entity.FkidUsuarioSisNavigation;
        var persona = usuario?.FkidPersonaNomNavigation;
        var departamento = entity.FkidDepartamentoSisNavigation;
        var empresa = departamento?.FkidEmpresaSisNavigation;
        var usuarioNombre = persona == null
            ? $"Usuario {entity.FkidUsuarioSis}"
            : $"{persona.Nombre} {persona.Paterno} {persona.Materno}".Trim();

        return new UsuarioDepartamentoResponse
        {
            UsuarioId = entity.FkidUsuarioSis,
            DepartamentoId = entity.FkidDepartamentoSis,
            EmpresaId = departamento?.FkidEmpresaSis ?? 0,
            UsuarioNombre = usuarioNombre,
            DepartamentoNombre = departamento?.Nombre ?? string.Empty,
            EmpresaNombre = empresa?.Nombre ?? empresa?.RazonSocial ?? string.Empty,
            EsJefe = entity.EsJefe,
            Activo = entity.Activo,
            FechaAsignacion = entity.FechaAsignacion
        };
    }

    private static PagedResult<UsuarioDepartamentoResponse> Success(
        List<UsuarioDepartamentoResponse> items,
        string message)
    {
        return new PagedResult<UsuarioDepartamentoResponse>
        {
            Success = true,
            Message = message,
            Code = "SUCCESS",
            Items = items,
            TotalCount = items.Count
        };
    }

    private static PagedResult<UsuarioDepartamentoResponse> Error(string message, string code = "ERROR")
    {
        return new PagedResult<UsuarioDepartamentoResponse>
        {
            Success = false,
            Message = message,
            Code = code,
            TotalCount = 0
        };
    }
}
