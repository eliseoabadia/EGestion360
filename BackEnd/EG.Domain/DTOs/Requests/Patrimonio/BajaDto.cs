namespace EG.Domain.DTOs.Requests.Patrimonio
{
    public class BajaDto
    {
        public int PkidBaja { get; set; }
        public string Folio { get; set; } = string.Empty;
        public int FkidEmpresaSis { get; set; }
        public int? FkidAreaSis { get; set; }
        public int FkidBienAlma { get; set; }
        public int FkidTipoBajaAlma { get; set; }
        public int FkidEstatusBajaAlma { get; set; }
        public int? FkidEstadoBienAnteriorAlma { get; set; }
        public int? FkidEstadoBienDestinoAlma { get; set; }
        public DateTime FechaSolicitud { get; set; }
        public DateTime? FechaBaja { get; set; }
        public string Referencia { get; set; } = string.Empty;
        public DateTime? FechaReferencia { get; set; }
        public string Destinatario { get; set; } = string.Empty;
        public string Recibo { get; set; } = string.Empty;
        public decimal? Cantidad { get; set; }
        public string Motivo { get; set; } = string.Empty;
        public string Dictamen { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public int? FkidPolizaConta { get; set; }
        public int? SolicitadoPorNom { get; set; }
        public int? AutorizadoPorNom { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
