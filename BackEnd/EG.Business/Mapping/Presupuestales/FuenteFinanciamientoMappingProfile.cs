using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class FuenteFinanciamientoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<FuenteFinanciamiento, FuenteFinanciamientoDto>().TwoWays();
            config.NewConfig<FuenteFinanciamiento, FuenteFinanciamientoResponse>();
            config.NewConfig<FuenteFinanciamientoResponse, FuenteFinanciamientoDto>()
                .Ignore(dest => dest.PkidFuenteFinanciamiento)
                .IgnoreNullValues(true);
        }
    }
}
