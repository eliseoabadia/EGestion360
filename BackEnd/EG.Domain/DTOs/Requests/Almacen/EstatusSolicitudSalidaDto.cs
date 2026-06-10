namespace EG.Domain.DTOs.Requests.Almacen
{
    public class EstatusSolicitudSalidaDto
    {
        public int PkidEstatusSolicitudSalida { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Color { get; set; } = string.Empty;
        public int Orden { get; set; }
        public bool EsFinal { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
