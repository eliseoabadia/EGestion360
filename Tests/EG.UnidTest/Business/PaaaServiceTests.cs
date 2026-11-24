using EG.Business.Services;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using EG.UnidTest.Support;
using Microsoft.Extensions.Logging.Abstractions;

namespace EG.UnidTest.Business;

public sealed class PaaaServiceTests
{
    [Fact]
    public async Task ForeignCompanyDetailCannotBeDeleted()
    {
        var data = Data();
        data[typeof(Paaa)] = new[] { new Paaa { PkidPaaas = 123, FkidEmpresaSis = 2, FkidAreaSis = 70, Activo = true } };
        data[typeof(Paaaspartidum)] = new[] { new Paaaspartidum { PkidPaaaspartida = 7, FkidPaaasOrco = 123, Activo = true } };
        data[typeof(Paaasdetalle)] = new[] { new Paaasdetalle { PkidPaaasdetalle = 9, FkidPaaaspartidaOrco = 7, Activo = true } };
        var persistence = new Persistence();

        var result = await Service(data, persistence).DeleteDetalleAsync(9);

        Assert.False(result.Success);
        Assert.Equal("NOT_FOUND", result.Code);
        Assert.Equal(0, persistence.Calls);
    }

    [Fact]
    public async Task CreateUsesServerCompanyAndCreationAudit()
    {
        var persistence = new Persistence();
        var result = await Service(Data(), persistence).CreateAsync(new PaaaResponse
        {
            FkidEmpresaSis = 999, FkidAnioSis = 5, FkidAreaSis = 70, FkidPersonaNom = 99,
            Descripcion = "Programa válido", Fecha = DateTime.Today,
            UsuarioCreacion = 999, FechaCreacion = new DateTime(2000, 1, 1)
        });

        Assert.True(result.Success);
        Assert.Equal(321, result.Data.PkidPaaas);
        Assert.Equal(1, persistence.Command!.EmpresaId);
        Assert.Equal(7, persistence.Command.UsuarioId);
        Assert.Equal(7, persistence.Command.Header!.UsuarioCreacion);
        Assert.Equal(1, result.Data.FkidEmpresaSis);
        Assert.NotEqual(new DateTime(2000, 1, 1), persistence.Command.Header.FechaCreacion);
    }

    [Fact]
    public async Task UnauthorizedAreaNeverReachesPersistence()
    {
        var persistence = new Persistence();
        var result = await Service(Data(), persistence).CreateAsync(new PaaaResponse
        {
            FkidAnioSis = 5, FkidAreaSis = 80, FkidPersonaNom = 99, Descripcion = "Programa", Fecha = DateTime.Today
        });

        Assert.False(result.Success);
        Assert.Equal("FORBIDDEN", result.Code);
        Assert.Equal(0, persistence.Calls);
    }

    [Fact]
    public async Task NonPositiveQuantityNeverReachesPersistence()
    {
        var persistence = new Persistence();
        var result = await Service(Data(), persistence).CreateDetalleAsync(new PaaasdetalleDto
        {
            FkidPaaaspartidaOrco = 7, FkidTipoBienAlma = 8, Cantidad = 0
        });

        Assert.False(result.Success);
        Assert.Equal("INVALID_CANTIDAD", result.Code);
        Assert.Equal(0, persistence.Calls);
    }

    private static Dictionary<Type, object> Data() => new()
    {
        [typeof(VwUsuarioPersonaArea)] = new[]
        {
            new VwUsuarioPersonaArea { PkIdUsuario = 7, UsuarioActivo = true, PersonaActivo = true, AreaActivo = true, PkidArea = 70 }
        }
    };

    private static PaaaService Service(Dictionary<Type, object> data, Persistence persistence) =>
        new(new Provider(data), persistence, new FixedUserContext(7, 1, 5), NullLogger<PaaaService>.Instance);

    private sealed class Provider(Dictionary<Type, object> data) : IRepositoryProvider
    {
        public IRepository<TEntity> For<TEntity>() where TEntity : class =>
            new InMemoryRepository<TEntity>(data.TryGetValue(typeof(TEntity), out var value) ? (IEnumerable<TEntity>)value : []);
    }

    private sealed class Persistence : IPaaaPersistence
    {
        public int Calls { get; private set; }
        public PaaaWriteCommand? Command { get; private set; }
        public Task<PaaaWriteResult> ExecuteAsync(PaaaWriteCommand command)
        {
            Calls++;
            Command = command;
            return Task.FromResult(new PaaaWriteResult(321, "OK"));
        }
    }
}
