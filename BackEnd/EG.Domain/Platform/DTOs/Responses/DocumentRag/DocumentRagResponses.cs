namespace EG.Domain.DTOs.Responses.DocumentRag
{
    public class DocumentRagSessionResponse
    {
        public Guid SessionId { get; set; }
        public string Modulo { get; set; } = "RAG";
        public string? SubModulo { get; set; }
        public string? Controlador { get; set; }
        public string? Servicio { get; set; }
        public long? EntidadId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public string? Titulo { get; set; }
        public string? Descripcion { get; set; }
        public int UsuarioId { get; set; }
        public DateTime CreatedAtUtc { get; set; }
        public DateTime LastAccessAtUtc { get; set; }
        public DateTime ExpiresAtUtc { get; set; }
        public int DocumentCount { get; set; }
        public int IndexedChunkCount { get; set; }
        public long TotalBytes { get; set; }
        public List<DocumentRagDocumentResponse> Documents { get; set; } = [];
        public List<DocumentRagHistoryItemResponse> History { get; set; } = [];
    }

    public class DocumentRagDocumentResponse
    {
        public Guid DocumentId { get; set; }
        public string NombreOriginal { get; set; } = string.Empty;
        public string Extension { get; set; } = string.Empty;
        public string TipoMime { get; set; } = string.Empty;
        public long TamanoBytes { get; set; }
        public int CharacterCount { get; set; }
        public int ChunkCount { get; set; }
        public string Status { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public DateTime UploadedAtUtc { get; set; }
    }

    public class DocumentRagAskResponse
    {
        public Guid SessionId { get; set; }
        public Guid QuestionId { get; set; }
        public string Question { get; set; } = string.Empty;
        public string Answer { get; set; } = string.Empty;
        public bool AnsweredFromDocuments { get; set; }
        public DateTime AskedAtUtc { get; set; }
        public List<DocumentRagCitationResponse> Citations { get; set; } = [];
    }

    public class DocumentRagHistoryItemResponse
    {
        public Guid QuestionId { get; set; }
        public string Question { get; set; } = string.Empty;
        public string Answer { get; set; } = string.Empty;
        public bool AnsweredFromDocuments { get; set; }
        public DateTime AskedAtUtc { get; set; }
        public List<DocumentRagCitationResponse> Citations { get; set; } = [];
    }

    public class DocumentRagCitationResponse
    {
        public Guid DocumentId { get; set; }
        public string DocumentName { get; set; } = string.Empty;
        public int ChunkIndex { get; set; }
        public int? Page { get; set; }
        public double Score { get; set; }
        public string Snippet { get; set; } = string.Empty;
    }
}
