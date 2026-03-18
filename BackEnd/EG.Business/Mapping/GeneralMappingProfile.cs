using AutoMapper;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Domain.DTOs.Responses.General;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping
{
    public class GeneralMappingProfile : Profile
    {
        public GeneralMappingProfile()
        {
            CreateMap<Empresa, EmpresaResponse>().ReverseMap();
            CreateMap<Usuario, UsuarioResponse>().ReverseMap();

            CreateMap<TipoConteo, TipoConteoDto>().ReverseMap();
            CreateMap<TipoConteo, TipoConteoResponse>(); 
            CreateMap<TipoConteoResponse, TipoConteoDto>();

            CreateMap<TipoBien, TipoBienDto>().ReverseMap();
            CreateMap<TipoBien, TipoBienResponse>().ReverseMap();
            CreateMap<TipoBienResponse, TipoBienDto>().ReverseMap();

            CreateMap<EstatusPeriodo, EstatusPeriodoResponse>().ReverseMap();
            CreateMap<EstatusPeriodoDto, EstatusPeriodo>().ReverseMap();
            CreateMap<EstatusPeriodoResponse, EstatusPeriodoDto>().ReverseMap();

            CreateMap<EstatusArticuloConteo, EstatusArticuloConteoResponse>().ReverseMap();
            CreateMap<EstatusArticuloConteoDto, EstatusArticuloConteo>().ReverseMap();
            CreateMap<EstatusArticuloConteoResponse, EstatusArticuloConteoDto>().ReverseMap();

            CreateMap<RegistroConteo, RegistroConteoDto>().ReverseMap();
            CreateMap<RegistroConteo, RegistroConteoResponse>().ReverseMap();
            CreateMap<RegistroConteoResponse, RegistroConteoDto>().ReverseMap();

            CreateMap<Sucursal, SucursalDto>().ReverseMap();
            CreateMap<SucursalResponse, SucursalDto>();
            CreateMap<Sucursal, SucursalResponse>().ReverseMap();

            CreateMap<Departamento, DepartamentoDto>().ReverseMap();
            CreateMap<DepartamentoResponse, DepartamentoDto>().ReverseMap();

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