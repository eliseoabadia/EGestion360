namespace EG.Common.GenericModel
{
    public class PagedResult<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public string Code { get; set; }

        public T Data { get; set; }
        public IList<T> Items { get; set; } = new List<T>();
        public int TotalCount { get; set; }
    }
}
