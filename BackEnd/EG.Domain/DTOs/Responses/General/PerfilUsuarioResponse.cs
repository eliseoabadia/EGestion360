
namespace EG.Dommain.DTOs.Responses
{
    public class PerfilUsuarioResponse
    {
        public int FkidUsuarioSis { get; set; }

        public byte[] Fotografia { get; set; }

        public string ContentType { get; set; }

        public string FileName { get; set; }

        public string FileExtension { get; set; }

        public bool Activo { get; set; }
    }
}
