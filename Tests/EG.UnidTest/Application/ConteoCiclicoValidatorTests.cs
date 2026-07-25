using EG.Application.Services.ConteoCiclico;
using EG.Domain.DTOs.Requests.ConteoCiclico;

namespace EG.UnidTest.Application;

public class ConteoCiclicoValidatorTests
{
    [Fact]
    public void ValidatePeriodo_AcceptsValidPeriod()
    {
        var dto = ValidPeriod();

        ConteoCiclicoValidator.ValidatePeriodo(dto);
    }

    [Fact]
    public void ValidatePeriodo_RejectsEndBeforeStart()
    {
        var dto = ValidPeriod();
        dto.FechaFin = dto.FechaInicio.AddDays(-1);

        var exception = Assert.Throws<ArgumentException>(() => ConteoCiclicoValidator.ValidatePeriodo(dto));

        Assert.Contains("fecha fin", exception.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Theory]
    [InlineData(0)]
    [InlineData(11)]
    public void ValidatePeriodo_RejectsInvalidMaximum(int maximum)
    {
        var dto = ValidPeriod();
        dto.MaximoConteosPorArticulo = maximum;

        Assert.Throws<ArgumentException>(() => ConteoCiclicoValidator.ValidatePeriodo(dto));
    }

    [Fact]
    public void ValidatePeriodo_RequiresSupervisorWhenApprovalIsEnabled()
    {
        var dto = ValidPeriod();
        dto.RequiereAprobacionSupervisor = true;
        dto.FkidSupervisorSis = null;

        var exception = Assert.Throws<ArgumentException>(() => ConteoCiclicoValidator.ValidatePeriodo(dto));

        Assert.Contains("supervisor", exception.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void ValidatePeriodo_RequiresAssignedResponsible()
    {
        var dto = ValidPeriod();
        dto.FkidResponsableSis = null;

        var exception = Assert.Throws<ArgumentException>(() => ConteoCiclicoValidator.ValidatePeriodo(dto));

        Assert.Contains("responsable", exception.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void ValidateConteo_AcceptsValidCount()
    {
        ConteoCiclicoValidator.ValidateConteo(ValidCount());
    }

    [Fact]
    public void ValidateConteo_RejectsNegativeQuantity()
    {
        var dto = ValidCount();
        dto.CantidadInventario = -1;

        var exception = Assert.Throws<ArgumentException>(() => ConteoCiclicoValidator.ValidateConteo(dto));

        Assert.Contains("negativa", exception.Message, StringComparison.OrdinalIgnoreCase);
    }

    [Fact]
    public void ValidateConteo_RejectsEndBeforeStart()
    {
        var dto = ValidCount();
        dto.FechaFin = dto.FechaInicio.AddMinutes(-1);

        var exception = Assert.Throws<ArgumentException>(() => ConteoCiclicoValidator.ValidateConteo(dto));

        Assert.Contains("fecha fin", exception.Message, StringComparison.OrdinalIgnoreCase);
    }

    private static PeriodoConteoDto ValidPeriod() => new()
    {
        CodigoPeriodo = "CC-TEST",
        Nombre = "Conteo ciclico de prueba",
        FechaInicio = new DateOnly(2026, 7, 24),
        FechaFin = new DateOnly(2026, 7, 31),
        MaximoConteosPorArticulo = 3,
        FkidSucursalSis = 1,
        FkidTipoConteoAlma = 1,
        FkidEstatusAlma = 1,
        FkidResponsableSis = 1,
        Activo = true
    };

    private static ConteoDto ValidCount() => new()
    {
        FkidTipoBienAlma = 1,
        FkidPeriodoConteoAlma = 1,
        CantidadInventario = 10,
        FechaInicio = new DateTime(2026, 7, 24, 10, 0, 0),
        Activo = true
    };
}
