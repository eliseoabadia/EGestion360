using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services.Security;

public sealed class UserContextQueries(EGestionContext context) : IUserContextQueries
{
    private IQueryable<Usuario> AccessibleUsers(int usuarioId, int empresaId) =>
        context.Usuarios.AsNoTracking().Where(user =>
            user.PkIdUsuario == usuarioId && user.Activo &&
            (user.FkidEmpresaSis == empresaId ||
             context.UsuarioSucursals.AsNoTracking().Any(assignment =>
                 assignment.FkidUsuarioSis == user.PkIdUsuario && assignment.Activo &&
                 assignment.FkidSucursalSisNavigation.Activo &&
                 assignment.FkidSucursalSisNavigation.FkidEmpresaSis == empresaId)));
    public bool CanAccessEmpresa(int usuarioId, int empresaId) => AccessibleUsers(usuarioId, empresaId).Any();

    public Task<bool> CanAccessEmpresaAsync(int usuarioId, int empresaId, CancellationToken cancellationToken = default) =>
        AccessibleUsers(usuarioId, empresaId).AnyAsync(cancellationToken);

    public bool IsActiveAnio(int anioId) =>
        context.Anios.AsNoTracking().Any(year => year.PkidAnio == anioId && year.Activo);

    public Task<bool> IsActiveAnioAsync(int anioId, CancellationToken cancellationToken = default) =>
        context.Anios.AsNoTracking().AnyAsync(year => year.PkidAnio == anioId && year.Activo, cancellationToken);
}
