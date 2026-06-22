namespace EG.Domain.DTOs.Responses.Nomina;

/// <summary>
/// DTO para la vista nom.Vw_Incidencia - Listado de incidencias con datos del empleado y detalles
/// </summary>
public sealed class VwRhIncidenciaResponse
{
    /// <summary>ID primario de la incidencia</summary>
    public int PkidIncidencia { get; set; }

    /// <summary>ID de la persona (empleado)</summary>
    public int FkidPersonaNom { get; set; }

    /// <summary>Nombre completo del empleado</summary>
    public string NombreCompleto { get; set; } = string.Empty;

    /// <summary>Clave del empleado</summary>
    public string ClavePersona { get; set; } = string.Empty;

    /// <summary>RFC del empleado</summary>
    public string Rfc { get; set; } = string.Empty;

    /// <summary>CURP del empleado</summary>
    public string Curp { get; set; } = string.Empty;

    /// <summary>ID del tipo de incidencia</summary>
    public int? FkidTipoIncidenciaNom { get; set; }

    /// <summary>Descripción del tipo de incidencia</summary>
    public string TipoIncidenciaDescripcion { get; set; } = string.Empty;

    /// <summary>Fecha de la incidencia</summary>
    public DateOnly? Fecha { get; set; }

    /// <summary>Comentario de la incidencia</summary>
    public string Comentario { get; set; } = string.Empty;

    /// <summary>ID del tipo de justificación</summary>
    public int? FkidTipoJustificacionNom { get; set; }

    /// <summary>Descripción del tipo de justificación</summary>
    public string TipoJustificacionDescripcion { get; set; } = string.Empty;

    /// <summary>Indica si aplica descuento</summary>
    public bool? AplicaDescuento { get; set; }

    /// <summary>Comentario de la justificación</summary>
    public string ComentarioJustificacion { get; set; } = string.Empty;

    /// <summary>ID del período quincenal</summary>
    public int? FkidPeriodoQuincenalSis { get; set; }

    /// <summary>Fecha inicio del período</summary>
    public DateOnly? FechaInicio { get; set; }

    /// <summary>Fecha fin del período</summary>
    public DateOnly? FechaFin { get; set; }

    /// <summary>Indica si la incidencia está activa (autorizada)</summary>
    public bool? Activo { get; set; }

    /// <summary>Usuario que creó el registro</summary>
    public string UsuarioCreacion { get; set; } = string.Empty;

    /// <summary>Fecha de creación</summary>
    public DateTime? FechaCreacion { get; set; }

    /// <summary>Usuario que modificó el registro</summary>
    public string UsuarioModificacion { get; set; } = string.Empty;

    /// <summary>Fecha de última modificación</summary>
    public DateTime? FechaModificacion { get; set; }
}
