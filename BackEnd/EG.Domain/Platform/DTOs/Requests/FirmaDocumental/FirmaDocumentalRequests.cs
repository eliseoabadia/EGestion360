namespace EG.Domain.DTOs.Requests.FirmaDocumental
{
    public class FirmaCertificadoUsuarioUploadRequest
    {
        public string Alias { get; set; } = string.Empty;
        public string NombreOriginal { get; set; } = string.Empty;
        public string Extension { get; set; } = string.Empty;
        public string Password { get; set; } = string.Empty;
        public byte[] Contenido { get; set; } = [];
        public long TamanoBytes { get; set; }
        public int? FkidEmpresaSis { get; set; }
    }

    public class FirmaDocumentoCrearRequest
    {
        public long DocumentoId { get; set; }
        public string Proveedor { get; set; } = "INTERNA";
        public Guid? CertificadoId { get; set; }
        public string? Password { get; set; }
        public string? Motivo { get; set; }
        public string? EntidadOrigen { get; set; }
        public long? RegistroOrigenId { get; set; }
        public int? FkidEmpresaSis { get; set; }
    }

    public class FirmaDocumentoEntidadRequest
    {
        public string? EntidadOrigen { get; set; }
        public long? RegistroOrigenId { get; set; }
        public long? DocumentoId { get; set; }
        public int? FkidEmpresaSis { get; set; }
    }
}
