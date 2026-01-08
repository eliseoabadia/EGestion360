namespace EG.Application.CommonModel
{
    public class PagedRequest
    {
        public int Page { get; set; }
        public int PageSize { get; set; }
        public string Filtro { get; set; }
        public string SortLabel { get; set; }
        public string SortDirection { get; set; }

    }
}
