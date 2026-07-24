using EG.Domain.DTOs.Responses.General;

namespace EG.UnidTest.Domain;

public class EnvioWorkflowEstadosTests
{
    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("DESCONOCIDO")]
    public void EstadoInicial_SeNormalizaComoPendiente(string? estado)
    {
        var result = EnvioWorkflowEstados.Normalizar(estado);

        Assert.Equal(EnvioWorkflowEstados.Pendiente, result);
        Assert.True(EnvioWorkflowEstados.PuedeEnviar(result));
        Assert.False(EnvioWorkflowEstados.PuedeRechazar(result));
    }

    [Fact]
    public void Enviado_BloqueaNuevoEnvio_YPermiteRechazo()
    {
        var state = new EnvioWorkflowEstadoResponse
        {
            Estado = EnvioWorkflowEstados.Enviado
        };

        Assert.False(state.PuedeEnviar);
        Assert.True(state.PuedeRechazar);
    }

    [Fact]
    public void Rechazado_HabilitaNuevamenteElEnvio()
    {
        var state = new EnvioWorkflowEstadoResponse
        {
            Estado = EnvioWorkflowEstados.Rechazado
        };

        Assert.True(state.PuedeEnviar);
        Assert.False(state.PuedeRechazar);
    }

    [Fact]
    public void Procesando_BloqueaEnvioYRechazo()
    {
        var state = new EnvioWorkflowEstadoResponse
        {
            Estado = EnvioWorkflowEstados.Procesando
        };

        Assert.False(state.PuedeEnviar);
        Assert.False(state.PuedeRechazar);
    }

    [Fact]
    public void Parcial_PermiteEnviarSoloPendientes()
    {
        Assert.True(EnvioWorkflowEstados.PuedeEnviar(EnvioWorkflowEstados.Parcial));
        Assert.False(EnvioWorkflowEstados.PuedeRechazar(EnvioWorkflowEstados.Parcial));
    }

    [Theory]
    [InlineData("enviado", "ENVIADO")]
    [InlineData(" ReChAzAdO ", "RECHAZADO")]
    [InlineData("procesando", "PROCESANDO")]
    public void Normalizar_NoDependeDeMayusculasNiEspacios(string input, string expected)
    {
        Assert.Equal(expected, EnvioWorkflowEstados.Normalizar(input));
    }

    [Fact]
    public void Procesos_TienenLlavesIndependientes()
    {
        var procesos = new[]
        {
            EnvioWorkflowProcesos.CotizacionCorreo,
            EnvioWorkflowProcesos.EstudioMercadoCotizacion,
            EnvioWorkflowProcesos.PolizaFirma
        };

        Assert.Equal(procesos.Length, procesos.Distinct().Count());
    }
}
