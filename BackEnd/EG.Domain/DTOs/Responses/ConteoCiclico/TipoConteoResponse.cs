namespace EG.Domain.DTOs.Responses.ConteoCiclico
{
    public class TipoConteoResponse
    {
        public int PkidTipoConteo { get; set; }

        public string Nombre { get; set; }

        public string Descripcion { get; set; }

        public bool Activo { get; set; }
    }
}
