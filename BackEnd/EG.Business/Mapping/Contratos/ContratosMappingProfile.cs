using EG.Domain.DTOs.Requests.Contratos;
using EG.Domain.DTOs.Responses.Contratos;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.Contratos
{
    public class ContratosMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Contrato, OrcoContratoDto>().TwoWays();
            config.NewConfig<VwContrato1, OrcoContratoResponse>().TwoWays();
            config.NewConfig<OrcoContratoResponse, OrcoContratoDto>().TwoWays();

            config.NewConfig<VwEgreCompNoDev, SaldosContratoResponse>().TwoWays();
            config.NewConfig<SaldosContratoResponse, SaldosContratoResponse>().TwoWays();

            config.NewConfig<Contrato1, EstadoContratoDto>().TwoWays();
            config.NewConfig<VwContrato2, EstadoContratoResponse>().TwoWays();
            config.NewConfig<EstadoContratoResponse, EstadoContratoDto>().TwoWays();
        }
    }
}
