using EG.Domain.Interfaces;
using EG.Infraestructure.Models;

namespace EG.Infrastructure;

public sealed class RepositoryProvider(EGestionContext context) : IRepositoryProvider
{
    public IRepository<TEntity> For<TEntity>() where TEntity : class => new Repository<TEntity>(context);
}
