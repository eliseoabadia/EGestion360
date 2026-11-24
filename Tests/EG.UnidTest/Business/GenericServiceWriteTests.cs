using System.Linq.Expressions;
using EG.Business.Services;
using EG.Domain.Interfaces;
using EG.UnidTest.Support;

namespace EG.UnidTest.Business;

public sealed class GenericServiceWriteTests
{
    [Fact]
    public async Task RejectedCreateNeverReachesPersistence()
    {
        var repository = new RecordingRepository();
        var service = Create(repository);
        service.AddValidationRule("required-name", dto => Task.FromResult(!string.IsNullOrWhiteSpace(dto.Nombre)));

        await Assert.ThrowsAsync<InvalidOperationException>(() => service.AddAsync(new Record()));
        Assert.Equal(0, repository.Adds);
    }

    [Fact]
    public async Task RejectedUpdateLeavesExistingRecordUnchanged()
    {
        var repository = new RecordingRepository { Existing = new() { Id = 1, Nombre = "Original", FkidEmpresaSis = 3 } };
        var service = Create(repository);
        service.AddValidationRuleWithId("update-blocked", (_, _) => Task.FromResult(false));

        await Assert.ThrowsAsync<InvalidOperationException>(() => service.UpdateAsync(1, new() { Nombre = "Alterado" }));
        Assert.Equal("Original", repository.Existing.Nombre);
        Assert.Equal(0, repository.Updates);
    }

    [Fact]
    public async Task CreateUsesServerIdentityDateAndCompanyBeforeValidation()
    {
        var repository = new RecordingRepository();
        var service = Create(repository);
        var earliest = DateTime.Now.AddSeconds(-1);
        service.AddValidationRule("server-scope", dto => Task.FromResult(dto.FkidEmpresaSis == 3 && dto.UsuarioCreacion == 7));

        await service.AddAsync(new()
        {
            Nombre = "Válido", FkidEmpresaSis = 99, UsuarioCreacion = 999, FechaCreacion = new DateTime(2000, 1, 1)
        });

        Assert.Equal(1, repository.Adds);
        Assert.Equal(7, repository.Saved!.UsuarioCreacion);
        Assert.Equal(3, repository.Saved.FkidEmpresaSis);
        Assert.InRange(repository.Saved.FechaCreacion, earliest, DateTime.Now);
    }

    [Fact]
    public async Task UpdatePreservesCreationAndPrimaryKey()
    {
        var originalDate = new DateTime(2020, 1, 1);
        var repository = new RecordingRepository
        {
            Existing = new() { Id = 1, Nombre = "Original", FkidEmpresaSis = 3, UsuarioCreacion = 2, FechaCreacion = originalDate }
        };

        await Create(repository).UpdateAsync(1, new()
        {
            Id = 999, Nombre = "Actualizado", FkidEmpresaSis = 99, UsuarioCreacion = 999, FechaCreacion = DateTime.Now
        });

        Assert.Equal(1, repository.Updates);
        Assert.Equal(1, repository.Existing.Id);
        Assert.Equal(2, repository.Existing.UsuarioCreacion);
        Assert.Equal(originalDate, repository.Existing.FechaCreacion);
        Assert.Equal(7, repository.Existing.UsuarioModificacion);
        Assert.Equal(3, repository.Existing.FkidEmpresaSis);
    }

    [Fact]
    public async Task ForeignCompanyUpdateNeverExecutesValidationOrPersistence()
    {
        var repository = new RecordingRepository { Existing = new() { Id = 1, FkidEmpresaSis = 99 } };
        var service = Create(repository);
        var validated = false;
        service.AddValidationRuleWithId("scope", (_, _) => { validated = true; return Task.FromResult(true); });

        await Assert.ThrowsAsync<KeyNotFoundException>(() => service.UpdateAsync(1, new()));
        Assert.False(validated);
        Assert.Equal(0, repository.Updates);
    }

    private static GenericService<Record, Record, Record> Create(RecordingRepository repository) =>
        new(repository, new FixedUserContext(7, 3));

    public sealed class Record
    {
        public int Id { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public int FkidEmpresaSis { get; set; }
        public bool Activo { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
    }

    private sealed class RecordingRepository : IRepository<Record>
    {
        public Record Existing { get; set; } = new();
        public Record? Saved { get; private set; }
        public int Adds { get; private set; }
        public int Updates { get; private set; }
        public Task<Record> GetByIdAsync(int id) => Task.FromResult(Existing);
        public Task<Record> GetByIdAsync(short id) => GetByIdAsync((int)id);
        public Task AddAsync(Record entity) { Adds++; Saved = entity; return Task.CompletedTask; }
        public Task UpdateAsync(Record entity, byte[]? originalRowVersion = null) { Updates++; return Task.CompletedTask; }
        public Task<IEnumerable<Record>> GetAllAsync() => Task.FromResult<IEnumerable<Record>>([Existing]);
        public Task DeleteAsync(int id) => throw new NotSupportedException();
        public Task SoftDeleteAsync(int id, string? activePropertyName = "Activo") => throw new NotSupportedException();
        public Task<bool> HasActiveChildrenAsync<TChild>(string childForeignKeyProperty, int parentId, string? childActiveProperty = "Activo") where TChild : class => throw new NotSupportedException();
        public Task<IEnumerable<Record>> GetAllWithIncludesAsync(Expression<Func<Record, bool>> filter, params Expression<Func<Record, object>>[] includes) => throw new NotSupportedException();
        public Task<IEnumerable<Record>> GetAllWithIncludes2Async(Expression<Func<Record, bool>> filter, params Expression<Func<Record, object>>[] includes) => throw new NotSupportedException();
        public IQueryable<Record> QueryWithIncludes(Expression<Func<Record, bool>> filter, params Expression<Func<Record, object>>[] includes) => new[] { Existing }.AsQueryable().Where(filter);
    }
}
