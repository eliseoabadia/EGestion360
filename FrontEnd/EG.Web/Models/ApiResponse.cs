using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Web.Models
{
    public class ApiResponse<T>
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public string Code { get; set; }
        
        public T Data { get; set; }
        public IList<T> Items { get; set; } = new List<T>();
        public int TotalCount { get; set; }
    }
}


