using Mapster;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;


namespace EG.Business.Mapping.General
{
    public class SucursalMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // Mapeo de Entidad a DTO (para crear/actualizar)
            config.NewConfig<Sucursal, SucursalDto>().TwoWays(); 
            // Mapeo de Entidad a DTO (para crear/actualizar)
            config.NewConfig<Sucursal, SucursalResponse>()
                .TwoWays(); // Permite mapeo bidireccional

            // MAPPER SOLICITADO: VwSucursalEmpresaEstado a SucursalResponse
            config.NewConfig<VwSucursalEmpresaEstado, SucursalResponse>()
                // Campos base de la sucursal
                .Map(dest => dest.PkidSucursal, src => src.PkidSucursal)
                .Map(dest => dest.FkidEmpresaSis, src => src.FkidEmpresaSis)
                .Map(dest => dest.FkidEstadoSis, src => src.FkidEstadoSis)
                .Map(dest => dest.Nombre, src => src.Nombre)
                .Map(dest => dest.CodigoSucursal, src => src.CodigoSucursal)
                .Map(dest => dest.Alias, src => src.Alias)
                .Map(dest => dest.FkidTipoSucursal, src => src.FkidTipoSucursal)
                .Map(dest => dest.FkidMonedaLocalSis, src => src.FkidMonedaLocalSis)
                .Map(dest => dest.Direccion, src => src.Direccion)
                .Map(dest => dest.Colonia, src => src.Colonia)
                .Map(dest => dest.Ciudad, src => src.Ciudad)
                .Map(dest => dest.CodigoPostal, src => src.CodigoPostal)
                .Map(dest => dest.TelefonoPrincipal, src => src.TelefonoPrincipal)
                .Map(dest => dest.TelefonoSecundario, src => src.TelefonoSecundario)
                .Map(dest => dest.Email, src => src.Email)
                .Map(dest => dest.HorarioApertura, src => src.HorarioApertura)
                .Map(dest => dest.HorarioCierre, src => src.HorarioCierre)
                .Map(dest => dest.EsMatriz, src => src.EsMatriz)
                .Map(dest => dest.EsActiva, src => src.EsActiva)
                .Map(dest => dest.Latitud, src => src.Latitud)
                .Map(dest => dest.Longitud, src => src.Longitud)

                // Propiedades adicionales de la vista (información enriquecida)
                .Map(dest => dest.NombreEmpresa, src => src.NombreEmpresa)
                //.Map(dest => dest.RfcEmpresa, src => src.Rfc)
                .Map(dest => dest.NombreEstado, src => src.NombreEstado)
                .Map(dest => dest.CodigoEstado, src => src.CodigoEstado)
                .Map(dest => dest.NombrePais, src => src.NombrePais)

                ;


        }
    }
}
