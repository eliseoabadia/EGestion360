using System;
using System.Collections.Generic;
using System.Text;

namespace EG.Domain.DTOs.Responses
{
    public class BusquedaRequest
    {
        public int Page { get; set; } = 1;
        public int PageSize { get; set; } = 10;
        public string? TerminoBusqueda { get; set; }
        public string? SortLabel { get; set; }
        public string? SortDirection { get; set; }
    }
}
