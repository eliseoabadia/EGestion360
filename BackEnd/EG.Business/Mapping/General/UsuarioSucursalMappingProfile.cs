using Mapster;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class UsuarioSucursalMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // Mapeo de Entidad -> DTO de creación/actualización
            config.NewConfig<UsuarioSucursal, UsuarioSucursalDto>().TwoWays();

            // Mapeo de la Vista -> Response DTO (proyección completa)
            config.NewConfig<VwUsuarioSucursal, UsuarioSucursalResponse>();
        }
    }
}