namespace EG.Domain.DTOs.Requests.Nomina;

public abstract class NominaRhDetailDtoBase
{
    public int FkidPersonaNom { get; set; }

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; } = true;
}

public sealed class NominaRhExpedienteDto : NominaRhDetailDtoBase
{
    public int PkidExpediente { get; set; }
    public string NombreDocumento { get; set; } = string.Empty;
    public string Ruta { get; set; } = string.Empty;
    public string Descripcion { get; set; } = string.Empty;
    public DateOnly? FechaExpedicion { get; set; }
    public bool? NecesitaRenovacion { get; set; }
    public DateOnly? FechaRenovacion { get; set; }
    public int? FkidTipoExpedienteNom { get; set; }
}

public sealed class NominaRhContratoDto : NominaRhDetailDtoBase
{
    public int PkidContratoLaboral { get; set; }
    public int FkidEmpresaNominaNom { get; set; }
    public DateOnly FechaInicio { get; set; }
    public DateOnly FechaFin { get; set; }
    public int FkidPuestoNom { get; set; }
    public string NumeroContrato { get; set; } = string.Empty;
    public string Vigencia { get; set; } = string.Empty;
    public decimal SueldoMensual { get; set; }
    public int? FkidNombramientoNom { get; set; }
    public int? FkidDepartamentoSis { get; set; }
    public string Departamento { get; set; } = string.Empty;
    public int? FkidTipoContratacionSis { get; set; }
    public string TipoContratacion { get; set; } = string.Empty;
}

public sealed class NominaRhDependienteDto : NominaRhDetailDtoBase
{
    public int PkidDependiente { get; set; }
    public string Nombre { get; set; } = string.Empty;
    public int? FkidParentescoSis { get; set; }
    public string Parentesco { get; set; } = string.Empty;
    public DateOnly? FechaNacimiento { get; set; }
}

public sealed class NominaRhIncidenciaDto : NominaRhDetailDtoBase
{
    public int PkidIncidencia { get; set; }
    public int? FkidTipoIncidenciaNom { get; set; }
    public DateOnly? Fecha { get; set; }
    public string Comentario { get; set; } = string.Empty;
    public int? FkidTipoJustificacionNom { get; set; }
    public bool? AplicaDescuento { get; set; }
    public string ComentarioJustificacion { get; set; } = string.Empty;
    public int? FkidPeriodoQuincenalSis { get; set; }
}

public sealed class NominaRhPensionDto : NominaRhDetailDtoBase
{
    public int PkidPension { get; set; }
    public string NombreBeneficiario { get; set; } = string.Empty;
    public string Documento { get; set; } = string.Empty;
    public DateOnly? FechaDocumento { get; set; }
    public decimal? Porcentaje { get; set; }
    public int? FkidTipoPensionNom { get; set; }
    public DateTime? FechaInicio { get; set; }
    public DateTime? FechaFin { get; set; }
    public string Banco { get; set; } = string.Empty;
    public string CuentaBancaria { get; set; } = string.Empty;
    public string Clabe { get; set; } = string.Empty;
    public string FormaPago { get; set; } = string.Empty;
    public int? FkidCuentaContableSis { get; set; }
}
