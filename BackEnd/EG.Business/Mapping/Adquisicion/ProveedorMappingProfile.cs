using Mapster;
using EG.Domain.DTOs.Requests.Adquisicion;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Adquisicion
{
    public class ProveedorMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Proveedor, ProveedorDto>()
                .Map(dest => dest.FkIdTipoProveedorSis, src => src.FkIdTipoProveedorSis)
                .TwoWays();
            config.NewConfig<Proveedor, ProveedorResponse>()
                .Map(dest => dest.TipoProveedorNombre, src => src.FkIdTipoProveedorSisNavigation != null ? src.FkIdTipoProveedorSisNavigation.Descripcion : string.Empty)
                .Map(dest => dest.EstatusProveedorNombre, src => src.FkidEstatusProveedorSisNavigation != null ? src.FkidEstatusProveedorSisNavigation.Descripcion : string.Empty)
                .Map(dest => dest.CuentaContableNombre, src => src.FkidCuentaContableSisNavigation != null ? src.FkidCuentaContableSisNavigation.Descripcion : string.Empty)
                .Map(dest => dest.MunicipioNombre, src => src.FkidMunicipioSisNavigation != null ? src.FkidMunicipioSisNavigation.Nombre : string.Empty)
                .Map(dest => dest.EstadoNombre, src => src.FkidEstadoSisNavigation != null ? src.FkidEstadoSisNavigation.Nombre : string.Empty)
                .Map(dest => dest.PaisNombre, src => src.FkidPaisSisNavigation != null ? src.FkidPaisSisNavigation.Nombre : string.Empty);
            config.NewConfig<VwProveedor, ProveedorResponse>()
                .Map(dest => dest.TipoProveedorNombre, src => src.TipoProveedorDesc)
                .Map(dest => dest.EstatusProveedorNombre, src => src.EstatusProveedorDesc)
                .Map(dest => dest.CuentaContableNombre, src => src.CuentaContableClave)
                .Ignore(dest => dest.ResponsableNombre);
            config.NewConfig<ProveedorResponse, ProveedorDto>()
                .Ignore(dest => dest.PkidProveedor)
                .Ignore(dest => dest.FkIdTipoProveedorSis)
                .Ignore(dest => dest.FkidEstatusProveedorSis)
                .IgnoreNullValues(true);
        }
    }
}