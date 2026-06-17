namespace EG.Domain.DTOs.Responses.Nomina;

public abstract class NominaRhDetailResponseBase
{
    public int FkidPersonaNom { get; set; }

    public string ClavePersona { get; set; } = string.Empty;

    public string NombreCompleto { get; set; } = string.Empty;

    public string Rfc { get; set; } = string.Empty;

    public string Curp { get; set; } = string.Empty;

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }
}

public sealed class NominaRhExpedienteResponse : NominaRhDetailResponseBase
{
    public int PkidExpediente { get; set; }

    public string NombreDocumento { get; set; } = string.Empty;

    public string Ruta { get; set; } = string.Empty;

    public string Descripcion { get; set; } = string.Empty;

    public DateOnly? FechaExpedicion { get; set; }

    public bool? NecesitaRenovacion { get; set; }

    public DateOnly? FechaRenovacion { get; set; }

    public int? FkidTipoExpedienteNom { get; set; }

    public string TipoExpedienteDescripcion { get; set; } = string.Empty;

    public bool? TipoExpedienteActivo { get; set; }

    public string ClaveNombre => NombreDocumento;
}

public sealed class NominaRhContratoResponse : NominaRhDetailResponseBase
{
    public int PkidContratoLaboral { get; set; }

    public int FkidEmpresaNominaNom { get; set; }

    public DateOnly FechaInicio { get; set; }

    public DateOnly FechaFin { get; set; }

    public int FkidPuestoNom { get; set; }

    public string PuestoNombre { get; set; } = string.Empty;

    public string NumeroContrato { get; set; } = string.Empty;

    public string Vigencia { get; set; } = string.Empty;

    public decimal SueldoMensual { get; set; }

    public int? FkidNombramientoNom { get; set; }

    public int? FkidDepartamentoSis { get; set; }

    public string Departamento { get; set; } = string.Empty;

    public string DepartamentoNombre { get; set; } = string.Empty;

    public string DepartamentoDescripcion { get; set; } = string.Empty;

    public int? FkidTipoContratacionSis { get; set; }

    public string TipoContratacion { get; set; } = string.Empty;

    public string TipoContratacionDescripcion { get; set; } = string.Empty;

    public string TipoContratacionClave { get; set; } = string.Empty;

    public string ClaveNombre => NumeroContrato;
}

public sealed class NominaRhDependienteResponse : NominaRhDetailResponseBase
{
    public int PkidDependiente { get; set; }

    public string Nombre { get; set; } = string.Empty;

    public int? FkidParentescoSis { get; set; }

    public string Parentesco { get; set; } = string.Empty;

    public DateOnly? FechaNacimiento { get; set; }

    public string NombreCompletoPersona
    {
        get => NombreCompleto;
        set => NombreCompleto = value;
    }

    public string ParentescoDescripcion { get; set; } = string.Empty;

    public bool? ParentescoActivo { get; set; }

    public string ClaveNombre => Nombre;
}

public sealed class NominaRhIncidenciaResponse : NominaRhDetailResponseBase
{
    public int PkidIncidencia { get; set; }

    public int? FkidTipoIncidenciaNom { get; set; }

    public DateOnly? Fecha { get; set; }

    public string Comentario { get; set; } = string.Empty;

    public int? FkidTipoJustificacionNom { get; set; }

    public bool? AplicaDescuento { get; set; }

    public string ComentarioJustificacion { get; set; } = string.Empty;

    public int? FkidPeriodoQuincenalSis { get; set; }

    public string TipoIncidenciaDescripcion { get; set; } = string.Empty;

    public double? TipoIncidenciaDiasPenalizacion { get; set; }

    public bool? TipoIncidenciaActivo { get; set; }

    public string TipoJustificacionDescripcion { get; set; } = string.Empty;

    public bool? TipoJustificacionActivo { get; set; }

    public string ClaveNombre => string.IsNullOrWhiteSpace(TipoIncidenciaDescripcion)
        ? $"Incidencia {PkidIncidencia}"
        : TipoIncidenciaDescripcion;
}

public sealed class NominaRhPensionResponse : NominaRhDetailResponseBase
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

    public string TipoPensionDescripcion { get; set; } = string.Empty;

    public bool? TipoPensionActivo { get; set; }

    public string CuentaContable { get; set; } = string.Empty;

    public string SubCuentaContable { get; set; } = string.Empty;

    public string SubSubCuentaContable { get; set; } = string.Empty;

    public string SubSubSubCuentaContable { get; set; } = string.Empty;

    public string SubSubSubSubCuentaContable { get; set; } = string.Empty;

    public string CuentaContableDescripcion { get; set; } = string.Empty;

    public bool? CuentaContableActivo { get; set; }

    public string ClaveNombre => NombreBeneficiario;
}

public sealed class NominaRhLookupResponse
{
    public int Id { get; set; }

    public string Catalogo { get; set; } = string.Empty;

    public string Clave { get; set; } = string.Empty;

    public string Descripcion { get; set; } = string.Empty;

    public bool Activo { get; set; }

    public string ClaveNombre => string.IsNullOrWhiteSpace(Clave)
        ? Descripcion
        : $"{Clave} - {Descripcion}";
}
