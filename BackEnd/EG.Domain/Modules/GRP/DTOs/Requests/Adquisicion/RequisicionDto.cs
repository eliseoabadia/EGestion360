namespace EG.Domain.DTOs.Requests.Adquisicion
{
    public class RequisicionDto
    {
        public int PkidRequisicion { get; set; }
        public int FkidEmpresaSis { get; set; }
        public int FkidPersonaNom { get; set; }
        public int FkidAreaSis { get; set; }
        public string Descripcion { get; set; } = string.Empty;
        public string Observaciones { get; set; } = string.Empty;
        public DateTime FechaRequisicion { get; set; }
        public bool Servicio { get; set; }
        public string FlFoto { get; set; } = string.Empty;
        public int? FkidProyectoOrco { get; set; }
        public DateTime? FechaRequiereInicio { get; set; }
        public DateTime? FechaRequiereFin { get; set; }
        public int? FkidProgramaPres { get; set; }
        public decimal? Importe { get; set; }
        public int? FkidJefeAlmacenNom { get; set; }
        public int? FkidSuficienciaPres { get; set; }
        public int? FkidSupervisoNom { get; set; }
        public int? FkidAutorizoNom { get; set; }
        public int? FkidPsolicitaNom { get; set; }
        public int? FkidPjefeAlmacenNom { get; set; }
        public int? FkidPsuficienciaNom { get; set; }
        public int? FkidPsupervisoNom { get; set; }
        public int? FkidPautorizoNom { get; set; }
        public int? FkidFuenteFinanciamientoPres { get; set; }
        public int? FkidAnioSis { get; set; }
        public int? FkidTipoGastoPres { get; set; }
        public int? FkidDigitoIdentificadorPres { get; set; }
        public int? FkidDestinoGastoPres { get; set; }
        public int? FkidEgresoAutorizadoPres { get; set; }
        public string Oficio { get; set; } = string.Empty;
        public DateTime? FechaOficio { get; set; }
        public bool? CompraDirecta { get; set; }
        public bool Activo { get; set; }
        public DateTime? FechaCreacion { get; set; }
        public int UsuarioCreacion { get; set; }
        public DateTime? FechaModificacion { get; set; }
        public int? UsuarioModificacion { get; set; }
        public byte[]? RowVersion { get; set; }
    }
}
