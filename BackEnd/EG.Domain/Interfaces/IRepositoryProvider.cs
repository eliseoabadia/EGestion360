namespace EG.Domain.Interfaces;

public interface IRepositoryProvider
{
    IRepository<TEntity> For<TEntity>() where TEntity : class;
}
