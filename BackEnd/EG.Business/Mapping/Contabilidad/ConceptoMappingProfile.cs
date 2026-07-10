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
            config.NewConfig<Concepto, ConceptoResponse>()
                .Map(dest => dest.FkidCapituloSis, src => src.FkidCapituloConta);
            config.NewConfig<VwConcepto, ConceptoResponse>();
            config.NewConfig<ConceptoResponse, ConceptoDto>()
                .Ignore(dest => dest.PkidConcepto)
                .Map(dest => dest.FkidCapituloConta, src => src.FkidCapituloSis)
                .IgnoreNullValues(true);
        }
    }
}
