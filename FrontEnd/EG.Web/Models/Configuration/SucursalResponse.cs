namespace EG.Web.Models.Configuration
{
    public class SucursalResponse
    {
        public int PkidSucursal { get; set; }

        public int FkidEmpresaSis { get; set; }

        public int FkidEstadoSis { get; set; }

        public string Nombre { get; set; }

        public string CodigoSucursal { get; set; }

        public string Alias { get; set; }

        public int FkidTipoSucursal { get; set; }

        public int? FkidMonedaLocalSis { get; set; }

        public string Direccion { get; set; }

        public string Colonia { get; set; }

        public string Ciudad { get; set; }

        public string CodigoPostal { get; set; }

        public string TelefonoPrincipal { get; set; }

        public string TelefonoSecundario { get; set; }

        public string Email { get; set; }

        public TimeOnly? HorarioApertura { get; set; }

        public TimeOnly? HorarioCierre { get; set; }

        public bool EsMatriz { get; set; }

        public bool EsActiva { get; set; }

        public decimal? Latitud { get; set; }

        public decimal? Longitud { get; set; }

        public string NombreEmpresa { get; set; }

        public string Rfc { get; set; }

        public string NombreEstado { get; set; }

        public string CodigoEstado { get; set; }

        public string NombrePais { get; set; }

        public bool Activo { get; set; }

        public DateTime? FechaCreacion { get; set; }

        public int UsuarioCreacion { get; set; }

        public DateTime? FechaModificacion { get; set; }

        public int? UsuarioModificacion { get; set; }
    }
}
