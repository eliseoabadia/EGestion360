namespace EG.Common.GenericModel
{
    public class PagedRequest
    {
        public int Page { get; set; }
        public int PageSize { get; set; }
        public string Filtro { get; set; }
        public string SortLabel { get; set; }
        public string SortDirection { get; set; }
        public string SearchString { get; set; }
        public Dictionary<string, object> AdditionalFilters { get; set; } = new Dictionary<string, object>();
    }
}
