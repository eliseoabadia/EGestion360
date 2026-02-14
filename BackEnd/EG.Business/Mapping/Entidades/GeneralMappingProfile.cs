using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;

namespace EG.Business.Mapping.Entidades
{
    public class GeneralMappingProfile : Profile
    {
        public GeneralMappingProfile()
        {
            CreateMap<Empresa, EmpresaResponse>().ReverseMap();
            CreateMap<Usuario, UsuarioResponse>().ReverseMap();

            // Entity -> Response
            CreateMap<Estado, EstadoResponse>()
                .ForMember(dest => dest.PkidEstado, opt => opt.MapFrom(src => src.PkidEstado))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre));

            // DTO -> Entity
            CreateMap<EstadoDto, Estado>()
                .ForMember(dest => dest.PkidEstado, opt => opt.MapFrom(src => src.PkidEstado))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre));

            // Response -> DTO (si es necesario)
            CreateMap<EstadoResponse, EstadoDto>()
                .ForMember(dest => dest.PkidEstado, opt => opt.MapFrom(src => src.PkidEstado))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre));

            CreateMap<LoginInformationEmployeeResult, UserResponse>().ReverseMap();
            CreateMap<spNodeMenuResponse, spNodeMenuResult>().ReverseMap();
            //CreateMap<DepartamentoResponse, DepartamentoDto>().ReverseMap();
            CreateMap<PerfilUsuarioResponse, PerfilUsuario>()
                .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.FkidUsuarioSisNavigation, opt => opt.Ignore())
                .ReverseMap();
        }
    }
}