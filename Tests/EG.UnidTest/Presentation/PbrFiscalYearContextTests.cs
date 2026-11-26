using EG.Web.Models.Forms;

namespace EG.UnidTest.Presentation;

public sealed class PbrFiscalYearContextTests
{
    [Theory]
    [InlineData(null, false)]
    [InlineData(0, false)]
    [InlineData(-1, false)]
    [InlineData(2026, true)]
    public void SelectedYearMustBePositive(int? selectedYear, bool expected)
    {
        Assert.Equal(expected, PbrFiscalYearContext.TryGetSelectedYear(selectedYear, out _));
    }

    [Fact]
    public void MissingSelectedYearDoesNotSubstituteTheCalendarYear()
    {
        var item = new AnnualRecord();

        var valid = PbrFiscalYearContext.Apply(item, selectedYear: null, overwrite: true);

        Assert.False(valid);
        Assert.Equal(0, item.Anio);
    }

    [Fact]
    public void MissingSelectedYearPreservesTheSavedYear()
    {
        var item = new AnnualRecord { Anio = 2024 };

        var valid = PbrFiscalYearContext.Apply(item, selectedYear: null, overwrite: true);

        Assert.True(valid);
        Assert.Equal(2024, item.Anio);
    }

    [Fact]
    public void SelectedYearFillsAnUninitializedYearWithoutReplacingAnExistingOne()
    {
        var item = new AnnualRecord { Anio = 2024 };

        var valid = PbrFiscalYearContext.Apply(item, selectedYear: 2026, overwrite: false);

        Assert.True(valid);
        Assert.Equal(2024, item.Anio);
    }

    [Fact]
    public void SelectedYearReplacesTheYearWhenOverwriteIsRequested()
    {
        var item = new AnnualRecord { Anio = 2024 };

        var valid = PbrFiscalYearContext.Apply(item, selectedYear: 2026, overwrite: true);

        Assert.True(valid);
        Assert.Equal(2026, item.Anio);
    }

    [Fact]
    public void NullableYearMustAlsoBePresentOrSelected()
    {
        var item = new OptionalYearRecord();

        Assert.False(PbrFiscalYearContext.Apply(item, selectedYear: null, overwrite: true));
        Assert.True(PbrFiscalYearContext.Apply(item, selectedYear: 2026, overwrite: true));
        Assert.Equal(2026, item.Anio);
    }

    [Fact]
    public void NonAnnualRecordDoesNotRequireFiscalYear()
    {
        Assert.True(PbrFiscalYearContext.Apply(new NonAnnualRecord(), selectedYear: null, overwrite: true));
    }

    private sealed class AnnualRecord
    {
        public int Anio { get; set; }
    }

    private sealed class OptionalYearRecord
    {
        public int? Anio { get; set; }
    }

    private sealed class NonAnnualRecord
    {
    }
}
