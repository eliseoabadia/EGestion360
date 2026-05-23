namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class SolicitudSuficienciaGenerarRequest
    {
        public int FkidRequisicionOrco { get; set; }
        public DateOnly FechaSolicitud { get; set; }
        public string? Justificacion { get; set; }
        public decimal PorcentajeAjuste { get; set; }
        public string? GastoNoProgramable { get; set; }
        public int? IdGastoNoProgramable { get; set; }
        public int? IdCompromisoNomina { get; set; }
    }
}
