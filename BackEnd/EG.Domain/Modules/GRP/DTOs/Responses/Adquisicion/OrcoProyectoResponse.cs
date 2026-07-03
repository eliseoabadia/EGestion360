namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class OrcoProyectoResponse
    {
        public int PkidProyecto { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public bool Activo { get; set; }
        public string ClaveNombre => $"{PkidProyecto} - {Descripcion}".Trim(' ', '-');
    }
}
