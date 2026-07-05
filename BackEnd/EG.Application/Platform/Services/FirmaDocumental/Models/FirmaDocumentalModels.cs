namespace EG.Application.Services.FirmaDocumental.Models
{
    public sealed class FirmaCertificateRecord
    {
        public Guid CertificadoId { get; set; }
        public int UsuarioId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public string Alias { get; set; } = string.Empty;
        public string TipoCertificado { get; set; } = "SAT_PFX";
        public string Formato { get; set; } = "PFX";
        public string RFC { get; set; } = string.Empty;
        public string Titular { get; set; } = string.Empty;
        public string NumeroSerie { get; set; } = string.Empty;
        public string HuellaSha256 { get; set; } = string.Empty;
        public DateTime VigenteDesde { get; set; }
        public DateTime VigenteHasta { get; set; }
        public bool Activo { get; set; } = true;
        public DateTime FechaRegistro { get; set; }
        public string ProtectedPfxBase64 { get; set; } = string.Empty;
    }

    public sealed class FirmaDocumentRecord
    {
        public Guid FirmaId { get; set; }
        public long DocumentoId { get; set; }
        public string Proveedor { get; set; } = string.Empty;
        public string Estado { get; set; } = "FIRMADO";
        public string? EntidadOrigen { get; set; }
        public long? RegistroOrigenId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public int UsuarioFirmanteId { get; set; }
        public Guid? CertificadoId { get; set; }
        public string? CertificadoSerie { get; set; }
        public string? CertificadoTitular { get; set; }
        public string? CertificadoRFC { get; set; }
        public string HashDocumentoSha256 { get; set; } = string.Empty;
        public string? FirmaBase64 { get; set; }
        public string? AlgoritmoFirma { get; set; }
        public string? Motivo { get; set; }
        public string EvidenciaJson { get; set; } = "{}";
        public DateTime FechaFirmaUtc { get; set; }
    }

    public sealed class FirmaProtectedDocumentRecord
    {
        public long DocumentoId { get; set; }
        public string TipoProteccion { get; set; } = "DOCUMENTO_OFICIAL_FIRMA";
        public string Etiqueta { get; set; } = "Documento oficial para firma";
        public string? EntidadOrigen { get; set; }
        public long? RegistroOrigenId { get; set; }
        public int? FkidEmpresaSis { get; set; }
        public int UsuarioCreacionId { get; set; }
        public DateTime FechaProteccionUtc { get; set; }
    }

    public sealed class FirmaProviderRequest
    {
        public byte[] DocumentoContenido { get; init; } = [];
        public string HashDocumentoSha256 { get; init; } = string.Empty;
        public int UsuarioFirmanteId { get; init; }
        public string? Password { get; init; }
        public string? Motivo { get; init; }
        public FirmaCertificateRecord? Certificado { get; init; }
        public byte[]? CertificadoPfx { get; init; }
    }

    public sealed class FirmaProviderResult
    {
        public string Estado { get; init; } = "FIRMADO";
        public string? FirmaBase64 { get; init; }
        public string? AlgoritmoFirma { get; init; }
        public string EvidenciaJson { get; init; } = "{}";
    }
}
