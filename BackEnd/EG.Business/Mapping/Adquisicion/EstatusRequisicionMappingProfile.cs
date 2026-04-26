using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class EstatusRequisicionMappingProfile : Profile
    {
        public EstatusRequisicionMappingProfile()
        {
            CreateMap<EstatusRequisicion, EstatusRequisicionDto>().ReverseMap();
            CreateMap<EstatusRequisicion, EstatusRequisicionResponse>();
            CreateMap<EstatusRequisicionResponse, EstatusRequisicionDto>()
                .ForMember(dest => dest.PkidEstatusRequisicion, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}