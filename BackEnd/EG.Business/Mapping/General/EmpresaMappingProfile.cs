using Mapster;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Responses.General;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.General
{
    public class EmpresaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // Entity -> DTO (para operaciones de escritura)
            config.NewConfig<Empresa, EmpresaDto>()
                .TwoWays(); // Permite mapear ambos sentidos

            config.NewConfig<Empresa, EmpresaResponse>()
                .Map(dest => dest.EmpresaNombre, src => src.Nombre)
                .Map(dest => dest.EmpresaActivo, src => src.Activo)
                .Map(dest => dest.EmpresaFechaCreacion, src => src.FechaCreacion)
                .Map(dest => dest.EmpresaUsuarioCreacion, src => src.UsuarioCreacion ?? 0)
                .Map(dest => dest.EmpresaFechaModificacion, src => src.FechaModificacion)
                .Map(dest => dest.EmpresaUsuarioModificacion, src => src.UsuarioModificacion)
                .IgnoreNullValues(true);
            // View -> Response (para consultas)
            config.NewConfig<VwEstadoEmpresa, EmpresaResponse>()
                .Map(dest => dest.EmpresaNombre, src => src.EmpresaNombre)
                .Map(dest => dest.EmpresaActivo, src => src.EmpresaActivo)
                .Map(dest => dest.EmpresaFechaCreacion, src => src.EmpresaFechaCreacion)
                .Map(dest => dest.EmpresaUsuarioCreacion, src => src.EmpresaUsuarioCreacion)
                .Map(dest => dest.EmpresaFechaModificacion, src => src.EmpresaFechaModificacion)
                .Map(dest => dest.EmpresaUsuarioModificacion, src => src.EmpresaUsuarioModificacion)
                // Los campos de Estado ya coinciden por nombre (PkidEstado, EstadoNombre, etc.)
                .TwoWays(); // Si necesitas mapear de Response a VwEstadoEmpresa (no es común)

            // Response -> DTO (para crear/actualizar desde el frontend)
            // Ignoramos propiedades que no existen en EmpresaDto
            config.NewConfig<EmpresaResponse, EmpresaDto>()
                .Map(dest => dest.Nombre, src => src.EmpresaNombre)
                .Map(dest => dest.Activo, src => src.EmpresaActivo)
                .Map(dest => dest.FechaCreacion, src => src.EmpresaFechaCreacion)
                .Map(dest => dest.UsuarioCreacion, src => src.EmpresaUsuarioCreacion)
                .Map(dest => dest.FechaModificacion, src => src.EmpresaFechaModificacion)
                .Map(dest => dest.UsuarioModificacion, src => src.EmpresaUsuarioModificacion)
                // Ignorar campos que no están en el DTO
                .Ignore(dest => dest.PkidEmpresa) // se asigna aparte
                .IgnoreNullValues(true);
        }
    }
}