using EG.Common.Modules;

namespace EG.UnidTest.Application;

public sealed class RequiredDateRulesTests
{
    [Fact]
    public void RejectsNullDate()
    {
        Assert.Equal("La fecha de solicitud es requerida.", RequiredDateRules.Validate(null, "solicitud"));
    }

    [Fact]
    public void RejectsDefaultDate()
    {
        Assert.Equal("La fecha de solicitud es requerida.", RequiredDateRules.Validate(default(DateTime), "solicitud"));
    }

    [Fact]
    public void AcceptsExplicitDate()
    {
        Assert.Null(RequiredDateRules.Validate(new DateTime(2026, 4, 10), "solicitud"));
    }
}
