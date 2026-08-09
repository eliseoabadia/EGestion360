namespace EG.Domain.DTOs.Responses.Patrimonio
{
    public class BajaResponse
    {
        public int PkidBaja { get; set; }
        public string Folio { get; set; } = string.Empty;
        public int FkidEmpresaSis { get; set; }
        public int? FkidAnioSis { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int? FkidAreaSis { get; set; }
        public string AreaClave { get; set; } = string.Empty;
        public string AreaNombre { get; set; } = string.Empty;
        public int FkidBienAlma { get; set; }
        public string BienClave { get; set; } = string.Empty;
        public string BienClaveAnterior { get; set; } = string.Empty;
        public string BienDescripcion { get; set; } = string.Empty;
        public string Modelo { get; set; } = string.Empty;
        public string Serie { get; set; } = string.Empty;
        public string Factura { get; set; } = string.Empty;
        public decimal? ValorActual { get; set; }
        public int FkidTipoBienAlma { get; set; }
        public string TipoBienCodigoClave { get; set; } = string.Empty;
        public string TipoBienDescripcion { get; set; } = string.Empty;
        public int FkidTipoBajaAlma { get; set; }
        public string TipoBajaClave { get; set; } = string.Empty;
        public string TipoBajaDescripcion { get; set; } = string.Empty;
        public int FkidEstatusBajaAlma { get; set; }
        public string EstatusDescripcion { get; set; } = string.Empty;
        public string EstatusColor { get; set; } = string.Empty;
        public int? FkidEstadoBienAnteriorAlma { get; set; }
        public string EstadoAnterior { get; set; } = string.Empty;
        public int? FkidEstadoBienDestinoAlma { get; set; }
        public string EstadoDestino { get; set; } = string.Empty;
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
        public string ClavePoliza { get; set; } = string.Empty;
        public int? SolicitadoPorNom { get; set; }
        public int? AutorizadoPorNom { get; set; }
        public DateTime? FechaAutorizacion { get; set; }
        public bool Activo { get; set; }
        public DateTime FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public bool EsFinal { get; set; }
    }
}
