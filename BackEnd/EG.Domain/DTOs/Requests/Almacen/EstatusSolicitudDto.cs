namespace EG.Domain.DTOs.Requests.Almacen
{
    public class EstatusSolicitudDto
    {
        public int PkidEstatusSolicitud { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}
