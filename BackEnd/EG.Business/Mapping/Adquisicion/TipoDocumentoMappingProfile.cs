using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class TipoDocumentoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<TipoDocumento, TipoDocumentoDto>().TwoWays();
            config.NewConfig<TipoDocumento, TipoDocumentoResponse>();
            config.NewConfig<TipoDocumentoResponse, TipoDocumentoDto>()
                .Ignore(dest => dest.PkidTipoDocumento)
                .IgnoreNullValues(true);
        }
    }
}