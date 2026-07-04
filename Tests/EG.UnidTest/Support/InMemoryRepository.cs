using System.Linq.Expressions;
using EG.Domain.Interfaces;

namespace EG.UnidTest.Support;

internal sealed class InMemoryRepository<T>(IEnumerable<T> source) : IRepository<T>
    where T : class
{
    private readonly IReadOnlyCollection<T> _source = source.ToArray();

    public Task<IEnumerable<T>> GetAllAsync()
    {
        return Task.FromResult<IEnumerable<T>>(_source);
    }

    public Task<T> GetByIdAsync(short id)
    {
        throw new NotSupportedException();
    }

    public Task<T> GetByIdAsync(int id)
    {
        throw new NotSupportedException();
    }

    public Task AddAsync(T entity)
    {
        throw new NotSupportedException();
    }

    public Task UpdateAsync(T entity)
    {
        throw new NotSupportedException();
    }

    public Task DeleteAsync(int id)
    {
        throw new NotSupportedException();
    }

    public Task SoftDeleteAsync(int id, string? activePropertyName = "Activo")
    {
        throw new NotSupportedException();
    }

    public Task<bool> HasActiveChildrenAsync<TChild>(
        string childForeignKeyProperty,
        int parentId,
        string? childActiveProperty = "Activo")
        where TChild : class
    {
        throw new NotSupportedException();
    }

    public Task<IEnumerable<T>> GetAllWithIncludesAsync(
        Expression<Func<T, bool>> filter,
        params Expression<Func<T, object>>[] includes)
    {
        return Task.FromResult<IEnumerable<T>>(_source.AsQueryable().Where(filter).ToArray());
    }

    public Task<IEnumerable<T>> GetAllWithIncludes2Async(
        Expression<Func<T, bool>> filter,
        params Expression<Func<T, object>>[] includes)
    {
        return GetAllWithIncludesAsync(filter, includes);
    }

    public IQueryable<T> QueryWithIncludes(
        Expression<Func<T, bool>> filter,
        params Expression<Func<T, object>>[] includes)
    {
        return new TestAsyncEnumerable<T>(_source.AsQueryable().Where(filter));
    }
}
