
namespace EG.Domain.DTOs.Responses.General
{
    public class EmpresaResponse
    {
        public int PkidEmpresa { get; set; }

        public string EmpresaNombre { get; set; }

        public string NombreCorto { get; set; }

        public string Rfc { get; set; }

        public string RazonSocial { get; set; }

        public string Giro { get; set; }

        public int FkidMonedaBaseSis { get; set; }

        public int? FkidIdiomaPreferidoSis { get; set; }

        public string Logo { get; set; }

        public byte[] LogoEmpresa { get; set; }

        public bool EmpresaActivo { get; set; }

        public DateTime? EmpresaFechaCreacion { get; set; }

        public int EmpresaUsuarioCreacion { get; set; }

        public DateTime? EmpresaFechaModificacion { get; set; }

        public int? EmpresaUsuarioModificacion { get; set; }

        public int PkidEstado { get; set; }

        public int FkidPaisSis { get; set; }

        public string EstadoNombre { get; set; }

        public string CodigoEstado { get; set; }

        public bool EstadoActivo { get; set; }

        public DateOnly? FechaApertura { get; set; }

        public bool EsOficinaPrincipal { get; set; }

        public bool RelacionActiva { get; set; }

        public string RegImss { get; set; }

        public string RegInfonavit { get; set; }

        public string CedEmpadronam { get; set; }

        public string NoFonacot { get; set; }

        public string UsAdmin { get; set; }

        public string EmailAdmin { get; set; }

        public int? FkidPeriodoPagoSis { get; set; }

        public decimal? PrimaRiesgoImss { get; set; }

        public bool UsaSueldoTabular { get; set; }

        public int? FkidTipoPagoNom { get; set; }
    }
}
