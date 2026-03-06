
namespace EG.Domain.DTOs.Requests.ConteoCiclico
{
    public class DiscrepanciaDto
    {
        public int PkidDiscrepancia { get; set; }

        public int FkidArticuloConteoAlma { get; set; }

        public decimal Valor1 { get; set; }

        public decimal Valor2 { get; set; }

        public decimal? Valor3 { get; set; }

        public decimal? ValorAceptado { get; set; }

        public string MetodoResolucion { get; set; }

        public int? FkidSupervisorSis { get; set; }

        public DateTime? FechaResolucion { get; set; }

        public string ObservacionesResolucion { get; set; }
    }
}
