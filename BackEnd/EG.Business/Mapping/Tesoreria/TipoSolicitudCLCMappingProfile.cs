using Mapster;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class TipoSolicitudCLCMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoSolicitudClc, TipoSolicitudCLCDto>().TwoWays();
            config.NewConfig<TipoSolicitudClc, TipoSolicitudCLCResponse>().TwoWays();
            config.NewConfig<TipoSolicitudCLCResponse, TipoSolicitudCLCDto>()
                .Ignore(dest => dest.PkidTipoSolicitudClc)
                .IgnoreNullValues(true);
        }
    }
}
