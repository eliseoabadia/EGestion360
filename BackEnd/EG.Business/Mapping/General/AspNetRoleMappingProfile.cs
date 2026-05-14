
using Mapster;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class AspNetRoleMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<AspNetRole, AspNetRoleDto>().TwoWays();
            config.NewConfig<AspNetRole, AspNetRoleResponse>().TwoWays();
            config.NewConfig<AspNetRoleDto, AspNetRoleResponse>().TwoWays();
        }
    }
}
