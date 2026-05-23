namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class SolicitudSuficienciaDto
    {
        public int PkidSolicitudSuficiencia { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public DateOnly FechaSolicitud { get; set; }
        public string? Justificacion { get; set; }
        public string? GastoNoProgramable { get; set; }
        public int? IdGastoNoProgramable { get; set; }
        public int? IdCompromisoNomina { get; set; }
        public int Estatus { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
