using System.ComponentModel.DataAnnotations;

namespace EG.Web.Models.Configuration;

public partial class PeriodoConteoResponse
{
    public int Id { get; set; }

    [Display(Name = "Código")]
    public string CodigoPeriodo { get; set; } = string.Empty;

    [Display(Name = "Nombre del Periodo")]
    public string Nombre { get; set; } = string.Empty;

    [Display(Name = "Descripción")]
    public string Descripcion { get; set; } = string.Empty;

    [Display(Name = "Sucursal")]
    public int SucursalId { get; set; }

    [Display(Name = "Sucursal")]
    public string SucursalNombre { get; set; } = string.Empty;

    [Display(Name = "Tipo de Conteo")]
    public int TipoConteoId { get; set; }

    [Display(Name = "Tipo de Conteo")]
    public string TipoConteoNombre { get; set; } = string.Empty;

    [Display(Name = "Fecha Inicio")]
    public DateTime FechaInicio { get; set; }

    [Display(Name = "Fecha Fin")]
    public DateTime? FechaFin { get; set; }

    [Display(Name = "Estatus")]
    public int EstatusId { get; set; }

    [Display(Name = "Estatus")]
    public string EstatusNombre { get; set; } = string.Empty;

    [Display(Name = "Color Estatus")]
    public string EstatusColor { get; set; } = "#FFA500";

    [Display(Name = "Total Artículos")]
    public int TotalArticulos { get; set; }

    [Display(Name = "Artículos Concluidos")]
    public int ArticulosConcluidos { get; set; }

    [Display(Name = "Artículos Pendientes")]
    public int ArticulosPendientes { get; set; }

    [Display(Name = "Artículos con Diferencia")]
    public int ArticulosConDiferencia { get; set; }

    [Display(Name = "Porcentaje Avance")]
    public decimal? PorcentajeAvance { get; set; }

    [Display(Name = "Responsable")]
    public int ResponsableId { get; set; }

    [Display(Name = "Responsable")]
    public string ResponsableNombre { get; set; } = string.Empty;

    [Display(Name = "Supervisor")]
    public int? SupervisorId { get; set; }

    [Display(Name = "Supervisor")]
    public string? SupervisorNombre { get; set; }

    [Display(Name = "Observaciones")]
    public string? Observaciones { get; set; }

    [Display(Name = "Activo")]
    public bool Activo { get; set; }

    [Display(Name = "Fecha Creación")]
    public DateTime FechaCreacion { get; set; }

    [Display(Name = "Creado Por")]
    public string CreadoPor { get; set; } = string.Empty;

    [Display(Name = "Fecha Modificación")]
    public DateTime? FechaModificacion { get; set; }

    [Display(Name = "Modificado Por")]
    public string? ModificadoPor { get; set; }
}

public class PeriodoConteoCreateDto
{
    [Required(ErrorMessage = "El código es requerido")]
    [StringLength(50, ErrorMessage = "El código no puede exceder 50 caracteres")]
    [Display(Name = "Código")]
    public string CodigoPeriodo { get; set; } = string.Empty;

    [Required(ErrorMessage = "El nombre es requerido")]
    [StringLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
    [Display(Name = "Nombre")]
    public string Nombre { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
    [Display(Name = "Descripción")]
    public string? Descripcion { get; set; }

    [Required(ErrorMessage = "La sucursal es requerida")]
    [Display(Name = "Sucursal")]
    public int SucursalId { get; set; }

    [Required(ErrorMessage = "El tipo de conteo es requerido")]
    [Display(Name = "Tipo de Conteo")]
    public int TipoConteoId { get; set; }

    [Required(ErrorMessage = "La fecha de inicio es requerida")]
    [Display(Name = "Fecha Inicio")]
    public DateTime FechaInicio { get; set; }

    [Display(Name = "Fecha Fin")]
    [FechaFinValidation(nameof(FechaInicio), ErrorMessage = "La fecha fin debe ser mayor a la fecha inicio")]
    public DateTime? FechaFin { get; set; }

    [Required(ErrorMessage = "El responsable es requerido")]
    [Display(Name = "Responsable")]
    public int ResponsableId { get; set; }

    [Display(Name = "Supervisor")]
    public int? SupervisorId { get; set; }

    [Display(Name = "Observaciones")]
    public string? Observaciones { get; set; }

    [Display(Name = "Activo")]
    public bool Activo { get; set; } = true;

    [Display(Name = "Artículos a Incluir")]
    public List<int> ArticulosSeleccionados { get; set; } = new();
}

public class PeriodoConteoUpdateDto
{
    public int Id { get; set; }

    [Required(ErrorMessage = "El código es requerido")]
    [StringLength(50, ErrorMessage = "El código no puede exceder 50 caracteres")]
    [Display(Name = "Código")]
    public string CodigoPeriodo { get; set; } = string.Empty;

    [Required(ErrorMessage = "El nombre es requerido")]
    [StringLength(100, ErrorMessage = "El nombre no puede exceder 100 caracteres")]
    [Display(Name = "Nombre")]
    public string Nombre { get; set; } = string.Empty;

    [StringLength(500, ErrorMessage = "La descripción no puede exceder 500 caracteres")]
    [Display(Name = "Descripción")]
    public string? Descripcion { get; set; }

    [Required(ErrorMessage = "La fecha de inicio es requerida")]
    [Display(Name = "Fecha Inicio")]
    public DateTime FechaInicio { get; set; }

    [Display(Name = "Fecha Fin")]
    public DateTime? FechaFin { get; set; }

    [Display(Name = "Responsable")]
    public int ResponsableId { get; set; }

    [Display(Name = "Supervisor")]
    public int? SupervisorId { get; set; }

    [Display(Name = "Observaciones")]
    public string? Observaciones { get; set; }

    [Display(Name = "Activo")]
    public bool Activo { get; set; }
}

public class FechaFinValidationAttribute : ValidationAttribute
{
    private readonly string _fechaInicioPropertyName;

    public FechaFinValidationAttribute(string fechaInicioPropertyName)
    {
        _fechaInicioPropertyName = fechaInicioPropertyName;
    }

    protected override ValidationResult? IsValid(object? value, ValidationContext validationContext)
    {
        var fechaFin = value as DateTime?;
        if (!fechaFin.HasValue)
            return ValidationResult.Success;

        var fechaInicioProperty = validationContext.ObjectType.GetProperty(_fechaInicioPropertyName);
        if (fechaInicioProperty == null)
            return new ValidationResult($"Propiedad {_fechaInicioPropertyName} no encontrada");

        var fechaInicio = (DateTime)fechaInicioProperty.GetValue(validationContext.ObjectInstance)!;

        if (fechaFin.Value <= fechaInicio)
            return new ValidationResult(ErrorMessage ?? "La fecha fin debe ser mayor a la fecha inicio");

        return ValidationResult.Success;
    }
}

public class PeriodoConteoResumenDto
{
    public int Id { get; set; }
    public string CodigoPeriodo { get; set; } = string.Empty;
    public string Nombre { get; set; } = string.Empty;
    public string Sucursal { get; set; } = string.Empty;
    public string TipoConteo { get; set; } = string.Empty;
    public string Estatus { get; set; } = string.Empty;
    public int TotalArticulos { get; set; }
    public int ConteosRealizados { get; set; }
    public int ConteosPendientes { get; set; }
    public int Diferencias { get; set; }
    public decimal Avance { get; set; }
    public string Responsable { get; set; } = string.Empty;
    public DateTime FechaInicio { get; set; }
}