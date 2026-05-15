using Mapster;
using EG.Domain.DTOs.Requests.General;
using EG.Domain.DTOs.Requests.Presupuestales;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.DTOs.Responses.Patrimonio;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Dommain.DTOs.Responses;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping
{
    public class GeneralMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            config.NewConfig<Empresa, EmpresaResponse>().TwoWays();
            config.NewConfig<Usuario, UsuarioResponse>().TwoWays();

            config.NewConfig<Programa, ProgramaDto>().TwoWays();
            config.NewConfig<Programa, ProgramaResponse>();
            config.NewConfig<VwPrograma, ProgramaResponse>();
            config.NewConfig<ProgramaResponse, ProgramaDto>()
                .Ignore(dest => dest.PkidPrograma)
                .IgnoreNullValues(true);

            //config.NewConfig<TipoBien, TipoBienDto>().TwoWays();
            config.NewConfig<TipoBien, TipoBienResponse>().TwoWays();
            //config.NewConfig<TipoBienResponse, TipoBienDto>().TwoWays();

            //config.NewConfig<EstatusPeriodo, EstatusPeriodoResponse>().TwoWays();
            //config.NewConfig<EstatusPeriodoDto, EstatusPeriodo>().TwoWays();
            //config.NewConfig<EstatusPeriodoResponse, EstatusPeriodoDto>().TwoWays();

            //config.NewConfig<EstatusArticuloConteo, EstatusArticuloConteoResponse>().TwoWays();
            //config.NewConfig<EstatusArticuloConteoDto, EstatusArticuloConteo>().TwoWays();
            //config.NewConfig<EstatusArticuloConteoResponse, EstatusArticuloConteoDto>().TwoWays();

            //config.NewConfig<RegistroConteo, RegistroConteoDto>().TwoWays();
            //config.NewConfig<RegistroConteo, RegistroConteoResponse>().TwoWays();
            //config.NewConfig<RegistroConteoResponse, RegistroConteoDto>().TwoWays();

            config.NewConfig<Sucursal, SucursalDto>().TwoWays();
            config.NewConfig<SucursalResponse, SucursalDto>();
            config.NewConfig<Sucursal, SucursalResponse>().TwoWays();

            config.NewConfig<Departamento, DepartamentoDto>().TwoWays();
            config.NewConfig<DepartamentoResponse, DepartamentoDto>().TwoWays();

            // Entity -> Response
            config.NewConfig<Estado, EstadoResponse>()
                .Map(dest => dest.PkidEstado, src => src.PkidEstado)
                .Map(dest => dest.FkidPaisSis, src => src.FkidPaisSis)
                .Map(dest => dest.Nombre, src => src.Nombre)
                .Map(dest => dest.CodigoEstado, src => src.CodigoEstado)
                .Map(dest => dest.Activo, src => src.Activo);

            // Dto -> Entity
            config.NewConfig<EstadoDto, Estado>()
                .Map(dest => dest.PkidEstado, src => src.PkidEstado)
                .Map(dest => dest.FkidPaisSis, src => src.FkidPaisSis)
                .Map(dest => dest.Nombre, src => src.Nombre)
                .Map(dest => dest.CodigoEstado, src => src.CodigoEstado)
                .Map(dest => dest.Activo, src => src.Activo)
                .Ignore(dest => dest.EmpresaEstados)
                .Ignore(dest => dest.Municipios)
                .Ignore(dest => dest.Proveedors)
                .Ignore(dest => dest.Sucursals)
                .Ignore(dest => dest.FkidPaisSisNavigation);

            // Response -> Dto
            config.NewConfig<EstadoResponse, EstadoDto>()
                .Map(dest => dest.PkidEstado, src => src.PkidEstado)
                .Map(dest => dest.FkidPaisSis, src => src.FkidPaisSis)
                .Map(dest => dest.Nombre, src => src.Nombre)
                .Map(dest => dest.CodigoEstado, src => src.CodigoEstado)
                .Map(dest => dest.Activo, src => src.Activo);

            config.NewConfig<LoginInformationEmployeeResult, UserResponse>().TwoWays();
            config.NewConfig<spNodeMenuResult, spNodeMenuResponse>()
                .Map(dest => dest.FkidMenuSis, src => (long?)src.FKIdMenuSIS);
            //config.NewConfig<DepartamentoResponse, DepartamentoDto>().TwoWays();
            config.NewConfig<PerfilUsuarioResponse, PerfilUsuario>()
                .Ignore(dest => dest.FechaCreacion)
                .Ignore(dest => dest.UsuarioCreacion)
                .Ignore(dest => dest.FechaModificacion)
                .Ignore(dest => dest.UsuarioModificacion)
                .Ignore(dest => dest.FkidUsuarioSisNavigation)
                .TwoWays();
        }
    }
}
