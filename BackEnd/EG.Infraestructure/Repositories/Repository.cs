using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;
using System.Reflection;

namespace EG.Infrastructure
{
    public class Repository<T> : IRepository<T> where T : class
    {
        private readonly EGestionContext _context;
        private readonly DbSet<T> _dbSet;

        public Repository(EGestionContext context)
        {
            _context = context;
            _dbSet = _context.Set<T>();
        }

        public async Task AddAsync(T entity)
        {
            await _dbSet.AddAsync(entity);
            await _context.SaveChangesAsync();
        }

        public async Task DeleteAsync(int id)
        {
            var entity = await GetByIdAsync(id);
            if (entity != null)
            {
                _dbSet.Remove(entity);
                await _context.SaveChangesAsync();
            }
        }

        public async Task SoftDeleteAsync(int id, string? activePropertyName = "Activo")
        {
            var entity = await GetByIdAsync(id);
            if (entity == null) return;

            var prop = typeof(T).GetProperty(activePropertyName ?? "Activo", BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
            if (prop != null && prop.PropertyType == typeof(bool))
            {
                prop.SetValue(entity, false);
                _dbSet.Update(entity);
                await _context.SaveChangesAsync();
            }
            else
            {
                _dbSet.Remove(entity);
                await _context.SaveChangesAsync();
            }
        }

        public async Task<bool> HasActiveChildrenAsync<TChild>(string childForeignKeyProperty, int parentId, string? childActiveProperty = "Activo") where TChild : class
        {
            var childSet = _context.Set<TChild>();
            var prop = typeof(TChild).GetProperty(childActiveProperty ?? "Activo", BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);

            IQueryable<TChild> query = childSet;

            if (prop != null && prop.PropertyType == typeof(bool))
            {
                var param = Expression.Parameter(typeof(TChild), "e");
                var propAccess = Expression.Property(param, prop);
                var condition = Expression.Equal(propAccess, Expression.Constant(true, typeof(bool)));
                var lambda = Expression.Lambda<Func<TChild, bool>>(condition, param);
                query = query.Where(lambda);
            }

            var fkProp = typeof(TChild).GetProperty(childForeignKeyProperty, BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
            if (fkProp == null) return false;

            var param2 = Expression.Parameter(typeof(TChild), "e");
            var fkAccess = Expression.Property(param2, fkProp);
            var fkCondition = Expression.Equal(fkAccess, Expression.Constant(parentId, fkProp.PropertyType));
            var fkLambda = Expression.Lambda<Func<TChild, bool>>(fkCondition, param2);
            query = query.Where(fkLambda);

            return await query.AnyAsync();
        }

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            var query = _dbSet.AsQueryable();
            var activoProperty = typeof(T).GetProperty("Activo", BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
            if (activoProperty != null && activoProperty.PropertyType == typeof(bool))
            {
                var param = Expression.Parameter(typeof(T), "e");
                var propAccess = Expression.Property(param, activoProperty);
                var condition = Expression.Equal(propAccess, Expression.Constant(true, typeof(bool)));
                var lambda = Expression.Lambda<Func<T, bool>>(condition, param);
                query = query.Where(lambda);
            }
            return await query.ToListAsync();
        }

        public async Task<T> GetByIdAsync(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            return entity;
        }

        public async Task<T> GetByIdAsync(short id)
        {
            var entity = await _dbSet.FindAsync(id);
            return entity;
        }


        public async Task UpdateAsync(T entity)
        {
            var entry = _context.Entry(entity);
            if (entry.State == EntityState.Detached)
            {
                _dbSet.Attach(entity);
                entry.State = EntityState.Modified;
            }
            await _context.SaveChangesAsync();
        }

        public async Task<IEnumerable<T>> GetAllWithIncludesAsync(Expression<Func<T, bool>> filter, params Expression<Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet;

            if (filter != null)
            {
                query = query.Where(filter);
            }

            foreach (var include in includes)
            {
                query = query.Include(include);
            }

            return await query.ToListAsync();
        }

        public async Task<IEnumerable<T>> GetAllWithIncludes2Async( Expression<Func<T, bool>> filter,  params Expression<Func<T, object>>[] includes)
        {
            try
            {
                IQueryable<T> query = _dbSet.AsQueryable();

                foreach (var include in includes)
                {
                    query = query.Include(include);
                }

                if (filter != null)
                {
                    query = query.Where(filter);
                }

                var sql = query.ToQueryString();
                Console.WriteLine($"SQL generado: {sql}");

                return await query.AsNoTracking().ToListAsync();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error en GetAllWithIncludesAsync: {ex.Message}");
                throw;
            }
        }

        public IQueryable<T> QueryWithIncludes(Expression<Func<T, bool>> filter, params Expression<Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet.AsQueryable();

            foreach (var include in includes)
            {
                query = query.Include(include);
            }

            if (filter != null)
            {
                query = query.Where(filter);
            }

            return query.AsNoTracking();
        }


    }
}