using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class UsuarioSucursalMappingProfile : Profile
    {
        public UsuarioSucursalMappingProfile()
        {
            // Mapeo de Entidad -> DTO de creación/actualización
            CreateMap<UsuarioSucursal, UsuarioSucursalDto>().ReverseMap();

            // Mapeo de la Vista -> Response DTO (proyección completa)
            CreateMap<VwUsuarioSucursal, UsuarioSucursalResponse>();
        }
    }
}