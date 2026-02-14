using AutoMapper;
using EG.Domain.Entities;
using EG.Dommain.DTOs.Responses;


namespace EG.Business.Mapping.Entidades
{
    public class SucursalMappingProfile : Profile
    {
        public SucursalMappingProfile()
        {
            // Mapeo de Entidad a DTO (para crear/actualizar)
            CreateMap<Sucursal, SucursalDto>()
                .ReverseMap(); // Permite mapeo bidireccional

            // Mapeo de Entidad a Response (para respuestas de API)
            CreateMap<Sucursal, SucursalResponse>()
                .ForMember(dest => dest.PkidSucursal, opt => opt.MapFrom(src => src.PkidSucursal))
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.FkidEmpresaSis))
                .ForMember(dest => dest.FkidEstadoSis, opt => opt.MapFrom(src => src.FkidEstadoSis))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.CodigoSucursal, opt => opt.MapFrom(src => src.CodigoSucursal))
                .ForMember(dest => dest.Alias, opt => opt.MapFrom(src => src.Alias))
                .ForMember(dest => dest.TipoSucursal, opt => opt.MapFrom(src => src.TipoSucursal))
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
                .ForMember(dest => dest.MetrosCuadrados, opt => opt.MapFrom(src => src.MetrosCuadrados))
                .ForMember(dest => dest.CapacidadPersonas, opt => opt.MapFrom(src => src.CapacidadPersonas))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion));

            // Mapeo de DTO a Entidad (opcional, si necesitas conversiones específicas)
            CreateMap<SucursalDto, Sucursal>()
                .ForMember(dest => dest.PkidSucursal, opt => opt.MapFrom(src => src.PkidSucursal))
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.FkidEmpresaSis))
                .ForMember(dest => dest.FkidEstadoSis, opt => opt.MapFrom(src => src.FkidEstadoSis))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.CodigoSucursal, opt => opt.MapFrom(src => src.CodigoSucursal))
                .ForMember(dest => dest.Alias, opt => opt.MapFrom(src => src.Alias))
                .ForMember(dest => dest.TipoSucursal, opt => opt.MapFrom(src => src.TipoSucursal))
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
                .ForMember(dest => dest.MetrosCuadrados, opt => opt.MapFrom(src => src.MetrosCuadrados))
                .ForMember(dest => dest.CapacidadPersonas, opt => opt.MapFrom(src => src.CapacidadPersonas))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion));

            // Si necesitas ignorar propiedades de navegación (para evitar ciclos)
            //CreateMap<Sucursal, SucursalResponse>();
        }
    }
}
