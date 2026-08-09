namespace EG.Domain.DTOs.Responses.General;

public sealed class EnvioWorkflowEstadoResponse
{
    public long EntidadId { get; set; }
    public string Estado { get; set; } = EnvioWorkflowEstados.Pendiente;
    public DateTime? FechaEnvio { get; set; }
    public DateTime? FechaRechazo { get; set; }
    public string? MotivoRechazo { get; set; }
    public bool PuedeEnviar => EnvioWorkflowEstados.PuedeEnviar(Estado);
    public bool PuedeRechazar => EnvioWorkflowEstados.PuedeRechazar(Estado);
}

public static class EnvioWorkflowEstados
{
    public const string Pendiente = "PENDIENTE";
    public const string Procesando = "PROCESANDO";
    public const string Enviado = "ENVIADO";
    public const string Rechazado = "RECHAZADO";
    public const string Parcial = "PARCIAL";

    public static string Normalizar(string? estado)
    {
        return estado?.Trim().ToUpperInvariant() switch
        {
            Procesando => Procesando,
            Enviado => Enviado,
            Rechazado => Rechazado,
            Parcial => Parcial,
            _ => Pendiente
        };
    }

    public static bool PuedeEnviar(string? estado)
    {
        var normalizado = Normalizar(estado);
        return normalizado is Pendiente or Rechazado or Parcial;
    }

    public static bool PuedeRechazar(string? estado)
    {
        return Normalizar(estado) == Enviado;
    }
}

public static class EnvioWorkflowProcesos
{
    public const string CotizacionCorreo = "COTIZACION_CORREO";
    public const string EstudioMercadoCotizacion = "ESTUDIO_MERCADO_COTIZACION";
    public const string PolizaFirma = "POLIZA_FIRMA";
}
