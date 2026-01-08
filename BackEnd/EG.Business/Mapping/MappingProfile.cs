using AutoMapper;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;



namespace EG.Business.Mapping
{
    public class MappingProfile : Profile
    {
        public MappingProfile()
        {
            CreateMap<Empresa, EmpresaDto>().ReverseMap();
            CreateMap<Usuario, UsuarioDto>().ReverseMap();
            CreateMap<Usuario, UsuarioResponse>().ReverseMap();
            CreateMap<LoginInformationEmployeeResult, UserResponse>().ReverseMap();
            CreateMap<PerfilUsuario, PerfilUsuarioResponse>().ReverseMap();
            CreateMap<PerfilUsuarioResponse, PerfilUsuario>()
               .ForMember(dest => dest.FechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.Ignore())
                .ForMember(dest => dest.FkidUsuarioSisNavigation, opt => opt.Ignore())
                .ReverseMap();

            CreateMap<LoginInformationEmployeeResult, LoginInformationEmployeeResult>().ReverseMap();
            CreateMap<spNodeMenuResponse, spNodeMenuResult>().ReverseMap();
        }
    }
}