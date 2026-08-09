namespace EG.Domain.DTOs.Requests.Almacen
{
    public class MotivoEsDto
    {
        public int PkidMotivoEs { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool AplicaEntrada { get; set; }
        public bool AplicaSalida { get; set; }
        public bool Activo { get; set; }
        public int? UsuarioCreacion { get; set; }
        public DateTime? FechaCreacion { get; set; }
    }
}
