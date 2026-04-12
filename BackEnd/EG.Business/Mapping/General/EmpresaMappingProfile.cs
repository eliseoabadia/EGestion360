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
            // Entity -> DTO (para operaciones de escritura)
            CreateMap<Empresa, EmpresaDto>()
                .ReverseMap(); // Permite mapear ambos sentidos

            // View -> Response (para consultas)
            CreateMap<VwEstadoEmpresa, EmpresaResponse>()
                .ForMember(dest => dest.EmpresaNombre, opt => opt.MapFrom(src => src.EmpresaNombre))
                .ForMember(dest => dest.EmpresaActivo, opt => opt.MapFrom(src => src.EmpresaActivo))
                .ForMember(dest => dest.EmpresaFechaCreacion, opt => opt.MapFrom(src => src.EmpresaFechaCreacion))
                .ForMember(dest => dest.EmpresaUsuarioCreacion, opt => opt.MapFrom(src => src.EmpresaUsuarioCreacion))
                .ForMember(dest => dest.EmpresaFechaModificacion, opt => opt.MapFrom(src => src.EmpresaFechaModificacion))
                .ForMember(dest => dest.EmpresaUsuarioModificacion, opt => opt.MapFrom(src => src.EmpresaUsuarioModificacion))
                // Los campos de Estado ya coinciden por nombre (PkidEstado, EstadoNombre, etc.)
                .ReverseMap(); // Si necesitas mapear de Response a VwEstadoEmpresa (no es común)

            // Response -> DTO (para crear/actualizar desde el frontend)
            // Ignoramos propiedades que no existen en EmpresaDto
            CreateMap<EmpresaResponse, EmpresaDto>()
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.EmpresaNombre))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.EmpresaActivo))
                .ForMember(dest => dest.FechaCreacion, opt => opt.MapFrom(src => src.EmpresaFechaCreacion))
                .ForMember(dest => dest.UsuarioCreacion, opt => opt.MapFrom(src => src.EmpresaUsuarioCreacion))
                .ForMember(dest => dest.FechaModificacion, opt => opt.MapFrom(src => src.EmpresaFechaModificacion))
                .ForMember(dest => dest.UsuarioModificacion, opt => opt.MapFrom(src => src.EmpresaUsuarioModificacion))
                // Ignorar campos que no están en el DTO
                .ForMember(dest => dest.PkidEmpresa, opt => opt.Ignore()) // se asigna aparte
                .ForAllMembers(opt => opt.Condition((src, dest, srcMember) => srcMember != null));
        }
    }
}