namespace EG.Domain.DTOs.Requests.DocumentRag
{
    public class DocumentRagSessionRequest
    {
        public string Modulo { get; set; } = "RAG";
        public string? SubModulo { get; set; }
        public string? Controlador { get; set; }
        public string? Servicio { get; set; }
        public long? EntidadId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public string? Titulo { get; set; }
        public string? Descripcion { get; set; }
    }

    public class DocumentRagUploadRequest : DocumentRagSessionRequest
    {
        public Guid SessionId { get; set; }
        public string NombreOriginal { get; set; } = string.Empty;
        public string TipoMime { get; set; } = "application/octet-stream";
        public long TamanoBytes { get; set; }
        public byte[] Contenido { get; set; } = [];
    }

    public class DocumentRagAskRequest
    {
        public Guid SessionId { get; set; }
        public string Question { get; set; } = string.Empty;
        public int? TopK { get; set; }
    }
}
