using AutoMapper;
using EG.Domain.DTOs.Requests.Patrimonio;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Patrimonio
{
    public class MarcaMappingProfile : Profile
    {
        public MarcaMappingProfile()
        {
            CreateMap<Marca, MarcaDto>().ReverseMap();
            CreateMap<Marca, MarcaResponse>().ReverseMap();
            CreateMap<MarcaResponse, MarcaDto>()
                .ForMember(dest => dest.PkidMarca, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
