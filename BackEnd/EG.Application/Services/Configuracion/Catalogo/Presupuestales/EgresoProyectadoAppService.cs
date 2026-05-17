using EG.Application.Interfaces.Configuracion.Catalogo.Presupuestales;
using EG.Application.Services.Adquisicion;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Configuracion.Catalogo.Presupuestales
{
    public class EgresoProyectadoAppService
        : AdquisicionCrudAppService<EgresoProyectado, VwEgresoProyectado, EgresoProyectadoDto, EgresoProyectadoResponse>,
            IEgresoProyectadoAppService
    {
        public EgresoProyectadoAppService(
            GenericService<EgresoProyectado, EgresoProyectadoDto, EgresoProyectadoResponse> service,
            GenericService<VwEgresoProyectado, EgresoProyectadoDto, EgresoProyectadoResponse> serviceView)
            : base(
                service,
                serviceView,
                "PkidEgresoProyectado",
                "Anteproyecto de egresos",
                (dto, id) => dto.PkidEgresoProyectado = id)
        {
        }
    }
}
