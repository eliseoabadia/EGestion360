namespace EG.Domain.DTOs.Requests.ConteoCiclico
{
    public class TipoConteoDto
    {
        public int PkidTipoConteo { get; set; }

        public string Nombre { get; set; }

        public string Descripcion { get; set; }

        public bool Activo { get; set; }
    }
}
