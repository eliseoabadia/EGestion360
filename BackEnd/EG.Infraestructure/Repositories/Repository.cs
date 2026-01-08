using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;
using System.Linq.Expressions;

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

        public async Task<IEnumerable<T>> GetAllAsync()
        {
            return await _dbSet.ToListAsync();
        }

        public async Task<T> GetByIdAsync(int id)
        {
            var entity = await _dbSet.FindAsync(id);
            return entity;
        }

        public async Task<T> GetByIdAsync(short id)
        {
            var entity = await _dbSet.FindAsync(id); //??
                //throw new ArgumentNullException(nameof(id), "El objeto no puede ser nulo.");
            return entity;
        }


        public async Task UpdateAsync(T entity)
        {
            _dbSet.Update(entity);
            await _context.SaveChangesAsync();
        }

        public async Task<IEnumerable<T>> GetAllWithIncludesAsync(Expression<Func<T, bool>> filter, params Expression<Func<T, object>>[] includes)
        {
            IQueryable<T> query = _dbSet;

            if (filter != null)
            {
                query = query.Where(filter); // Apply filter separately
            }

            foreach (var include in includes)
            {
                query = query.Include(include); // Ensure direct property access
            }

            return await query.ToListAsync();
        }

        public async Task<IEnumerable<T>> GetAllWithIncludes2Async( Expression<Func<T, bool>> filter,  params Expression<Func<T, object>>[] includes)
        {
            try
            {
                IQueryable<T> query = _dbSet.AsQueryable();

                // Aplicar includes primero
                foreach (var include in includes)
                {
                    query = query.Include(include);
                }

                // Luego aplicar el filtro
                if (filter != null)
                {
                    query = query.Where(filter);
                }

                // Para diagnóstico: ver la consulta SQL generada
                var sql = query.ToQueryString();
                Console.WriteLine($"SQL generado: {sql}");

                return await query.AsNoTracking().ToListAsync();
            }
            catch (Exception ex)
            {
                // Loggear el error adecuadamente
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