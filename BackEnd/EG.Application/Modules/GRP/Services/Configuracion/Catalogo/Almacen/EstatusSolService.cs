using EG.Application.Interfaces.Configuracion.Catalogo.Almacen;
using EG.Application.Modules.GRP.Services.Configuracion.Catalogo;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Almacen
{
    public class EstatusSolService(GenericService<EstatusSolicitud, EstatusSolicitudDto, EstatusSolicitudResponse> service)
        : GenericCatalogService<EstatusSolicitud, EstatusSolicitudDto, EstatusSolicitudResponse>(service), IEstatusSolService;
}
