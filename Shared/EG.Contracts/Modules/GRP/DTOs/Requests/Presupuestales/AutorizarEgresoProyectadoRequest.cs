namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class AutorizarEgresoProyectadoRequest
    {
        public int? FkidPolizaConta { get; set; }
        public string? Descripcion { get; set; }
    }
}
