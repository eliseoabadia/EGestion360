using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class DepartamentoMappingProfile : Profile
    {
        public DepartamentoMappingProfile()
        {
            // ============ DEPARTAMENTO ============

            // Entidad <-> DTO básico
            CreateMap<Departamento, DepartamentoDto>()
                .ReverseMap();

            // Vista -> Response
            CreateMap<VwEmpresaDepartamanto, DepartamentoResponse>();

            //// Vista -> Entity
            // Mapeo de Response a DTO de solicitud (útil para edición)
            CreateMap<DepartamentoResponse, DepartamentoDto>()
                .ForMember(dest => dest.FkidEmpresaSis, opt => opt.MapFrom(src => src.PkidEmpresa))
                .ForMember(dest => dest.Nombre, opt => opt.MapFrom(src => src.DepartamentoNombre))
                .ForMember(dest => dest.Activo, opt => opt.MapFrom(src => src.DepartamentoActivo))
                .ForMember(dest => dest.FkidSucursalSis, opt => opt.Ignore())    // No disponible en response
                .ForMember(dest => dest.Descripcion, opt => opt.Ignore())         // No disponible en response
                .ForMember(dest => dest.NivelJerarquico, opt => opt.Ignore())     // No disponible en response
                .ReverseMap(); // Opcional: si necesitas el mapeo inverso
        }
    }
}