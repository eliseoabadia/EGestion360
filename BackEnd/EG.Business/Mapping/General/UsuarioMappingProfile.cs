using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class UsuarioMappingProfile : Profile
    {
        public UsuarioMappingProfile()
        {
            // 1. Mapeo básico entre entidad Usuario y DTO de solicitud (CRUD)
            CreateMap<Usuario, UsuarioDto>()
                .ReverseMap();

            // 2. Mapeo desde la vista enriquecida hacia la respuesta de usuario
            CreateMap<VwUsuarioEmpresa, UsuarioResponse>()
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.UsuarioFechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreadorId))
                .ForMember(dest => dest.UsuarioModifyId, opt => opt.MapFrom(src => src.UsuarioModifyId))
                .ForMember(dest => dest.UsuarioFechaModificacion, opt => opt.MapFrom(src => src.UsuarioFechaModificacion))
                // La vista ya contiene los mismos nombres para el resto (coinciden)
                .ReverseMap(); // Si alguna vez necesitas volver a la vista (raro), pero lo dejamos

            // 3. Mapeo entre UsuarioResponse y UsuarioDto (bidireccional)
            CreateMap<UsuarioResponse, UsuarioDto>()
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.UsuarioFechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreadorId))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.UsuarioModifyId))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioFechaModificacion))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.UsuarioActivo))
                // Ignorar propiedades que no existen en UsuarioDto
                .ForMember(dest => dest.AspNetUserId, opt => opt.MapFrom(src => src.AspNetUserId))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.ApellidoPaterno, opt => opt.MapFrom(src => src.ApellidoPaterno))
                .ForMember(dest => dest.ApellidoMaterno, opt => opt.MapFrom(src => src.ApellidoMaterno))
                .ForMember(dest => dest.Iniciales, opt => opt.MapFrom(src => src.Iniciales))
                .ForMember(dest => dest.PayrollId, opt => opt.MapFrom(src => src.PayrollId))
                .ForMember(dest => dest.CodigoPostal, opt => opt.MapFrom(src => src.CodigoPostalUsuario))
                .ForMember(dest => dest.Telefono, opt => opt.MapFrom(src => src.TelefonoUsuario))
                .ForMember(dest => dest.Direccion1, opt => opt.MapFrom(src => src.Direccion1))
                .ForMember(dest => dest.Direccion2, opt => opt.MapFrom(src => src.Direccion2))
                .ForMember(dest => dest.Email, opt => opt.MapFrom(src => src.Email))
                .ForMember(dest => dest.NumeroSocial, opt => opt.MapFrom(src => src.NumeroSocial))
                .ForMember(dest => dest.Gafete, opt => opt.MapFrom(src => src.Gafete))
                .ForMember(dest => dest.Sexo, opt => opt.MapFrom(src => src.Sexo))
                .ForMember(dest => dest.FechaIngreso, opt => opt.MapFrom(src => src.FechaIngreso))
                .ForMember(dest => dest.FkidIdiomaPreferidoSis, opt => opt.MapFrom(src => src.IdIdiomaPreferido))
                .ForMember(dest => dest.FkidMonedaPreferidaSis, opt => opt.MapFrom(src => src.IdMonedaPreferida))
                .ForMember(dest => dest.EsAdministrador, opt => opt.MapFrom(src => src.EsAdministrador))
                .ReverseMap()
                // Configuración para el reverso (UsuarioDto -> UsuarioResponse)
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.FkidEmpresaSis))
                .ForMember(dest => dest.UsuarioFechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.UsuarioCreadorId, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.UsuarioModifyId, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.UsuarioFechaModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
                .ForMember(dest => dest.UsuarioActivo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.CodigoPostalUsuario, opt => opt.MapFrom(src => src.CodigoPostal))
                .ForMember(dest => dest.TelefonoUsuario, opt => opt.MapFrom(src => src.Telefono))
                .ForMember(dest => dest.IdIdiomaPreferido, opt => opt.MapFrom(src => src.FkidIdiomaPreferidoSis))
                .ForMember(dest => dest.IdMonedaPreferida, opt => opt.MapFrom(src => src.FkidMonedaPreferidaSis))
                // Las siguientes propiedades no existen en UsuarioDto, se ignoran (o se dejan en blanco)
                .ForMember(dest => dest.NombreCompleto, opt => opt.Ignore())
                .ForMember(dest => dest.SexoDescripcion, opt => opt.Ignore())
                .ForMember(dest => dest.FechaIngresoFormat, opt => opt.Ignore())
                .ForMember(dest => dest.AntigüedadAños, opt => opt.Ignore())
                .ForMember(dest => dest.IdiomaPreferido, opt => opt.Ignore())
                .ForMember(dest => dest.MonedaPreferida, opt => opt.Ignore())
                .ForMember(dest => dest.SimboloMoneda, opt => opt.Ignore())
                .ForMember(dest => dest.UsuarioFechaCreacionFormat, opt => opt.Ignore())
                .ForMember(dest => dest.NombreEmpresa, opt => opt.Ignore())
                .ForMember(dest => dest.RfcEmpresa, opt => opt.Ignore())
                .ForMember(dest => dest.RazonSocialEmpresa, opt => opt.Ignore())
                .ForMember(dest => dest.GiroEmpresa, opt => opt.Ignore())
                .ForMember(dest => dest.IdMonedaBaseEmpresa, opt => opt.Ignore())
                .ForMember(dest => dest.MonedaBaseEmpresa, opt => opt.Ignore())
                .ForMember(dest => dest.SimboloMonedaBase, opt => opt.Ignore())
                .ForMember(dest => dest.EmpresaActiva, opt => opt.Ignore())
                .ForMember(dest => dest.EmpresaFechaCreacion, opt => opt.Ignore())
                .ForMember(dest => dest.ListaDepartamentos, opt => opt.Ignore())
                .ForMember(dest => dest.TotalDepartamentos, opt => opt.Ignore())
                .ForMember(dest => dest.EsJefeAlgunDepartamento, opt => opt.Ignore())
                .ForMember(dest => dest.DepartamentosComoJefe, opt => opt.Ignore())
                .ForMember(dest => dest.ListaSucursales, opt => opt.Ignore())
                .ForMember(dest => dest.TotalSucursales, opt => opt.Ignore())
                .ForMember(dest => dest.SucursalMatrizAsignada, opt => opt.Ignore())
                .ForMember(dest => dest.RolPrincipal, opt => opt.Ignore())
                .ForMember(dest => dest.CoberturaSucursales, opt => opt.Ignore())
                .ForMember(dest => dest.UltimoAcceso, opt => opt.Ignore())
                .ForMember(dest => dest.NumeroEmpleado, opt => opt.Ignore())
                .ForMember(dest => dest.InicialesNombre, opt => opt.Ignore());

            // 4. (Opcional) Si tienes una entidad FotografiaUsuario, podrías mapearla a FotografiaUsuarioResponse
            // CreateMap<FotografiaUsuario, FotografiaUsuarioResponse>().ReverseMap();
        }
    }
}