using AutoMapper;
using EG.Business.Interfaces;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.Entities;
using EG.Domain.Interfaces;


namespace EG.Business.Services
{
    public class EmpresaService(IRepository<Empresa> repositorySP,
                IMapper mapper) : IEmpresaService
    {
        private readonly IRepository<Empresa> _repository = repositorySP;
        private readonly IMapper _mapper = mapper;


        public async Task<IEnumerable<EmpresaDto>> GetAllEmpresasAsync()
        {
            var empresas = await _repository.GetAllAsync();
            return _mapper.Map<IEnumerable<EmpresaDto>>(empresas);
        }

        public async Task<EmpresaDto?> GetEmpresaByIdAsync(int empresaId)
        {
            var item = await _repository.GetByIdAsync(short.Parse(empresaId.ToString()));
            return item != null ? _mapper.Map<EmpresaDto>(item) : null;
        }

        public async Task AddEmpresaAsync(EmpresaDto dto)
        {
            var item = _mapper.Map<Empresa>(dto);
            await _repository.AddAsync(item);
        }

        public async Task UpdateEmpresaAsync(int empresaId, EmpresaDto dto)
        {
            var existingEmpresa = await _repository.GetByIdAsync(empresaId);
            if (existingEmpresa == null)
                throw new KeyNotFoundException($"Empresa {empresaId} No encontrada.");

            _mapper.Map(dto, existingEmpresa);
            await _repository.UpdateAsync(existingEmpresa);
        }

        public async Task UpdateUserEmpresaAsync(int empresaId, EmpresaDto dto)
        {
            var existingEmpresa = await _repository.GetByIdAsync(empresaId);
            if (existingEmpresa == null)
                throw new KeyNotFoundException($"Empresa {empresaId} No encontrada.");

            _mapper.Map(dto, existingEmpresa);
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