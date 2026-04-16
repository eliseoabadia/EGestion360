using AutoMapper;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico;

public class PeriodoConteoMappingProfile : Profile
{
    public PeriodoConteoMappingProfile()
    {
        CreateMap<PeriodoConteo, PeriodoConteoDto>().ReverseMap()
            .ForMember(dest => dest.FkidEstatusAlmaNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidResponsableSisNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidSucursalSisNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidSupervisorSisNavigation, opt => opt.Ignore())
            .ForMember(dest => dest.FkidTipoConteoAlmaNavigation, opt => opt.Ignore());

        CreateMap<VwPeriodoConteo, PeriodoConteoResponse>();

        CreateMap<PeriodoConteoResponse, PeriodoConteoDto>()
            .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.IdSucursal ?? 0))
            .ForMember(dest => dest.FkidTipoConteoAlma, opt => opt.MapFrom(src => src.IdTipoConteo ?? 0))
            .ForMember(dest => dest.FkidEstatusAlma, opt => opt.MapFrom(src => src.IdEstatusPeriodo ?? 1))
            .ForMember(dest => dest.FkidResponsableSis, opt => opt.MapFrom(src => src.IdResponsable))
            .ForMember(dest => dest.FkidSupervisorSis, opt => opt.MapFrom(src => src.IdSupervisor));
    }
}
