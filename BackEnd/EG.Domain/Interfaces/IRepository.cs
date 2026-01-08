using System.Linq.Expressions;

namespace EG.Domain.Interfaces
{
    public interface IRepository<T> where T : class
    {
        Task<IEnumerable<T>> GetAllAsync();

        Task<T> GetByIdAsync(short id);

        Task<T> GetByIdAsync(int id);

        Task AddAsync(T entity);

        Task UpdateAsync(T entity);

        Task DeleteAsync(int id);

        //Task<IEnumerable<T>> GetAllWithIncludesAsync(params Expression<Func<T, object>>[] includes);

        Task<IEnumerable<T>> GetAllWithIncludesAsync(Expression<Func<T, bool>> filter, params Expression<Func<T, object>>[] includes);
        Task<IEnumerable<T>> GetAllWithIncludes2Async(Expression<Func<T, bool>> filter, params Expression<Func<T, object>>[] includes);

        IQueryable<T> QueryWithIncludes(Expression<Func<T, bool>> filter, params Expression<Func<T, object>>[] includes);


    }
}