namespace EG.Domain.DTOs.Responses.Tesoreria
{
    public class VwClcfacturaImporteResponse
    {
        public int PkidFactura { get; set; }
        public int FkidEmpresaSis { get; set; }
        public string EmpresaNombre { get; set; } = string.Empty;
        public int FkidContratoPres { get; set; }
        public string NumeroContrato { get; set; } = string.Empty;
        public int FkidProveedorSis { get; set; }
        public string Rfc { get; set; } = string.Empty;
        public string Nombre { get; set; } = string.Empty;
        public int FkidPolizaConta { get; set; }
        public string ClavePoliza { get; set; } = string.Empty;
        public string NumFactura { get; set; } = string.Empty;
        public string SerieFactura { get; set; } = string.Empty;
        public DateOnly Fecha { get; set; }
        public DateOnly? FechaRecepcion { get; set; }
        public decimal? Subtotal { get; set; }
        public decimal? Iva { get; set; }
        public decimal? Retencion { get; set; }
        public decimal Importe { get; set; }
        public string Uuid { get; set; } = string.Empty;
        public string Fldocto { get; set; } = string.Empty;
        public string Concepto { get; set; } = string.Empty;
        public int Estatus { get; set; }
        public string EstatusDescripcion { get; set; } = string.Empty;
        public decimal Ene { get; set; }
        public decimal Feb { get; set; }
        public decimal Mar { get; set; }
        public decimal Abr { get; set; }
        public decimal May { get; set; }
        public decimal Jun { get; set; }
        public decimal Jul { get; set; }
        public decimal Ago { get; set; }
        public decimal Sep { get; set; }
        public decimal Oct { get; set; }
        public decimal Nov { get; set; }
        public decimal Dic { get; set; }
        public decimal DevengadoIngresos { get; set; }
        public decimal DevengadoEgresos { get; set; }
        public decimal? SaldoClc { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
    }
}
