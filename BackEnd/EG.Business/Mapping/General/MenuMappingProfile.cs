using Mapster;
using EG.Domain.DTOs.Requests.General;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class MenuMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // Mapeo de VwMenu a MenuItemsResponse (para consultas/lectura)
            config.NewConfig<VwMenu, MenuItemsResponse>()
                .Map(dest => dest.PkidMenu, src => src.PkidMenu)
                .Map(dest => dest.Nombre, src => src.Nombre)
                .Map(dest => dest.Tipo, src => src.Tipo)
                .Map(dest => dest.TipoDescripcion, src => src.TipoDescripcion)
                .Map(dest => dest.FkidMenuSis, src => src.FkidMenuSis)
                .Map(dest => dest.NombreMenuPadre, src => src.NombreMenuPadre)
                .Map(dest => dest.TipoMenuPadre, src => src.TipoMenuPadre)
                .Map(dest => dest.TipoMenuPadreDescripcion, src => src.TipoMenuPadreDescripcion)
                .Map(dest => dest.LegacyName, src => src.LegacyName)
                .Map(dest => dest.Ruta, src => src.Ruta)
                .Map(dest => dest.ImageUrl, src => src.ImageUrl)
                .Map(dest => dest.Lenguaje, src => src.Lenguaje)
                .Map(dest => dest.Orden, src => src.Orden)
                .Map(dest => dest.Activo, src => src.Activo)
                .Map(dest => dest.Estado, src => src.Estado)
                .Map(dest => dest.CreatedByOperatorId, src => src.CreatedByOperatorId)
                .Map(dest => dest.CreatedDateTime, src => src.CreatedDateTime)
                .Map(dest => dest.ModifiedByOperatorId, src => src.ModifiedByOperatorId)
                .Map(dest => dest.ModifiedDateTime, src => src.ModifiedDateTime)
                .Map(dest => dest.NivelJerarquico, src => src.NivelJerarquico)
                .Map(dest => dest.RutaCompleta, src => src.RutaCompleta)
                .Map(dest => dest.TieneSubmenus, src => src.TieneSubmenus)
                .Map(dest => dest.ValidacionEstructura, src => src.ValidacionEstructura)
                .Ignore(dest => dest.Children); // Los hijos se asignan manualmente

            // Mapeo de MenuItemsDto a Menu (para operaciones de escritura: Create/Update)
            //config.NewConfig<MenuItemsDto, Menu>()
            //    .Ignore(dest => dest.PkidMenu) // Ignorar ID para nuevos registros
            //    .Ignore(dest => dest.FkidMenuSisNavigation)
            //    .Ignore(dest => dest.InverseFkidMenuSisNavigation)
            //    .Ignore(dest => dest.MenuRoles)
            //    // Estas propiedades se asignan en el servicio/repositorio
            //    .Ignore(dest => dest.CreatedDateTime)
            //    .Ignore(dest => dest.ModifiedDateTime)
            //    .Ignore(dest => dest.CreatedByOperatorId)
            //    .Ignore(dest => dest.ModifiedByOperatorId);

            // Mapeo de Menu a MenuItemsDto (para cuando necesitas convertir de Entity a DTO)
            //config.NewConfig<Menu, MenuItemsDto>()
            //    .Map(dest => dest.PkidMenu, src => src.PkidMenu)
            //    .Map(dest => dest.Nombre, src => src.Nombre)
            //    .Map(dest => dest.Tipo, src => src.Tipo)
            //    .Map(dest => dest.FkidMenuSis, src => src.FkidMenuSis)
            //    .Map(dest => dest.LegacyName, src => src.LegacyName)
            //    .Map(dest => dest.Ruta, src => src.Ruta)
            //    .Map(dest => dest.ImageUrl, src => src.ImageUrl)
            //    .Map(dest => dest.Lenguaje, src => src.Lenguaje)
            //    .Map(dest => dest.Orden, src => src.Orden)
            //    .Map(dest => dest.Activo, src => src.Activo)
            //    .Map(dest => dest.CreatedByOperatorId, src => src.CreatedByOperatorId)
            //    .Map(dest => dest.CreatedDateTime, src => src.CreatedDateTime)
            //    .Map(dest => dest.ModifiedByOperatorId, src => src.ModifiedByOperatorId)
            //    .Map(dest => dest.ModifiedDateTime, src => src.ModifiedDateTime);
            config.NewConfig<Menu, MenuItemsDto>().TwoWays();

            // Si necesitas mapear desde VwMenu a MenuItemsDto (útil para actualizaciones)
            config.NewConfig<VwMenu, MenuItemsDto>()
                .Map(dest => dest.PkidMenu, src => src.PkidMenu)
                .Map(dest => dest.Nombre, src => src.Nombre)
                .Map(dest => dest.Tipo, src => src.Tipo)
                .Map(dest => dest.FkidMenuSis, src => src.FkidMenuSis)
                .Map(dest => dest.LegacyName, src => src.LegacyName)
                .Map(dest => dest.Ruta, src => src.Ruta)
                .Map(dest => dest.ImageUrl, src => src.ImageUrl)
                .Map(dest => dest.Lenguaje, src => src.Lenguaje)
                .Map(dest => dest.Orden, src => src.Orden)
                .Map(dest => dest.Activo, src => src.Activo)
                .Map(dest => dest.CreatedByOperatorId, src => src.CreatedByOperatorId)
                .Map(dest => dest.CreatedDateTime, src => src.CreatedDateTime)
                .Map(dest => dest.ModifiedByOperatorId, src => src.ModifiedByOperatorId)
                .Map(dest => dest.ModifiedDateTime, src => src.ModifiedDateTime);
        }
    }
}
