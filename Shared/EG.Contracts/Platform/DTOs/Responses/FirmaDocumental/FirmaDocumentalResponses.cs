namespace EG.Domain.DTOs.Responses.FirmaDocumental
{
    public class FirmaProveedorResponse
    {
        public string Codigo { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public bool Disponible { get; set; }
        public bool RequiereCertificado { get; set; }
        public bool RequierePassword { get; set; }
        public string Descripcion { get; set; } = string.Empty;
    }

    public class FirmaCertificadoUsuarioResponse
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
        public bool Activo { get; set; }
        public bool Vencido { get; set; }
        public DateTime FechaRegistro { get; set; }
    }

    public class FirmaDocumentoResponse
    {
        public Guid FirmaId { get; set; }
        public long DocumentoId { get; set; }
        public string Proveedor { get; set; } = string.Empty;
        public string Estado { get; set; } = string.Empty;
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
}
