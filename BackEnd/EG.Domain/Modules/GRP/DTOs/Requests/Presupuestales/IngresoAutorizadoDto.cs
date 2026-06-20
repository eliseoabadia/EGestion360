namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class IngresoAutorizadoDto
    {
        public int PkidIngresoAutorizado { get; set; }
        public int FkidProgramaPres { get; set; }
        public int FkidOrigenPres { get; set; }
        public string? Descripcion { get; set; }
        public DateOnly Fecha { get; set; }
        public int? FkidPolizaConta { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public int? FkidTipoGastoPres { get; set; }
        public int? FkidDigitoIdentificadorPres { get; set; }
        public int? FkidDestinoGastoPres { get; set; }
        public decimal Enero { get; set; }
        public decimal Febrero { get; set; }
        public decimal Marzo { get; set; }
        public decimal Abril { get; set; }
        public decimal Mayo { get; set; }
        public decimal Junio { get; set; }
        public decimal Julio { get; set; }
        public decimal Agosto { get; set; }
        public decimal Septiembre { get; set; }
        public decimal Octubre { get; set; }
        public decimal Noviembre { get; set; }
        public decimal Diciembre { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public int? UsuarioAutorizacion { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
