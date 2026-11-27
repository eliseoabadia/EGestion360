using EG.Common.GenericModel;

namespace EG.UnidTest.Business;

public sealed class PagingPolicyTests
{
    [Theory]
    [InlineData(int.MaxValue, int.MaxValue)]
    [InlineData(-1, 0)]
    [InlineData(2, 50)]
    public void NormalizationBoundsMemoryAndPreventsOffsetOverflow(int page, int size)
    {
        var request = new PagedRequest { Page = page, PageSize = size };
        PagingPolicy.Normalize(request);
        Assert.InRange(request.PageSize, 1, 250);
        Assert.True(request.Page >= 1);
        Assert.InRange(checked((request.Page - 1) * request.PageSize), 0, int.MaxValue);
        if (page == 2) { Assert.Equal(2, request.Page); Assert.Equal(50, request.PageSize); }
    }
}
