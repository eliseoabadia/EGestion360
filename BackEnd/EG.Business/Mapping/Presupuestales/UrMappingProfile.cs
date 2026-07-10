using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class UrMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Ur, UrDto>().TwoWays();
            config.NewConfig<Ur, UrResponse>();
            config.NewConfig<UrResponse, UrDto>()
                .Ignore(dest => dest.PkidUr)
                .IgnoreNullValues(true);
        }
    }
}
