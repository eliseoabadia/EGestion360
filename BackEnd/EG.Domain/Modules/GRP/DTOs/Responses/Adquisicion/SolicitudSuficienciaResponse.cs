namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class SolicitudSuficienciaResponse
    {
        public int PkidSolicitudSuficiencia { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int FkidRequisicionOrco { get; set; }
        public string RequisicionDescripcion { get; set; } = string.Empty;
        public DateTime? FechaRequisicion { get; set; }
        public decimal? RequisicionImporte { get; set; }
        public DateOnly FechaSolicitud { get; set; }
        public string Justificacion { get; set; } = string.Empty;
        public string GastoNoProgramable { get; set; } = string.Empty;
        public int? IdGastoNoProgramable { get; set; }
        public int? IdCompromisoNomina { get; set; }
        public int Estatus { get; set; }
        public string EstatusDescripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
