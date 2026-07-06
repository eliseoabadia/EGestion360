using EG.Domain.DTOs.Responses.Presupuestales;

namespace EG.Domain.DTOs.Requests.Presupuestales
{
    public class EgresoProyectadoAiImportUploadRequest
    {
        public string NombreOriginal { get; set; } = string.Empty;
        public string TipoMime { get; set; } = "application/octet-stream";
        public long TamanoBytes { get; set; }
        public byte[] Contenido { get; set; } = [];
        public EgresoProyectadoAiImportHeaderRequest HeaderFallback { get; set; } = new();
    }

    public class EgresoProyectadoAiImportConfirmRequest
    {
        public string SourceFileName { get; set; } = string.Empty;
        public EgresoProyectadoAiImportHeaderRequest Header { get; set; } = new();
        public List<EgresoProyectadoAiImportRowRequest> Rows { get; set; } = [];
    }

    public class EgresoProyectadoAiImportHeaderRequest
    {
        public int? FkidAnioSis { get; set; }
        public int? Anio { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public string? EmpresaNombre { get; set; }
        public DateTime? Fecha { get; set; }
    }

    public class EgresoProyectadoAiImportRowRequest
    {
        public int RowNumber { get; set; }
        public string? Programa { get; set; }
        public int? FkidProgramaPres { get; set; }
        public string? ProgramaDescripcion { get; set; }
        public string? Partida { get; set; }
        public int? FkidPartidaConta { get; set; }
        public string? PartidaDescripcion { get; set; }
        public string? Area { get; set; }
        public int? FkidAreaSis { get; set; }
        public string? AreaDescripcion { get; set; }
        public string? Descripcion { get; set; }
        public DateTime? Fecha { get; set; }
        public string? FuenteFinanciamiento { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public string? FuenteFinanciamientoDescripcion { get; set; }
        public string? TipoGasto { get; set; }
        public int? FkidTipoGastoPres { get; set; }
        public string? TipoGastoDescripcion { get; set; }
        public string? DigitoIdentificador { get; set; }
        public int? FkidDigitoIdentificadorPres { get; set; }
        public string? DigitoIdentificadorDescripcion { get; set; }
        public string? DestinoGasto { get; set; }
        public int? FkidDestinoGastoPres { get; set; }
        public string? DestinoGastoDescripcion { get; set; }
        public string? Py { get; set; }
        public int? FkidPyPres { get; set; }
        public string? PyDescripcion { get; set; }
        public decimal Enero { get; set; }
        public decimal Febrero { get; set; }
        public decimal Marzo { get; set; }
        public decimal Abril { get; set; }
        public decimal Mayo { get; set; }
        public decimal Junio { get; set; }
        public decimal Julio { get; set; }
        public decimal Agosto { get; set; }
        public decimal Septiembre { get; set; }
        public decimal Octubre { get; set; }
        public decimal Noviembre { get; set; }
        public decimal Diciembre { get; set; }
        public decimal Total { get; set; }
    }

    public class EgresoProyectadoAiImportPreviewResponse
    {
        public string SourceFileName { get; set; } = string.Empty;
        public EgresoProyectadoAiImportHeaderRequest Header { get; set; } = new();
        public List<EgresoProyectadoAiImportRowRequest> Rows { get; set; } = [];
        public List<EgresoProyectadoAiImportValidationMessage> Messages { get; set; } = [];
        public List<string> DetectedColumns { get; set; } = [];
        public decimal Total { get; set; }
        public bool CanImport { get; set; }
        public int ImportedCount { get; set; }
        public List<int> ImportedIds { get; set; } = [];
        public List<EgresoProyectadoResponse> ImportedRows { get; set; } = [];
    }

    public class EgresoProyectadoAiImportValidationMessage
    {
        public string Severity { get; set; } = "Info";
        public string Code { get; set; } = string.Empty;
        public string Message { get; set; } = string.Empty;
        public int? RowNumber { get; set; }
        public string? Field { get; set; }
    }
}
