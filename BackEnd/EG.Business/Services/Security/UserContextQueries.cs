using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Business.Services.Security;

public sealed class UserContextQueries(EGestionContext context) : IUserContextQueries
{
    public bool CanAccessEmpresa(int usuarioId, int empresaId)
    {
        if (context.Usuarios.AsNoTracking().Any(user =>
                user.PkIdUsuario == usuarioId && user.Activo && user.FkidEmpresaSis == empresaId))
        {
            return true;
        }

        return context.UsuarioSucursals.AsNoTracking().Any(assignment =>
            assignment.FkidUsuarioSis == usuarioId && assignment.Activo &&
            assignment.FkidSucursalSisNavigation.Activo &&
            assignment.FkidSucursalSisNavigation.FkidEmpresaSis == empresaId);
    }

    public bool IsActiveAnio(int anioId) =>
        context.Anios.AsNoTracking().Any(year => year.PkidAnio == anioId && year.Activo);
}
