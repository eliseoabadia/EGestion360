namespace EG.Domain.DTOs.Responses.Adquisicion
{
    public class RequisicionResponse
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
        public string EmpresaNombre { get; set; } = string.Empty;
        public string EmpresaRfc { get; set; } = string.Empty;
        public int? AnioClave { get; set; }
        public string AreaNombre { get; set; } = string.Empty;
        public string AreaClave { get; set; } = string.Empty;
        public string SolicitanteNombre { get; set; } = string.Empty;
        public string SolicitantePaterno { get; set; } = string.Empty;
        public string SolicitanteMaterno { get; set; } = string.Empty;
        public string SolicitanteCompleto { get; set; } = string.Empty;
        public string ProyectoDescripcion { get; set; } = string.Empty;
        public string ProgramaClave { get; set; } = string.Empty;
        public string ProgramaDescripcion { get; set; } = string.Empty;
        public string FuenteFinanciamientoClave { get; set; } = string.Empty;
        public string FuenteFinanciamientoDescripcion { get; set; } = string.Empty;
        public int? TipoGastoClave { get; set; }
        public string TipoGastoDescripcion { get; set; } = string.Empty;
        public string DigitoIdentificadorClave { get; set; } = string.Empty;
        public string DigitoIdentificadorDescripcion { get; set; } = string.Empty;
        public string DestinoGastoClave { get; set; } = string.Empty;
        public string DestinoGastoDescripcion { get; set; } = string.Empty;
        public string SuficienciaDescripcion { get; set; } = string.Empty;
        public string EgresoAutorizadoDescripcion { get; set; } = string.Empty;
        public DateOnly? EgresoAutorizadoFecha { get; set; }
        public string JefeAlmacenCompleto { get; set; } = string.Empty;
        public string SupervisoCompleto { get; set; } = string.Empty;
        public string AutorizoCompleto { get; set; } = string.Empty;
        public string PsolicitaCompleto { get; set; } = string.Empty;
        public string PjefeAlmacenCompleto { get; set; } = string.Empty;
        public string PsuficienciaCompleto { get; set; } = string.Empty;
        public string PsupervisoCompleto { get; set; } = string.Empty;
        public string PautorizoCompleto { get; set; } = string.Empty;
        public string ClaveNombre { get; set; } = string.Empty;
        public int CotizacionesActivas { get; set; }
        public int PartidasActivas { get; set; }
        public int PartidasConPosicionPresupuestal { get; set; }
        public decimal MontoPartidas { get; set; }
        public int DetallesActivos { get; set; }
        public int DetallesCotizados { get; set; }
        public int DetallesEnSuficiencia { get; set; }
        public int SuficienciasActivas { get; set; }
        public bool BloqueadaPorCotizacion => CotizacionesActivas > 0 || SuficienciasActivas > 0;
        public bool TienePosicionPresupuestalValida =>
            FkidProgramaPres.HasValue && FkidProgramaPres.Value > 0 &&
            FkidEgresoAutorizadoPres.HasValue && FkidEgresoAutorizadoPres.Value > 0;
        public bool PartidasPresupuestalesCompletas =>
            PartidasActivas > 0 &&
            PartidasConPosicionPresupuestal == PartidasActivas &&
            Importe.HasValue &&
            MontoPartidas == Importe.Value;
        public bool ListaParaCotizar =>
            TienePosicionPresupuestalValida &&
            PartidasPresupuestalesCompletas &&
            DetallesActivos > 0;
        public bool TodosLosDetallesCotizados =>
            DetallesActivos > 0 && DetallesCotizados >= DetallesActivos;
        public bool TodosLosDetallesEnSuficiencia =>
            DetallesActivos > 0 && DetallesEnSuficiencia >= DetallesActivos;
        public byte[]? RowVersion { get; set; }
    }
}
