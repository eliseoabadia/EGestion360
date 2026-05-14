using Mapster;
using EG.Domain.DTOs.Requests.Almacen;
using EG.Domain.DTOs.Responses.Almacen;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Almacen
{
    public class AlmacenMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config){
            // MotivoES
            config.NewConfig<Motivo, MotivoEsResponse>().TwoWays();
            config.NewConfig<Motivo, MotivoEsDto>().TwoWays();

            // Unidades
            config.NewConfig<Unidade, UnidadeResponse>().TwoWays();
            config.NewConfig<Unidade, UnidadeDto>().TwoWays();

            // EstatusSolicitud
            config.NewConfig<EstatusSolicitud, EstatusSolicitudResponse>().TwoWays();
            config.NewConfig<EstatusSolicitud, EstatusSolicitudDto>().TwoWays();

            // PeriodoConteo
            config.NewConfig<PeriodoConteo, PeriodoConteoResponse>().TwoWays();
            config.NewConfig<PeriodoConteo, PeriodoConteoDto>().TwoWays();
        }
    }
}
