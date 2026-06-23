using EG.Domain.DTOs.Requests.PBR;
using EG.Domain.DTOs.Responses.PBR;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.PBR
{
    public class PbrMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Anteproyecto, PbrAnteproyectoDto>().TwoWays();
            config.NewConfig<Anteproyecto, PbrAnteproyectoResponse>();
            config.NewConfig<VwAnteproyecto, PbrAnteproyectoResponse>();
            config.NewConfig<PbrAnteproyectoResponse, PbrAnteproyectoDto>()
                .Ignore(dest => dest.PkidAnteproyecto)
                .IgnoreNullValues(true);

            config.NewConfig<PresupuestoPrograma, PbrPresupuestoProgramaDto>().TwoWays();
            config.NewConfig<PresupuestoPrograma, PbrPresupuestoProgramaResponse>();
            config.NewConfig<VwPresupuestoPrograma, PbrPresupuestoProgramaResponse>();
            config.NewConfig<PbrPresupuestoProgramaResponse, PbrPresupuestoProgramaDto>()
                .Ignore(dest => dest.PkidPresupuestoPrograma)
                .IgnoreNullValues(true);

            config.NewConfig<PartidaGasto, PbrPartidaGastoDto>().TwoWays();
            config.NewConfig<PartidaGasto, PbrPartidaGastoResponse>();
            config.NewConfig<VwPartidaGasto, PbrPartidaGastoResponse>();
            config.NewConfig<PbrPartidaGastoResponse, PbrPartidaGastoDto>()
                .Ignore(dest => dest.PkidPartidaGasto)
                .IgnoreNullValues(true);

            config.NewConfig<MirNivel, PbrMirNivelDto>().TwoWays();
            config.NewConfig<MirNivel, PbrMirNivelResponse>();
            config.NewConfig<VwMirNivel, PbrMirNivelResponse>();
            config.NewConfig<PbrMirNivelResponse, PbrMirNivelDto>()
                .Ignore(dest => dest.PkidMirNivel)
                .IgnoreNullValues(true);

            config.NewConfig<Indicador, PbrIndicadorDto>().TwoWays();
            config.NewConfig<Indicador, PbrIndicadorResponse>();
            config.NewConfig<VwIndicador, PbrIndicadorResponse>();
            config.NewConfig<PbrIndicadorResponse, PbrIndicadorDto>()
                .Ignore(dest => dest.PkidIndicador)
                .IgnoreNullValues(true);
        }
    }
}
