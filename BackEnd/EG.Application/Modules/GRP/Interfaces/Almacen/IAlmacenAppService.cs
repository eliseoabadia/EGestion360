using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Almacen;

namespace EG.Application.Interfaces.Almacen
{
    public interface IAlmacenAppService : IAdquisicionCrudAppService<AlmacenResponse>
    {
        Task<PagedResult<AlmacenResponse>> CreateSalidaAjusteAsync(int origenId, AlmacenResponse response, int usuarioActual);
    }
}
