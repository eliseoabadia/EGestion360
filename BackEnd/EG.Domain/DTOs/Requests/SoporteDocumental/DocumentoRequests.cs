namespace EG.Domain.DTOs.Requests.SoporteDocumental
{
    public class DocumentoEntidadRequest
    {
        public string Modulo { get; set; } = string.Empty;
        public string? SubModulo { get; set; }
        public string? Controlador { get; set; }
        public string? Servicio { get; set; }
        public long EntidadId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public bool IncluirInactivos { get; set; }
    }

    public class DocumentoUploadRequest : DocumentoEntidadRequest
    {
        public string? Titulo { get; set; }
        public string? Descripcion { get; set; }
        public string NombreOriginal { get; set; } = string.Empty;
        public string TipoMime { get; set; } = string.Empty;
        public long TamanoBytes { get; set; }
        public byte[] Contenido { get; set; } = [];
    }

    public class DocumentoAnotacionCrearRequest
    {
        public long FkidDocumento { get; set; }
        public string TipoAnotacion { get; set; } = "COMENTARIO";
        public string? Comentario { get; set; }
        public string? TextoSeleccionado { get; set; }
        public int? Pagina { get; set; }
        public decimal? PosicionX { get; set; }
        public decimal? PosicionY { get; set; }
        public decimal? Ancho { get; set; }
        public decimal? Alto { get; set; }
        public string? Color { get; set; }
    }
}
