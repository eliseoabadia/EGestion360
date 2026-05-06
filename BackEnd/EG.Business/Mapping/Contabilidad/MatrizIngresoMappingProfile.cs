using AutoMapper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class MatrizIngresoMappingProfile : Profile
    {
        public MatrizIngresoMappingProfile()
        {
            CreateMap<MatrizIngreso, MatrizIngresoDto>().ReverseMap();
            CreateMap<MatrizIngreso, MatrizIngresoResponse>()
                .ForMember(dest => dest.ProgramaClave, opt => opt.MapFrom(src => src.FkIdProgramaNavigation.Clave))
                .ForMember(dest => dest.ProgramaDescripcion, opt => opt.MapFrom(src => src.FkIdProgramaNavigation.Descripcion))
                .ForMember(dest => dest.OrigenDescripcion, opt => opt.MapFrom(src => src.FkIdOrigenNavigation.Descripcion))
                .ForMember(dest => dest.CuentaAutorizadoNombre, opt => opt.MapFrom(src => src.FkIdCuentaContableAutorizadoNavigation != null ? src.FkIdCuentaContableAutorizadoNavigation.Cuenta + " - " + src.FkIdCuentaContableAutorizadoNavigation.Descripcion : null))
                .ForMember(dest => dest.CuentaPorEjecutarNombre, opt => opt.MapFrom(src => src.FkIdCuentaContablePorEjercerNavigation != null ? src.FkIdCuentaContablePorEjercerNavigation.Cuenta + " - " + src.FkIdCuentaContablePorEjercerNavigation.Descripcion : null))
                .ForMember(dest => dest.CuentaModificadoNombre, opt => opt.MapFrom(src => src.FkIdCuentaContableModificadoNavigation != null ? src.FkIdCuentaContableModificadoNavigation.Cuenta + " - " + src.FkIdCuentaContableModificadoNavigation.Descripcion : null))
                .ForMember(dest => dest.CuentaDevengadoNombre, opt => opt.MapFrom(src => src.FkIdCuentaContableDevengadoNavigation != null ? src.FkIdCuentaContableDevengadoNavigation.Cuenta + " - " + src.FkIdCuentaContableDevengadoNavigation.Descripcion : null))
                .ForMember(dest => dest.CuentaRecaudadoNombre, opt => opt.MapFrom(src => src.FkIdCuentaContableRecaudadoNavigation != null ? src.FkIdCuentaContableRecaudadoNavigation.Cuenta + " - " + src.FkIdCuentaContableRecaudadoNavigation.Descripcion : null))
                .ForMember(dest => dest.CuentaDepositoNombre, opt => opt.MapFrom(src => src.FkIdCuentaContableDepositoNavigation != null ? src.FkIdCuentaContableDepositoNavigation.Cuenta + " - " + src.FkIdCuentaContableDepositoNavigation.Descripcion : null));
            CreateMap<MatrizIngresoResponse, MatrizIngresoDto>()
                .ForMember(dest => dest.PkidMatrizIngreso, opt => opt.Ignore())
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
