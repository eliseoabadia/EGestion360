namespace EG.Common.GenericModel;

public static class PagingPolicy
{
    public const int MaximumPageSize = 250;
    public const int DefaultPageSize = 10;

    public static void Normalize(PagedRequest request)
    {
        request.PageSize = Math.Clamp(request.PageSize <= 0 ? DefaultPageSize : request.PageSize, 1, MaximumPageSize);
        request.Page = Math.Clamp(request.Page, 1, int.MaxValue / request.PageSize);
    }
}
