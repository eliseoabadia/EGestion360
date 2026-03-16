using AutoMapper;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico
{
    public class ArticuloConteoMappingProfile : Profile
    {
        public ArticuloConteoMappingProfile()
        {
            // ArticuloConteo <-> ArticuloConteoDto
            CreateMap<ArticuloConteo, ArticuloConteoDto>()
                .ReverseMap()
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore());

            // ArticuloConteo -> ArticuloConteoResponse
            CreateMap<ArticuloConteo, ArticuloConteoResponse>();

            // VwArticuloConteo (view entity) -> ArticuloConteoDto
            // Used when receiving a view model as input for create/update
            CreateMap<VwArticuloConteo, ArticuloConteoDto>()
                .ForMember(dest => dest.PkidArticuloConteo, opt => opt.MapFrom(src => src.Id))
                .ForMember(dest => dest.FkidPeriodoConteoAlma, opt => opt.MapFrom(src => src.PeriodoId))
                .ForMember(dest => dest.FkidTipoBienAlma, opt => opt.MapFrom(src => src.TipoBienId))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.MapFrom(src => src.SucursalId))
                .ForMember(dest => dest.FkidEstatusAlma, opt => opt.MapFrom(src => src.EstatusId))
                .ForMember(dest => dest.FkidUsuarioConcluyoSis, opt => opt.MapFrom(src => src.UsuarioConcluyoId))
                // Ignore properties that are not part of the entity DTO
                /*.ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())*/
                ;

            // VwArticuloConteo -> VwArticuloConteoResponse
            CreateMap<VwArticuloConteo, ArticuloConteoResponse>();
        }
    }
}