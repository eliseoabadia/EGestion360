using Mapster;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Presupuestales
{
    public class SubFuncionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Sf, SubFuncionDto>().TwoWays();
            config.NewConfig<Sf, SubFuncionResponse>()
                .Map(dest => dest.SubFuncionClave, src => src.Clave)
                .Map(dest => dest.SubFuncionDescripcion, src => src.Descripcion)
                .Map(dest => dest.FuncionClave, src => src.FkidFnPresNavigation != null ? src.FkidFnPresNavigation.Clave : (int?)null)
                .Map(dest => dest.FuncionDescripcion, src => src.FkidFnPresNavigation != null ? src.FkidFnPresNavigation.Descripcion : null)
                .Ignore(dest => dest.SubFuncionClaveNombre)
                .Ignore(dest => dest.FuncionClaveNombre);
            config.NewConfig<VwSubFuncion, SubFuncionDto>()
                .Map(dest => dest.Clave, src => src.SubFuncionClave)
                .Map(dest => dest.Descripcion, src => src.SubFuncionDescripcion)
                .Ignore(dest => dest.PkidSf);
            config.NewConfig<VwSubFuncion, SubFuncionResponse>();
            config.NewConfig<SubFuncionResponse, SubFuncionDto>()
                .Map(dest => dest.Clave, src => src.SubFuncionClave)
                .Map(dest => dest.Descripcion, src => src.SubFuncionDescripcion)
                .IgnoreNullValues(true);
        }
    }
}
