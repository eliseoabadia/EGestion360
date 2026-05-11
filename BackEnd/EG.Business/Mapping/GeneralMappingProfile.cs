using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.DTOs.Responses.Presupuestales;
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

            CreateMap<Programa, ProgramaDto>().ReverseMap();
            CreateMap<Programa, ProgramaResponse>();

            //CreateMap<TipoBien, TipoBienDto>().ReverseMap();
            CreateMap<TipoBien, TipoBienResponse>().ReverseMap();
            //CreateMap<TipoBienResponse, TipoBienDto>().ReverseMap();

            //CreateMap<EstatusPeriodo, EstatusPeriodoResponse>().ReverseMap();
            //CreateMap<EstatusPeriodoDto, EstatusPeriodo>().ReverseMap();
            //CreateMap<EstatusPeriodoResponse, EstatusPeriodoDto>().ReverseMap();

            //CreateMap<EstatusArticuloConteo, EstatusArticuloConteoResponse>().ReverseMap();
            //CreateMap<EstatusArticuloConteoDto, EstatusArticuloConteo>().ReverseMap();
            //CreateMap<EstatusArticuloConteoResponse, EstatusArticuloConteoDto>().ReverseMap();

            //CreateMap<RegistroConteo, RegistroConteoDto>().ReverseMap();
            //CreateMap<RegistroConteo, RegistroConteoResponse>().ReverseMap();
            //CreateMap<RegistroConteoResponse, RegistroConteoDto>().ReverseMap();

            CreateMap<Sucursal, SucursalDto>().ReverseMap();
            CreateMap<SucursalResponse, SucursalDto>();
            CreateMap<Sucursal, SucursalResponse>().ReverseMap();

            CreateMap<Departamento, DepartamentoDto>().ReverseMap();
            CreateMap<DepartamentoResponse, DepartamentoDto>().ReverseMap();

            // Entity -> Response
            CreateMap<Estado, EstadoResponse>()
                .ForMember(dest => dest.PkidEstado, opt => opt.MapFrom(src => src.PkidEstado))
                .ForMember(dest => dest.FkidPaisSis, opt => opt.MapFrom(src => src.FkidPaisSis))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.CodigoEstado, opt => opt.MapFrom(src => src.CodigoEstado))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo));

            // Dto -> Entity
            CreateMap<EstadoDto, Estado>()
                .ForMember(dest => dest.PkidEstado, opt => opt.MapFrom(src => src.PkidEstado))
                .ForMember(dest => dest.FkidPaisSis, opt => opt.MapFrom(src => src.FkidPaisSis))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.CodigoEstado, opt => opt.MapFrom(src => src.CodigoEstado))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.EmpresaEstados, opt => opt.Ignore())
                .ForMember(dest => dest.Municipios, opt => opt.Ignore())
                .ForMember(dest => dest.Proveedors, opt => opt.Ignore())
                .ForMember(dest => dest.Sucursals, opt => opt.Ignore())
                .ForMember(dest => dest.FkidPaisSisNavigation, opt => opt.Ignore());

            // Response -> Dto
            CreateMap<EstadoResponse, EstadoDto>()
                .ForMember(dest => dest.PkidEstado, opt => opt.MapFrom(src => src.PkidEstado))
                .ForMember(dest => dest.FkidPaisSis, opt => opt.MapFrom(src => src.FkidPaisSis))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.CodigoEstado, opt => opt.MapFrom(src => src.CodigoEstado))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo));

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