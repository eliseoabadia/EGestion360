using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IEgresoProyectadoAppService : IAdquisicionCrudAppService<EgresoProyectadoResponse>
    {
        Task<PagedResult<bool>> EstaAutorizadoAsync(int id);
    }
}
