
using EG.Business.Services.PresupuestoModificado;
using EG.Domain.DTOs.Responses.PresupuestoModificado;
using EG.UnidTest.Support;
using System.Globalization;

namespace EG.UnidTest.Application;

public sealed class IncomeAmountValidationTests
{
    [Fact]
    public async Task MissingHeaderDateInJsonCannotBeReplacedByToday()
    {
        var request = System.Text.Json.JsonSerializer.Deserialize<IngreAdecuacionResponse>("{\"FkidAnioSis\":1}")!;
        var service = new IngreAdecuacionOperationsService(null!, null!, null!, new FixedUserContext(7, 3));
        var result = await service.CreateAsync(request, 7);
        Assert.False(result.Success);
        Assert.Equal("VALIDATION", result.Code);
        Assert.Equal(default, request.Fecha);
        Assert.Contains("fecha", result.Message);
    }

    [Fact]
    public async Task MissingDetailDateInJsonIsRejectedBeforePersistence()
    {
        var request = System.Text.Json.JsonSerializer.Deserialize<IngreAdecuacionDetalleResponse>(
            "{\"FkidIngreAdecuacionPres\":1,\"FkidIngresoAutorizadoPres\":2,\"FkidTipoMovimientoPres\":3,\"Enero\":1}")!;
        var service = new IngreAdecuacionDetalleOperationsService(null!, null!, null!, new FixedUserContext(7, 3));
        var result = await service.CreateAsync(request, 7);
        Assert.False(result.Success);
        Assert.Equal("VALIDATION", result.Code);
        Assert.Contains("fecha", result.Message);
    }

    public static IEnumerable<object[]> MonthNames => new[]
    {
        "Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"
    }.Select(month => new object[] { month });

    [Theory]
    [MemberData(nameof(MonthNames))]
    public async Task NegativeMonthIsRejectedBeforeAnyDatabaseAccess(string month)
    {
        var request = Valid();
        typeof(IngreAdecuacionDetalleResponse).GetProperty(month)!.SetValue(request, -0.01m);
        var service = new IngreAdecuacionDetalleOperationsService(null!, null!, null!, new FixedUserContext(7, 3));
        var result = await service.CreateAsync(request, 7);
        Assert.False(result.Success);
        Assert.Equal("VALIDATION", result.Code);
        Assert.Contains("negativo", result.Message);
        Assert.Equal(-0.01m, typeof(IngreAdecuacionDetalleResponse).GetProperty(month)!.GetValue(request));
    }

    [Theory]
    [InlineData("0", false)]
    [InlineData("0.01", true)]
    [InlineData("1234.56", true)]
    [InlineData("0.001", false)]
    [InlineData("9999999999999999.99", true)]
    [InlineData("10000000000000000", false)]
    [InlineData("79228162514264337593543950335", false)]
    [InlineData("-79228162514264337593543950335", false)]
    public void MonetaryRangeAndScaleMatchTheStoredProcedure(string input, bool valid)
    {
        var request = Valid();
        request.Enero = decimal.Parse(input, CultureInfo.InvariantCulture);
        Assert.Equal(valid, IncomeCaptureRules.ValidateDetailCapture(request) == null);
        Assert.Equal(decimal.Parse(input, CultureInfo.InvariantCulture), request.Enero);
    }

    [Fact]
    public void TotalCannotOverflowTheProcedureEvenWhenEachMonthFits()
    {
        var request = Valid();
        request.Enero = IncomeCaptureRules.MaximumAmount;
        request.Febrero = 0.01m;
        Assert.Contains("total", IncomeCaptureRules.ValidateDetailCapture(request));
    }

    [Theory]
    [InlineData(1, false)]
    [InlineData(2, false)]
    [InlineData(3, true)]
    [InlineData(4, true)]
    public void OnlyIncomeMovementTypesAreAccepted(int movement, bool valid)
    {
        var request = Valid();
        request.FkidTipoMovimientoPres = movement;
        Assert.Equal(valid, IncomeCaptureRules.ValidateDetailCapture(request) == null);
    }

    private static IngreAdecuacionDetalleResponse Valid() => new()
    {
        FkidIngreAdecuacionPres = 1, FkidIngresoAutorizadoPres = 2,
        FkidTipoMovimientoPres = 3, Fecha = new(2026, 1, 1), Enero = 1m
    };
}
