using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class EmpresaMappingProfile : Profile
    {
        public EmpresaMappingProfile()
        {
            // Entidad <-> DTO (CRUD)
            CreateMap<Empresa, EmpresaDto>().ReverseMap();

            // Vista enriquecida -> Response
            CreateMap<VwEstadoEmpresa, EmpresaResponse>();

            // Bidireccional Response <-> DTO (para manejo en frontend)
            CreateMap<EmpresaResponse, EmpresaDto>()
                .ForMember(dest => dest.PkidEmpresa, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.EmpresaNombre))
                .ForMember(dest => dest.Rfc, opt => opt.MapFrom(src => src.Rfc))
                .ForMember(dest => dest.RazonSocial, opt => opt.MapFrom(src => src.RazonSocial))
                .ForMember(dest => dest.Giro, opt => opt.MapFrom(src => src.Giro))
                .ForMember(dest => dest.FkidMonedaBaseSis, opt => opt.MapFrom(src => src.FkidMonedaBaseSis))
                .ForMember(dest => dest.FkidIdiomaPreferidoSis, opt => opt.MapFrom(src => src.FkidIdiomaPreferidoSis))
                .ForMember(dest => dest.Logo, opt => opt.MapFrom(src => src.Logo))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.EmpresaActivo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.EmpresaFechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.EmpresaUsuarioCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.EmpresaFechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.EmpresaUsuarioModificacion))
                .ReverseMap()
                .ForMember(dest => dest.EmpresaNombre, opt => opt.MapFrom(src => src.Nombre))
                .ForMember(dest => dest.EmpresaActivo, opt => opt.MapFrom(src => src.Activo))
                .ForMember(dest => dest.EmpresaFechaCreacion, opt => opt.MapFrom(src => src.FechaCreacion))
                .ForMember(dest => dest.EmpresaUsuarioCreacion, opt => opt.MapFrom(src => src.UsuarioCreacion))
                .ForMember(dest => dest.EmpresaFechaModificacion, opt => opt.MapFrom(src => src.FechaModificacion))
                .ForMember(dest => dest.EmpresaUsuarioModificacion, opt => opt.MapFrom(src => src.UsuarioModificacion))
                // Ignorar propiedades de la relación que no existen en DTO
                .ForMember(dest => dest.PkidEstado, opt => opt.Ignore())
                .ForMember(dest => dest.FkidPaisSis, opt => opt.Ignore())
                .ForMember(dest => dest.EstadoNombre, opt => opt.Ignore())
                .ForMember(dest => dest.CodigoEstado, opt => opt.Ignore())
                .ForMember(dest => dest.EstadoActivo, opt => opt.Ignore())
                .ForMember(dest => dest.FechaApertura, opt => opt.Ignore())
                .ForMember(dest => dest.EsOficinaPrincipal, opt => opt.Ignore())
                .ForMember(dest => dest.RelacionActiva, opt => opt.Ignore());
        }
    }
}