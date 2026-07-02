using EG.Domain.DTOs.Responses.Contabilidad;

namespace EG.Domain.DTOs.Requests.Contabilidad
{
    public class PolizaAiImportUploadRequest
    {
        public string NombreOriginal { get; set; } = string.Empty;
        public string TipoMime { get; set; } = "application/octet-stream";
        public long TamanoBytes { get; set; }
        public byte[] Contenido { get; set; } = [];
        public PolizaAiImportHeaderRequest HeaderFallback { get; set; } = new();
    }

    public class PolizaAiImportConfirmRequest
    {
        public string SourceFileName { get; set; } = string.Empty;
        public PolizaAiImportHeaderRequest Header { get; set; } = new();
        public List<PolizaAiImportDetailRequest> Details { get; set; } = [];
    }

    public class PolizaAiImportHeaderRequest
    {
        public int? FkidEmpresaSis { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? Anio { get; set; }
        public int? FkidMesSis { get; set; }
        public string? Mes { get; set; }
        public int? FkidTipoPolizaSis { get; set; }
        public string? TipoPoliza { get; set; }
        public string? ClavePoliza { get; set; }
        public string? NombrePoliza { get; set; }
        public DateTime? FechaPoliza { get; set; }
        public bool PermitirModificar { get; set; } = true;
        public bool Autorizado { get; set; }
    }

    public class PolizaAiImportDetailRequest
    {
        public int RowNumber { get; set; }
        public string Cuenta { get; set; } = string.Empty;
        public int? FkidCuentaContableConta { get; set; }
        public string? CuentaDescripcion { get; set; }
        public int? FkidTipoDetallePolizaSis { get; set; }
        public string? TipoDetallePoliza { get; set; }
        public string? Descripcion { get; set; }
        public decimal? ImporteDebe { get; set; }
        public decimal? ImporteHaber { get; set; }
    }

    public class PolizaAiImportPreviewResponse
    {
        public string SourceFileName { get; set; } = string.Empty;
        public PolizaAiImportHeaderRequest Header { get; set; } = new();
        public List<PolizaAiImportDetailRequest> Details { get; set; } = [];
        public List<PolizaAiImportValidationMessage> Messages { get; set; } = [];
        public List<string> DetectedColumns { get; set; } = [];
        public decimal TotalDebe { get; set; }
        public decimal TotalHaber { get; set; }
        public decimal Diferencia { get; set; }
        public bool EstaCuadrada { get; set; }
        public bool CanImport { get; set; }
        public int? ImportedPolizaId { get; set; }
        public PolizaResponse? Poliza { get; set; }
    }

    public class PolizaAiImportValidationMessage
    {
        public string Severity { get; set; } = "Info";
        public string Code { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public int? RowNumber { get; set; }
        public string? Field { get; set; }
    }
}
