namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class PaaasdetalleDto
    {
        public int PkidPaaasdetalle { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidPaaaspartidaOrco { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public int? FkidUnidadesAlma { get; set; }
        public decimal Cantidad { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public string LugarEntrega { get; set; } = string.Empty;
        public bool Activo { get; set; } = true;
    }
}
