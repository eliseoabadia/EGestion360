using Mapster;
using EG.Domain.DTOs.Requests.Tesoreria;
using EG.Domain.DTOs.Responses.Tesoreria;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Tesoreria
{
    public class BancoMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Banco, BancoDto>().TwoWays();
            config.NewConfig<Banco, BancoResponse>().TwoWays();
            config.NewConfig<VwBanco, BancoResponse>().TwoWays();
        }
    }

    public class CuentaBancariaMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<CuentaBancarium, CuentaBancariaDto>().TwoWays();
            config.NewConfig<CuentaBancarium, CuentaBancariaResponse>()
                .Map(dest => dest.BancoNombre, src => src.FkidBancoTesNavigation != null ? src.FkidBancoTesNavigation.Nombre : string.Empty)
                .Map(dest => dest.BancoClave, src => src.FkidBancoTesNavigation != null ? src.FkidBancoTesNavigation.Clave : string.Empty)
                .Map(dest => dest.MonedaDescripcion, src => src.FkidTipoMonedaTesNavigation != null ? src.FkidTipoMonedaTesNavigation.Descripcion : string.Empty)
                .Map(dest => dest.MonedaSimbolo, src => src.FkidTipoMonedaTesNavigation != null ? src.FkidTipoMonedaTesNavigation.Simbolo : string.Empty)
                .Map(dest => dest.CuentaContable, src => src.FkidCuentaContableSisNavigation != null ? src.FkidCuentaContableSisNavigation.Cuenta : string.Empty)
                .Map(dest => dest.CuentaContableDescripcion, src => src.FkidCuentaContableSisNavigation != null ? src.FkidCuentaContableSisNavigation.Descripcion : string.Empty)
                .TwoWays();
        }
    }

    public class IntermediarioFinancieroMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<IntermediarioFinanciero, IntermediarioFinancieroDto>().TwoWays();
            config.NewConfig<IntermediarioFinanciero, IntermediarioFinancieroResponse>().TwoWays();
            config.NewConfig<VwIntermediarioFinanciero, IntermediarioFinancieroResponse>().TwoWays();
        }
    }

    public class InstrumentoInversionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Instrumento, InstrumentoDto>().TwoWays();
            config.NewConfig<Instrumento, InstrumentoResponse>().TwoWays();
            config.NewConfig<VwInstrumento, InstrumentoResponse>().TwoWays();
        }
    }

    public class InversionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Inversion, InversionDto>().TwoWays();
            config.NewConfig<Inversion, InversionResponse>()
                .Map(dest => dest.CuentaBan, src => src.FkidCuentaBancariaNavigation != null ? src.FkidCuentaBancariaNavigation.NumeroCuenta : string.Empty)
                .Map(dest => dest.Instrumento, src => src.FkidInstrumentoNavigation != null ? src.FkidInstrumentoNavigation.Nombre : string.Empty)
                .Map(dest => dest.Intereses, src => 0m)
                .Map(dest => dest.Retiros, src => 0m)
                .Map(dest => dest.Saldo, src => src.Monto)
                .TwoWays();
            config.NewConfig<VwInversione, InversionResponse>().TwoWays();
        }
    }

    public class InteresMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Intere, InteresDto>().TwoWays();
            config.NewConfig<Intere, InteresResponse>().TwoWays();
        }
    }

    public class RetiroInversionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<Retiro, RetiroDto>().TwoWays();
            config.NewConfig<Retiro, RetiroResponse>()
                .Map(dest => dest.TipoRetiroDescripcion, src => src.FkidTipoRetiroTesNavigation != null ? src.FkidTipoRetiroTesNavigation.Descripcion : string.Empty)
                .TwoWays();
        }
    }

    public class TipoPlazoInversionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<TipoPlazo, TipoPlazoDto>().TwoWays();
            config.NewConfig<TipoPlazo, TipoPlazoResponse>().TwoWays();
            config.NewConfig<VwTipoPlazo, TipoPlazoResponse>().TwoWays();
        }
    }

    public class TipoRetiroInversionMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
            config.NewConfig<TipoRetiro, TipoRetiroDto>().TwoWays();
            config.NewConfig<TipoRetiro, TipoRetiroResponse>().TwoWays();
            config.NewConfig<VwTipoRetiro, TipoRetiroResponse>().TwoWays();
        }
    }
}
