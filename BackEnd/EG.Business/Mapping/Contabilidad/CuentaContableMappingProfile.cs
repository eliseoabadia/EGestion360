using AutoMapper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class CuentaContableMappingProfile : Profile
    {
        public CuentaContableMappingProfile()
        {
            CreateMap<CuentaContable, CuentaContableDto>().ReverseMap();
            CreateMap<CuentaContable, CuentaContableResponse>();
            CreateMap<CuentaContableResponse, CuentaContableDto>()
                .ForMember(dest => dest.PkidCuentaContable, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
