using EG.Common.Modules;

namespace EG.UnidTest.Application;

public sealed class RequisitionDateRulesTests
{
    private static readonly DateTime Requisition = new(2026, 4, 10, 0, 0, 0, DateTimeKind.Unspecified);

    [Fact]
    public void RequiresTheRequisitionDate()
    {
        Assert.Equal(
            "La fecha de requisicion es requerida.",
            RequisitionDateRules.Validate(null, Requisition, Requisition.AddDays(1)));
    }

    [Theory]
    [InlineData(true, false)]
    [InlineData(false, true)]
    public void RequiresSupplyRange(bool missingStart, bool missingEnd)
    {
        DateTime? start = missingStart ? null : Requisition;
        DateTime? end = missingEnd ? null : Requisition.AddDays(1);

        Assert.Equal(
            "Las fechas de inicio y fin de suministro son requeridas.",
            RequisitionDateRules.Validate(Requisition, start, end));
    }

    [Fact]
    public void RequestDateMustNotBeAfterSupplyStart()
    {
        var validation = RequisitionDateRules.Validate(
            Requisition.AddDays(1),
            Requisition,
            Requisition.AddDays(2));

        Assert.Equal("La fecha de requisicion no puede ser posterior al inicio de suministro.", validation);
    }

    [Fact]
    public void SupplyStartMustNotBeAfterSupplyEnd()
    {
        var validation = RequisitionDateRules.Validate(
            Requisition,
            Requisition.AddDays(2),
            Requisition.AddDays(1));

        Assert.Equal("La fecha de inicio de suministro no puede ser posterior a la fecha fin.", validation);
    }

    [Fact]
    public void SameDayBoundsAreValidAndCompareByCalendarDate()
    {
        var request = Requisition.AddHours(8);
        var start = Requisition.AddHours(9);
        var end = Requisition.AddHours(17);

        Assert.Null(RequisitionDateRules.Validate(request, start, end));
    }
}
