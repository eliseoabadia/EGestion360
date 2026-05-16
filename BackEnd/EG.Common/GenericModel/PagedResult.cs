using EG.Common.Enums;

namespace EG.Common.GenericModel
{
    public class PagedResult<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string Code { get; set; } = ApiResponseCode.Error.ToCode();

        public T Data { get; set; }
        public IList<T> Items { get; set; } = new List<T>();
        public int TotalCount { get; set; }
    }
}
