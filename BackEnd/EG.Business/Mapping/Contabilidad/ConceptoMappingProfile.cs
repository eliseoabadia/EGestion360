using Mapster;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class ConceptoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Concepto, ConceptoDto>().TwoWays();
            config.NewConfig<Concepto, ConceptoResponse>();
            config.NewConfig<VwConcepto, ConceptoResponse>();
            config.NewConfig<ConceptoResponse, ConceptoDto>()
                .Ignore(dest => dest.PkidConcepto)
                .IgnoreNullValues(true);
        }
    }
}
