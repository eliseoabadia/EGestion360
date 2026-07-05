namespace EG.Web.Models.Platform.FirmaDocumental
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
        public string TipoCertificado { get; set; } = string.Empty;
        public string Formato { get; set; } = string.Empty;
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
}
