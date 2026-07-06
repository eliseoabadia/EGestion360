using EG.Application.Interfaces.Configuracion.Catalogo.Tesoreria;
using EG.Application.Modules.GRP.Services.Configuracion.Catalogo;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Tesoreria
{
    public class TipoSolicitudCLCService(GenericService<TipoSolicitudClc, TipoSolicitudCLCDto, TipoSolicitudCLCResponse> service)
        : GenericCatalogService<TipoSolicitudClc, TipoSolicitudCLCDto, TipoSolicitudCLCResponse>(service), ITipoSolicitudCLCService;
}
