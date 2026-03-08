
using AutoMapper;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class AspNetRoleMappingProfile : Profile
    {
        public AspNetRoleMappingProfile()
        {
            CreateMap<AspNetRole, AspNetRoleDto>().ReverseMap();
            CreateMap<AspNetRole, AspNetRoleResponse>().ReverseMap();
            CreateMap<AspNetRoleDto, AspNetRoleResponse>().ReverseMap();
        }
    }
}
