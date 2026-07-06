using Mapster;
using EG.Business.Interfaces;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;


namespace EG.Business.Services
{
    public class EmpresaService(IRepository<Empresa> repositorySP) : IEmpresaService
    {
        private readonly IRepository<Empresa> _repository = repositorySP;


        public async Task<IEnumerable<EmpresaDto>> GetAllEmpresasAsync()
        {
            var empresas = await _repository.GetAllAsync();
            return empresas.Adapt<IEnumerable<EmpresaDto>>();
        }

        public async Task<EmpresaDto?> GetEmpresaByIdAsync(int empresaId)
        {
            var item = await _repository.GetByIdAsync(short.Parse(empresaId.ToString()));
            return item != null ? item.Adapt<EmpresaDto>() : null;
        }

        public async Task AddEmpresaAsync(EmpresaDto dto)
        {
            var item = dto.Adapt<Empresa>();
            await _repository.AddAsync(item);
        }

        public async Task UpdateEmpresaAsync(int empresaId, EmpresaDto dto)
        {
            var existingEmpresa = await _repository.GetByIdAsync(empresaId);
            if (existingEmpresa == null)
                throw new KeyNotFoundException($"Empresa {empresaId} No encontrada.");

            EntityUpdateMapper.Apply(dto, existingEmpresa);
            await _repository.UpdateAsync(existingEmpresa);
        }

        public async Task UpdateUserEmpresaAsync(int empresaId, EmpresaDto dto)
        {
            var existingEmpresa = await _repository.GetByIdAsync(empresaId);
            if (existingEmpresa == null)
                throw new KeyNotFoundException($"Empresa {empresaId} No encontrada.");

            EntityUpdateMapper.Apply(dto, existingEmpresa);
            await _repository.UpdateAsync(existingEmpresa);
        }

        public async Task DeleteEmpresaAsync(int empresaId)
        {
            var empresa = await _repository.GetByIdAsync(empresaId);
            if (empresa == null)
                throw new KeyNotFoundException($"Empresa {empresaId} No encontrada.");

            await _repository.DeleteAsync(empresaId);
        }

    }
}
