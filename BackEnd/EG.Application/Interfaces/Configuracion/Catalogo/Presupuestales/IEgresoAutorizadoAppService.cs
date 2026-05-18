using EG.Application.Interfaces.Adquisicion;
using EG.Common.GenericModel;
using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales
{
    public interface IEgresoAutorizadoAppService : IAdquisicionCrudAppService<EgresoAutorizadoResponse>
    {
        Task<PagedResult<EgresoAutorizadoResponse>> AutorizarProyectadoAsync(
            int pkidEgresoProyectado,
            int usuarioActual,
            int? fkidPolizaConta,
            string? descripcion);

        Task<PagedResult<bool>> RegresarAProyectadoAsync(int pkidEgresoAutorizado, int usuarioActual);
    }
}
