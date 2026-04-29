using AutoMapper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class MatrizIngresoMappingProfile : Profile
    {
        public MatrizIngresoMappingProfile()
        {
            CreateMap<MatrizIngreso, MatrizIngresoDto>().ReverseMap();
            CreateMap<MatrizIngreso, MatrizIngresoResponse>();
            CreateMap<MatrizIngresoResponse, MatrizIngresoDto>()
                .ForMember(dest => dest.PkidMatrizIngreso, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
