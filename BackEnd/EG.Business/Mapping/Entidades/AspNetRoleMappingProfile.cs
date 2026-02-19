
using AutoMapper;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Entities;

namespace EG.Business.Mapping.Entidades
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
