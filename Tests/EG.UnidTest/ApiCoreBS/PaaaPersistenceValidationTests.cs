using EG.Domain.Interfaces;
using EG.Infrastructure;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.UnidTest.ApiCoreBS;

public sealed class PaaaPersistenceValidationTests
{
    [Theory]
    [InlineData(0, 1)]
    [InlineData(7, 0)]
    public async Task MissingIdentityOrCompanyIsRejectedBeforeOpeningDatabase(int user, int company)
    {
        using var context = new EGestionContext(new DbContextOptionsBuilder<EGestionContext>().Options);
        var repository = new PaaaPersistence(context);

        await Assert.ThrowsAsync<UnauthorizedAccessException>(() => repository.ExecuteAsync(new PaaaWriteCommand
        {
            Action = PaaaWriteAction.Create, UsuarioId = user, EmpresaId = company
        }));
    }

    [Theory]
    [InlineData(PaaaWriteAction.Create)]
    [InlineData(PaaaWriteAction.Update)]
    [InlineData(PaaaWriteAction.CreatePartida)]
    [InlineData(PaaaWriteAction.CreateDetalle)]
    [InlineData(PaaaWriteAction.UpdateDetalle)]
    public async Task IncompleteCommandIsRejectedBeforeOpeningDatabase(PaaaWriteAction action)
    {
        using var context = new EGestionContext(new DbContextOptionsBuilder<EGestionContext>().Options);
        var repository = new PaaaPersistence(context);

        await Assert.ThrowsAsync<ArgumentException>(() => repository.ExecuteAsync(new PaaaWriteCommand
        {
            Action = action, PaaaId = 1, UsuarioId = 7, EmpresaId = 1
        }));
    }
}
