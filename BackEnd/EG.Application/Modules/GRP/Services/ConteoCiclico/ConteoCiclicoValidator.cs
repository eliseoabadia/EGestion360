using EG.Domain.DTOs.Requests.ConteoCiclico;

namespace EG.Application.Services.ConteoCiclico;

public static class ConteoCiclicoValidator
{
    public static void ValidatePeriodo(PeriodoConteoDto dto)
    {
        ArgumentNullException.ThrowIfNull(dto);

        if (string.IsNullOrWhiteSpace(dto.CodigoPeriodo))
            throw new ArgumentException("El codigo del periodo es requerido.");

        if (string.IsNullOrWhiteSpace(dto.Nombre))
            throw new ArgumentException("El nombre del periodo es requerido.");

        if (dto.FechaFin.HasValue && dto.FechaFin.Value < dto.FechaInicio)
            throw new ArgumentException("La fecha fin no puede ser anterior a la fecha de inicio.");

        if (dto.MaximoConteosPorArticulo is < 1 or > 10)
            throw new ArgumentException("El maximo de conteos por articulo debe estar entre 1 y 10.");

        if (dto.FkidResponsableSis.GetValueOrDefault() <= 0)
            throw new ArgumentException("Selecciona a la persona responsable del conteo.");

        if (dto.RequiereAprobacionSupervisor && dto.FkidSupervisorSis.GetValueOrDefault() <= 0)
            throw new ArgumentException("Selecciona un supervisor cuando el periodo requiere aprobacion.");
    }

    public static void ValidateConteo(ConteoDto dto)
    {
        ArgumentNullException.ThrowIfNull(dto);

        if (dto.FkidTipoBienAlma <= 0)
            throw new ArgumentException("Selecciona un tipo de bien valido.");

        if (dto.CantidadInventario < 0)
            throw new ArgumentException("La cantidad de inventario no puede ser negativa.");

        if (dto.FechaInicio == default)
            throw new ArgumentException("La fecha de inicio es requerida.");

        if (dto.FechaFin.HasValue && dto.FechaFin.Value < dto.FechaInicio)
            throw new ArgumentException("La fecha fin no puede ser anterior a la fecha de inicio.");
    }
}
