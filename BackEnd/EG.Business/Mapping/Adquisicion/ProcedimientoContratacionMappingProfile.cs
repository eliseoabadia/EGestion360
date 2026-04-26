using AutoMapper;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class ProcedimientoContratacionMappingProfile : Profile
    {
        public ProcedimientoContratacionMappingProfile()
        {
            CreateMap<ProcedimientoContratacion, ProcedimientoContratacionDto>().ReverseMap();
            CreateMap<ProcedimientoContratacion, ProcedimientoContratacionResponse>();
            CreateMap<ProcedimientoContratacionResponse, ProcedimientoContratacionDto>()
                .ForMember(dest => dest.PkidProcedimientoContratacion, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}