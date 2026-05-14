using Mapster;
using EG.Domain.DTOs.Requests.ConteoCiclico;
using EG.Domain.DTOs.Responses.ConteoCiclico;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.ConteoCiclico;

public class PeriodoConteoMappingProfile : IRegister
{
    public void Register(TypeAdapterConfig config){
        config.NewConfig<PeriodoConteo, PeriodoConteoDto>().TwoWays();

        config.NewConfig<VwPeriodoConteo, PeriodoConteoResponse>();

        config.NewConfig<PeriodoConteoResponse, PeriodoConteoDto>()
            .Map(dest => dest.FkidSucursalSis, src => src.IdSucursal ?? 0)
            .Map(dest => dest.FkidTipoConteoAlma, src => src.IdTipoConteo ?? 0)
            .Map(dest => dest.FkidEstatusAlma, src => src.IdEstatusPeriodo ?? 1)
            .Map(dest => dest.FkidResponsableSis, src => src.IdResponsable)
            .Map(dest => dest.FkidSupervisorSis, src => src.IdSupervisor);
    }
}
