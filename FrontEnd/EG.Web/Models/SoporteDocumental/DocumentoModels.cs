using EG.Web.Models;

namespace EG.Web.Models.SoporteDocumental
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

    public class DocumentoResponse
    {
        public long PkidDocumento { get; set; }
        public string Modulo { get; set; } = string.Empty;
        public string? SubModulo { get; set; }
        public string? Controlador { get; set; }
        public string? Servicio { get; set; }
        public long EntidadId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public string? Titulo { get; set; }
        public string? Descripcion { get; set; }
        public string NombreOriginal { get; set; } = string.Empty;
        public string NombreAlmacenado { get; set; } = string.Empty;
        public string Extension { get; set; } = string.Empty;
        public string TipoMime { get; set; } = string.Empty;
        public long TamanoBytes { get; set; }
        public string ModoAlmacenamiento { get; set; } = string.Empty;
        public string? RutaRelativa { get; set; }
        public string? HashSha256Hex { get; set; }
        public int VersionDocumento { get; set; }
        public bool EsImagen { get; set; }
        public bool EsPdf { get; set; }
        public bool Activo { get; set; }
        public int CT_CreatedBy { get; set; }
        public DateTime CT_CreatedDate { get; set; }
        public int? CT_ModifiedBy { get; set; }
        public DateTime? CT_ModifiedDate { get; set; }
    }

    public class DocumentoResumenResponse
    {
        public string Modulo { get; set; } = string.Empty;
        public string? SubModulo { get; set; }
        public string? Controlador { get; set; }
        public string? Servicio { get; set; }
        public long EntidadId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public int TotalDocumentos { get; set; }
        public long TotalBytes { get; set; }
        public DateTime? UltimaFechaDocumento { get; set; }
    }

    public class DocumentoAnotacionResponse
    {
        public long PkidDocumentoAnotacion { get; set; }
        public long FkidDocumento { get; set; }
        public string TipoAnotacion { get; set; } = string.Empty;
        public string TipoAnotacionDescripcion { get; set; } = string.Empty;
        public string? Comentario { get; set; }
        public string? TextoSeleccionado { get; set; }
        public int? Pagina { get; set; }
        public decimal? PosicionX { get; set; }
        public decimal? PosicionY { get; set; }
        public decimal? Ancho { get; set; }
        public decimal? Alto { get; set; }
        public string Color { get; set; } = "#FFE066";
        public bool Activo { get; set; }
        public int CT_CreatedBy { get; set; }
        public DateTime CT_CreatedDate { get; set; }
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

    public class DocumentoDownloadResult
    {
        public byte[] Content { get; set; } = [];
        public string FileName { get; set; } = string.Empty;
        public string ContentType { get; set; } = "application/octet-stream";
        public bool Success { get; set; }
        public string Message { get; set; } = string.Empty;
    }
}
