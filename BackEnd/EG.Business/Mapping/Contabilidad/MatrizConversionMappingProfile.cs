using AutoMapper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class MatrizConversionMappingProfile : Profile
    {
        public MatrizConversionMappingProfile()
        {
            CreateMap<MatrizConversion, MatrizConversionDto>().ReverseMap();
            CreateMap<MatrizConversion, MatrizConversionResponse>();
            CreateMap<MatrizConversionResponse, MatrizConversionDto>()
                .ForMember(dest => dest.PkidMatrizConversion, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
