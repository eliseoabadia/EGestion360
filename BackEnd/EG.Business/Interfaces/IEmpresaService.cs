using EG.Dommain.DTOs.Responses;

namespace EG.Business.Interfaces
{
    public interface IEmpresaService
    {
        Task<IEnumerable<EmpresaDto>> GetAllEmpresasAsync();
        Task<EmpresaDto?> GetEmpresaByIdAsync(int empresaId);
        Task AddEmpresaAsync(EmpresaDto dto);
        Task UpdateEmpresaAsync(int empresaId, EmpresaDto dto);
        Task UpdateUserEmpresaAsync(int empresaId, EmpresaDto dto);
        Task DeleteEmpresaAsync(int empresaId);

    }
}
