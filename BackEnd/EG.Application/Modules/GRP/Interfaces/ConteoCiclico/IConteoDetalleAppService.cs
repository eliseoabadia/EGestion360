using EG.Common.GenericModel;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;

namespace EG.Application.Interfaces.ConteoCiclico
{
    public interface IConteoDetalleAppService
    {
        Task<PagedResult<BienResponse>> BuscarBienes(string? filtro, string? tipoBienCodigo, int page = 1, int pageSize = 20);
        Task<PagedResult<BienResponse>> BuscarPorCodigo(string codigo, string? tipoBienCodigo = null);
        Task<PagedResult<ConteoDetalleResponse>> AgregarBien(AgregarBienConteoDto dto, int usuarioActual);
        Task<PagedResult<ConteoDetalleResponse>> GetPorConteo(int conteoId);
        Task<PagedResult<ConteoDetalleResponse>> ActualizarCantidad(int id, decimal cantidad, int usuarioActual);
        Task<PagedResult<bool>> Delete(int id);
    }
}
