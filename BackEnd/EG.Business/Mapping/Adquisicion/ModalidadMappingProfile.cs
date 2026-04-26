using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class ModalidadMappingProfile : Profile
    {
        public ModalidadMappingProfile()
        {
            CreateMap<Modalidad, ModalidadDto>().ReverseMap();
            CreateMap<Modalidad, ModalidadResponse>();
            CreateMap<ModalidadResponse, ModalidadDto>()
                .ForMember(dest => dest.PkidModalidad, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}