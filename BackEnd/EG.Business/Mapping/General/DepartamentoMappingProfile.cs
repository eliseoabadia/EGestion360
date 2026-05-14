using Mapster;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class DepartamentoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Departamento, DepartamentoDto>()
                .Map(dest => dest.PkidDepartamento, src => src.PkidDepartamento)
                .Map(dest => dest.FkidEmpresaSis, src => src.FkidEmpresaSis)
                .Map(dest => dest.FkidSucursalSis, src => src.FkidSucursalSis)
                .Map(dest => dest.Nombre, src => src.Nombre)
                .Map(dest => dest.Descripcion, src => src.Descripcion)
                .Map(dest => dest.NivelJerarquico, src => src.NivelJerarquico)
                .Map(dest => dest.Activo, src => src.Activo)
                .Map(dest => dest.UsuarioCreacion, src => src.UsuarioCreacion)
                .Map(dest => dest.FechaCreacion, src => src.FechaCreacion)
                .Map(dest => dest.UsuarioModificacion, src => src.UsuarioModificacion)
                .Map(dest => dest.FechaModificacion, src => src.FechaModificacion);

            config.NewConfig<DepartamentoDto, Departamento>()
                .Ignore(dest => dest.FkidEmpresaSisNavigation)
                .Ignore(dest => dest.FkidSucursalSisNavigation)
                .Ignore(dest => dest.UsuarioCreacionNavigation)
                .Ignore(dest => dest.UsuarioModificacionNavigation)
                .Ignore(dest => dest.UsuarioDepartamentos);

            config.NewConfig<Departamento, DepartamentoResponse>()
                .Map(dest => dest.PkidEmpresa, src => src.FkidEmpresaSis)
                .Map(dest => dest.EmpresaNombre, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Nombre : string.Empty)
                .Map(dest => dest.Rfc, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Rfc : string.Empty)
                .Map(dest => dest.DepartamentoNombre, src => src.Nombre)
                .Map(dest => dest.DepartamentoActivo, src => src.Activo)
                .Map(dest => dest.EmpresaActivo, src => src.FkidEmpresaSisNavigation != null ? src.FkidEmpresaSisNavigation.Activo : false)
                .Map(dest => dest.UsuarioCreacionNombre, src => src.UsuarioCreacionNavigation != null 
                    && src.UsuarioCreacionNavigation.FkidPersonaNomNavigation != null
                    ? $"{src.UsuarioCreacionNavigation.FkidPersonaNomNavigation.Nombre} {src.UsuarioCreacionNavigation.FkidPersonaNomNavigation.Paterno}" 
                    : string.Empty);

            config.NewConfig<VwEmpresaDepartamanto, DepartamentoResponse>();

            config.NewConfig<DepartamentoResponse, DepartamentoDto>()
                .Map(dest => dest.PkidDepartamento, src => src.PkidDepartamento)
                .Map(dest => dest.FkidEmpresaSis, src => src.PkidEmpresa)
                .Ignore(dest => dest.FkidSucursalSis)
                .Map(dest => dest.Nombre, src => src.DepartamentoNombre)
                .Map(dest => dest.Descripcion, src => src.Descripcion)
                .Map(dest => dest.NivelJerarquico, src => src.NivelJerarquico)
                .Map(dest => dest.Activo, src => src.DepartamentoActivo)
                .Map(dest => dest.UsuarioCreacion, src => src.UsuarioCreacion)
                .Ignore(dest => dest.FechaCreacion)
                .Map(dest => dest.UsuarioModificacion, src => src.UsuarioModificacion)
                .Ignore(dest => dest.FechaModificacion);
        }
    }
}
