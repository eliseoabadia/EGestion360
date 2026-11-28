using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Application.Interfaces.Contabilidad;
using EG.Business.Interfaces;

namespace EG.ApiCoreBS.Services.Contabilidad;

public sealed class MatrizConversionService(IMatrizConversionOperations service) : IMatrizConversionService
{
    public Task<IEnumerable<MatrizConversionResponse>> GetAllAsync() => service.GetAllAsync();
    public Task<MatrizConversionResponse?> GetByIdAsync(int id) => service.GetByIdAsync(id);
    public Task<MatrizConversionResponse> AddAsync(MatrizConversionDto dto, int usuarioId) => service.AddAsync(dto, usuarioId);
    public Task UpdateAsync(int id, MatrizConversionDto dto, int usuarioId) => service.UpdateAsync(id, dto, usuarioId);
    public Task DeleteAsync(int id) => service.DeleteAsync(id);
    public Task<PagedResult<MatrizConversionResponse>> GetAllPaginadoAsync(PagedRequest request, Dictionary<string, object>? additionalFilters = null) => service.GetAllPaginadoAsync(request, additionalFilters);
    public Task<bool> CanAddAsync(MatrizConversionDto dto) => service.CanAddAsync(dto);
    public Task<bool> CanUpdateAsync(int id, MatrizConversionDto dto) => service.CanUpdateAsync(id, dto);
    public Task<bool> ExisteRegistroAsync(int anioSis, int programaPres, int partidaSis, int tipoGastoPres) => service.ExisteRegistroAsync(anioSis, programaPres, partidaSis, tipoGastoPres);
    public Task<bool> ExisteRegistroUpdateAsync(int id, int anioSis, int programaPres, int partidaSis, int tipoGastoPres) => service.ExisteRegistroUpdateAsync(id, anioSis, programaPres, partidaSis, tipoGastoPres);
    public Task<IEnumerable<dynamic>> GetProgramasAsync(int? idAnio = null) => service.GetProgramasAsync(idAnio);
}
