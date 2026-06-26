using EG.Domain.DTOs.Requests.CuentasXPagar;
using EG.Domain.DTOs.Responses.CuentasXPagar;
using EG.Infraestructure.Models;
using Mapster;

namespace EG.Business.Mapping.CuentasXPagar
{
    public class CuentasXPagarMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Contrato1, ContratoDto>().TwoWays();
            config.NewConfig<VwContrato2, ContratoResponse>().TwoWays();
            config.NewConfig<ContratoResponse, ContratoDto>().TwoWays();

            config.NewConfig<ContratoDetalle, ContratoDetalleDto>().TwoWays();
            config.NewConfig<VwContratoDetalle, ContratoDetalleResponse>().TwoWays();
            config.NewConfig<ContratoDetalleResponse, ContratoDetalleDto>().TwoWays();

            config.NewConfig<Factura, FacturaDto>().TwoWays();
            config.NewConfig<VwFactura, FacturaResponse>().TwoWays();
            config.NewConfig<FacturaResponse, FacturaDto>().TwoWays();

            config.NewConfig<FacturaDetalle, FacturaDetalleDto>().TwoWays();
            config.NewConfig<VwFacturaDetalle, FacturaDetalleResponse>().TwoWays();
            config.NewConfig<FacturaDetalleResponse, FacturaDetalleDto>().TwoWays();

            config.NewConfig<Clc, CLCDto>().TwoWays();
            config.NewConfig<VwClc, CLCResponse>().TwoWays();
            config.NewConfig<CLCResponse, CLCDto>().TwoWays();

            config.NewConfig<Clcdetalle, CLCDetalleDto>().TwoWays();
            config.NewConfig<VwClcdetalle, CLCDetalleResponse>().TwoWays();
            config.NewConfig<CLCDetalleResponse, CLCDetalleDto>().TwoWays();

            config.NewConfig<Clcfactura, CLCFacturaDto>().TwoWays();
            config.NewConfig<VwClcfactura, CLCFacturaResponse>().TwoWays();
            config.NewConfig<CLCFacturaResponse, CLCFacturaDto>().TwoWays();

            config.NewConfig<Cheque, ChequeDto>().TwoWays();
            config.NewConfig<VwCheque, ChequeResponse>().TwoWays();
            config.NewConfig<ChequeResponse, ChequeDto>().TwoWays();

            config.NewConfig<ChequePartida, ChequePartidaDto>().TwoWays();
            config.NewConfig<VwChequePartida, ChequePartidaResponse>().TwoWays();
            config.NewConfig<ChequePartidaResponse, ChequePartidaDto>().TwoWays();

            config.NewConfig<Deposito, DepositoDto>().TwoWays();
            config.NewConfig<VwDeposito, DepositoResponse>().TwoWays();
            config.NewConfig<DepositoResponse, DepositoDto>().TwoWays();
        }
    }
}
