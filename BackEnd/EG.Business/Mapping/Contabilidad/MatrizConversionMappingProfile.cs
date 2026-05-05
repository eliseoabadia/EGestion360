using AutoMapper;
using EG.Domain.DTOs.Requests.Contabilidad;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Contabilidad
{
    public class MatrizConversionMappingProfile : Profile
    {
        public MatrizConversionMappingProfile()
        {
CreateMap<MatrizConversion, MatrizConversionDto>().ReverseMap();
CreateMap<MatrizConversion, MatrizConversionResponse>()
    .ForMember(dest => dest.ProgramaClave, opt => opt.MapFrom(src => src.FkidProgramaPresNavigation.Clave))
    .ForMember(dest => dest.PartidaDescripcion, opt => opt.MapFrom(src => src.FkidPartidaSisNavigation.Descripcion))
    .ForMember(dest => dest.CuentaAprobadoNombre, opt => opt.MapFrom(src => src.FkidCuentaContableAprobadoNavigation.Cuenta + " - " + src.FkidCuentaContableAprobadoNavigation.Descripcion))
    .ForMember(dest => dest.CuentaPorEjercerNombre, opt => opt.MapFrom(src => src.FkidCuentaContablePorEjercerNavigation.Cuenta + " - " + src.FkidCuentaContablePorEjercerNavigation.Descripcion))
    .ForMember(dest => dest.CuentaModificadoNombre, opt => opt.MapFrom(src => src.FkidCuentaContableModificadoNavigation.Cuenta + " - " + src.FkidCuentaContableModificadoNavigation.Descripcion))
    .ForMember(dest => dest.CuentaComprometidoNombre, opt => opt.MapFrom(src => src.FkidCuentaContableComprometidoNavigation.Cuenta + " - " + src.FkidCuentaContableComprometidoNavigation.Descripcion))
    .ForMember(dest => dest.CuentaDevengadoNombre, opt => opt.MapFrom(src => src.FkidCuentaContableDevengadoNavigation.Cuenta + " - " + src.FkidCuentaContableDevengadoNavigation.Descripcion))
    .ForMember(dest => dest.CuentaEjercidoNombre, opt => opt.MapFrom(src => src.FkidCuentaContableEjercidoNavigation.Cuenta + " - " + src.FkidCuentaContableEjercidoNavigation.Descripcion))
    .ForMember(dest => dest.CuentaPagadoNombre, opt => opt.MapFrom(src => src.FkidCuentaContablePagadoNavigation.Cuenta + " - " + src.FkidCuentaContablePagadoNavigation.Descripcion))
    .ForMember(dest => dest.CuentaGastoNombre, opt => opt.MapFrom(src => src.FkidCuentaContableGastoNavigation.Cuenta + " - " + src.FkidCuentaContableGastoNavigation.Descripcion));
CreateMap<MatrizConversionResponse, MatrizConversionDto>()
    .ForMember(dest => dest.PkidMatrizConversion, opt => opt.Ignore())
    .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}
