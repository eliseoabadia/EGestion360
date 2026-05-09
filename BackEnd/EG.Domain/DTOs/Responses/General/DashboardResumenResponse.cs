using System.Collections.Generic;

namespace EG.Domain.DTOs.Responses.General
{
    public class DashboardResumenResponse
    {
        public string UserName { get; set; } = string.Empty;
        public string SucursalNombre { get; set; } = string.Empty;
        public List<ConteoResumen> Conteos { get; set; } = new();
    }

    public class ConteoResumen
    {
        public string Etiqueta { get; set; } = string.Empty;
        public int Conteo { get; set; }
        public string Icono { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public string Ruta { get; set; } = string.Empty;
    }
}
