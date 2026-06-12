namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class PaaaspartidaDto
    {
        public int FkidEmpresaSis { get; set; }
        public int FkidPaaasOrco { get; set; }
        public int FkidPartidaConta { get; set; }
        public string Observaciones { get; set; } = string.Empty;
        public bool Activo { get; set; } = true;
    }
}
