namespace EG.Builder.Templates;
public static class AppSerices
{
    public static string ItemService =
@"using AutoMapper;
using EG.Application.DTOs.General;
using EG.Application.Interfaces.Configuration;
using EG.Infrastructure.Models;
using EG.Infrastructure.Storage;


namespace EG.Application.Services.Configuration
{
    public class TABLENAMEService : ITABLENAMEService
    {
        private readonly IRepository<TABLENAME> _repository;
        private readonly IMapper _mapper;

        public TABLENAMEService(IRepository<TABLENAME> _Repository, IMapper mapper)
        {
            _repository = _Repository;
            _mapper = mapper;
        }

        public async Task<IEnumerable<TABLENAME>> GetAllTABLENAMEAsync()
        {
            var items = await _repository.GetAllAsync();
            return _mapper.Map<IEnumerable<TABLENAME>>(items);
        }

        public async Task<TABLENAME?> GetTABLENAMEByIdAsync(int itemId)
        {
            var item = await _repository.GetByIdAsync(itemId);
            return item != null ? _mapper.Map<TABLENAME>(item) : null;
        }

        public async Task CreateTABLENAME(TABLENAME dto)
        {
            var item = _mapper.Map<TABLENAME>(dto);
            await _repository.AddAsync(item);
        }

        public async Task SetTABLENAME(int itemId, TABLENAME dto)
        {
            var item = await _repository.GetByIdAsync(itemId);
            if (item == null)
                throw new KeyNotFoundException($""TABLENAME {itemId} No encontrada."");

            _mapper.Map(dto, item);
            await _repository.UpdateAsync(item);
        }


        public async Task DeleteTABLENAME(int itemId)
        {
            var item = await _repository.GetByIdAsync(UsuaritemIdioId);
            if (item == null)
                throw new KeyNotFoundException($""TABLENAME {itemId} No encontrada."");

            await _repository.DeleteAsync(itemId);
        }


    }

}

";

    public static string IItemService =
@"using EG.Application.DTOs.General;
using EG.Infrastructure.Models;

namespace EG.Application.Interfaces.Configuration;
public interface ITABLENAMEService
{
    
    Task<IEnumerable<TABLENAME>> GetAllTABLENAMEAsync();
    Task<TABLENAME?> GetTABLENAMEByIdAsync(int itemId);
    Task CreateTABLENAME(TABLENAME dto);
    Task SetTABLENAME(int itemId, TABLENAME dto);
    Task DeleteTABLENAME(int itemId);
    
}

";
}

