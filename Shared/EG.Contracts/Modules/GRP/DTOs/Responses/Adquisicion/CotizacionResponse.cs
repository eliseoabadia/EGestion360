namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class CotizacionResponse
    {
        public int PkidCotizacion { get; set; }
        public int FkidRequisicionOrco { get; set; }
        public string RequisicionDescripcion { get; set; } = string.Empty;
        public int FkidProveedorSis { get; set; }
        public string ProveedorNombre { get; set; } = string.Empty;
        public string ProveedorClave { get; set; } = string.Empty;
        public string ProveedorRfc { get; set; } = string.Empty;
        public DateTime FechaSolicitud { get; set; }
        public DateTime? FechaProveedorCotiza { get; set; }
        public DateTime? FechaProveedorCompromiso { get; set; }
        public string? Comentarios { get; set; }
        public bool Servicio { get; set; }
        public string? FlDocumento { get; set; }
        public string? Entrega { get; set; }
        public string? Vigencia { get; set; }
        public string? Condiciones { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? FkidContenedorCotOrco { get; set; }
        public int? FkidContenedorMultiCotOrco { get; set; }
        public int TotalDetalles { get; set; }
        public decimal TotalCotizado { get; set; }
        public string EstadoEnvio { get; set; } = "PENDIENTE";
        public DateTime? FechaEnvio { get; set; }
        public DateTime? FechaRechazoEnvio { get; set; }
        public bool PuedeEnviar { get; set; } = true;
        public bool PuedeRechazar { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
