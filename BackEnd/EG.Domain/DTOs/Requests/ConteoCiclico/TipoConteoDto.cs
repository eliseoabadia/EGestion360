namespace EG.Domain.DTOs.Responses.ConteoCiclico
{
    public class TipoConteoDto
    {
        public int PkidTipoConteo { get; set; }
        public string Nombre { get; set; } = string.Empty;
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
    }
}
