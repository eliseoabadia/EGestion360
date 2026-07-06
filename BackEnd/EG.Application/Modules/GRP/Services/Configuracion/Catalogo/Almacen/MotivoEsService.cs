using EG.Application.Interfaces.Configuracion.Catalogo.Almacen;
using EG.Application.Modules.GRP.Services.Configuracion.Catalogo;
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Infraestructure.Models;

namespace EG.ApiCoreBS.Services.Configuracion.Catalogo.Almacen
{
    public class MotivoEsService(GenericService<Motivo, MotivoEsDto, MotivoEsResponse> service)
        : GenericCatalogService<Motivo, MotivoEsDto, MotivoEsResponse>(service), IMotivoEsService;
}
