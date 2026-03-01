using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;


namespace EG.Business.Mapping.Entidades
{
    public class SucursalMappingProfile : Profile
    {
        public SucursalMappingProfile()
        {
            // Mapeo de Entidad a DTO (para crear/actualizar)
            CreateMap<Sucursal, SucursalDto>().ReverseMap(); 
            // Mapeo de Entidad a DTO (para crear/actualizar)
            CreateMap<Sucursal, SucursalResponse>()
                .ReverseMap(); // Permite mapeo bidireccional

            // MAPPER SOLICITADO: VwSucursalEmpresaEstado a SucursalResponse
            CreateMap<VwSucursalEmpresaEstado, SucursalResponse>()
                // Campos base de la sucursal
                .ForMember(dest => dest.PkidSucursal, opt => opt.MapFrom(src => src.PkidSucursal))
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.FkidEmpresaSis))
                .ForMember(dest => dest.FkidEstadoSis, opt => opt.MapFrom(src => src.FkidEstadoSis))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.CodigoSucursal, opt => opt.MapFrom(src => src.CodigoSucursal))
                .ForMember(dest => dest.Alias, opt => opt.MapFrom(src => src.Alias))
                .ForMember(dest => dest.FkidTipoSucursal, opt => opt.MapFrom(src => src.FkidTipoSucursal))
                .ForMember(dest => dest.FkidMonedaLocalSis, opt => opt.MapFrom(src => src.FkidMonedaLocalSis))
                .ForMember(dest => dest.Direccion, opt => opt.MapFrom(src => src.Direccion))
                .ForMember(dest => dest.Colonia, opt => opt.MapFrom(src => src.Colonia))
                .ForMember(dest => dest.Ciudad, opt => opt.MapFrom(src => src.Ciudad))
                .ForMember(dest => dest.CodigoPostal, opt => opt.MapFrom(src => src.CodigoPostal))
                .ForMember(dest => dest.TelefonoPrincipal, opt => opt.MapFrom(src => src.TelefonoPrincipal))
                .ForMember(dest => dest.TelefonoSecundario, opt => opt.MapFrom(src => src.TelefonoSecundario))
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.Email))
                .ForMember(dest => dest.HorarioApertura, opt => opt.MapFrom(src => src.HorarioApertura))
                .ForMember(dest => dest.HorarioCierre, opt => opt.MapFrom(src => src.HorarioCierre))
                .ForMember(dest => dest.EsMatriz, opt => opt.MapFrom(src => src.EsMatriz))
                .ForMember(dest => dest.EsActiva, opt => opt.MapFrom(src => src.EsActiva))
                .ForMember(dest => dest.Latitud, opt => opt.MapFrom(src => src.Latitud))
                .ForMember(dest => dest.Longitud, opt => opt.MapFrom(src => src.Longitud))

                // Propiedades adicionales de la vista (información enriquecida)
                .ForMember(dest => dest.NombreEmpresa, opt => opt.MapFrom(src => src.NombreEmpresa))
                //.ForMember(dest => dest.RfcEmpresa, opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.NombreEstado, opt => opt.MapFrom(src => src.NombreEstado))
                .ForMember(dest => dest.CodigoEstado, opt => opt.MapFrom(src => src.CodigoEstado))
                .ForMember(dest => dest.NombrePais, opt => opt.MapFrom(src => src.NombrePais))

                ;


        }
    }
}
