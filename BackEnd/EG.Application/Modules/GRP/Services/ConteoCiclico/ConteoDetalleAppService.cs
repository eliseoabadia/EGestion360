using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Application.Interfaces.ConteoCiclico;
using EG.Business.Interfaces;

namespace EG.Application.Services.ConteoCiclico;

public sealed class ConteoDetalleAppService(IConteoDetalleOperations service) : IConteoDetalleAppService
{
    public Task<PagedResult<BienResponse>> BuscarBienes(string? filtro, string? tipoBienCodigo, int page = 1, int pageSize = 20) => service.BuscarBienes(filtro, tipoBienCodigo, page, pageSize);
    public Task<PagedResult<BienResponse>> BuscarPorCodigo(string codigo, string? tipoBienCodigo = null) => service.BuscarPorCodigo(codigo, tipoBienCodigo);
    public Task<PagedResult<ConteoDetalleResponse>> AgregarBien(AgregarBienConteoDto dto, int usuarioActual) => service.AgregarBien(dto, usuarioActual);
    public Task<PagedResult<ConteoDetalleResponse>> GetPorConteo(int conteoId) => service.GetPorConteo(conteoId);
    public Task<PagedResult<ConteoDetalleResponse>> ActualizarCantidad(int id, decimal cantidad, int usuarioActual) => service.ActualizarCantidad(id, cantidad, usuarioActual);
    public Task<PagedResult<bool>> Delete(int id) => service.Delete(id);
}
