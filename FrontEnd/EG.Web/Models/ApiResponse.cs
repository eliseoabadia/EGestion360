using EG.Common.Enums;

namespace EG.Web.Models
{
    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
        public string Code { get; set; } = ApiResponseCode.Error.ToCode();
        public string? TraceId { get; set; }

        public T Data { get; set; }
        public IList<T> Items { get; set; } = new List<T>();
        public int TotalCount { get; set; }
    }
}
