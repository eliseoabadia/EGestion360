using EG.Common.Modules;

namespace EG.UnidTest.Presentation;

public sealed class IncomeAmountSummaryTests
{
    [Fact]
    public void InvalidMonthDoesNotProduceAPartialTotal()
    {
        Assert.False(IncomeAmountRules.TrySum([100m, decimal.MaxValue], out var total));
        Assert.Equal(0m, total);
    }

    [Fact]
    public void TotalLimitIsCheckedWithoutOverflow()
    {
        Assert.False(IncomeAmountRules.TrySum([IncomeAmountRules.MaximumAmount, 0.01m], out var total));
        Assert.Equal(0m, total);
    }

    [Fact]
    public void InvalidPrecisionCannotBeHiddenInFormattedTotal()
    {
        Assert.NotNull(IncomeAmountRules.ValidateMonth(0.001m));
        Assert.False(IncomeAmountRules.TrySum([0.001m], out _));
    }

    [Fact]
    public void ValidMonthlyValuesAreAddedExactly()
    {
        Assert.True(IncomeAmountRules.TrySum([1234.56m, 0.01m], out var total));
        Assert.Equal(1234.57m, total);
    }

    [Fact]
    public void EmptyInputIsAllowedForAMonthWhileTotalRemainsZero()
    {
        Assert.Null(IncomeAmountRules.ValidateMonth(null));
        Assert.True(IncomeAmountRules.TrySum([0m, 0m], out var total));
        Assert.Equal(0m, total);
    }
}
