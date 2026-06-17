// <manual> Modelos NOM agregados para completar dependencias RH/EMP migradas. </manual>
#nullable disable
using System;
using System.Collections.Generic;

namespace EG.Infraestructure.Models;

public partial class NomEmpresaNomina
{
    public int PkidEmpresaNomina { get; set; }

    public string RazonSocial { get; set; }

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

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }

    public virtual ICollection<NomPuesto> Puestos { get; set; } = new List<NomPuesto>();
}

public partial class NomUniverso
{
    public int PkidUniverso { get; set; }

    public string Descripcion { get; set; }

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }

    public virtual ICollection<NomNivel> Niveles { get; set; } = new List<NomNivel>();
}

public partial class NomNivel
{
    public int PkidNivel { get; set; }

    public string Clave { get; set; }

    public int? FkidUniversoNom { get; set; }

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }

    public virtual NomUniverso FkidUniversoNomNavigation { get; set; }

    public virtual ICollection<NomPuesto> Puestos { get; set; } = new List<NomPuesto>();
}

public partial class NomClasePuesto
{
    public int PkidClasePuesto { get; set; }

    public string Descripcion { get; set; }

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }

    public virtual ICollection<NomPuesto> Puestos { get; set; } = new List<NomPuesto>();
}

public partial class NomPuesto
{
    public int PkidPuesto { get; set; }

    public int? FkidPuestoPadreNom { get; set; }

    public int FkidEmpresaNominaNom { get; set; }

    public string Nombre { get; set; }

    public int? FkidNivelNom { get; set; }

    public int? FkidClasePuestoNom { get; set; }

    public string Descripcion1 { get; set; }

    public string Descripcion2 { get; set; }

    public int? Orden { get; set; }

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }

    public virtual NomPuesto FkidPuestoPadreNomNavigation { get; set; }

    public virtual NomEmpresaNomina FkidEmpresaNominaNomNavigation { get; set; }

    public virtual NomNivel FkidNivelNomNavigation { get; set; }

    public virtual NomClasePuesto FkidClasePuestoNomNavigation { get; set; }

    public virtual ICollection<NomPuesto> InverseFkidPuestoPadreNomNavigation { get; set; } = new List<NomPuesto>();
}

public partial class NomNombramiento
{
    public int PkidNombramiento { get; set; }

    public string Descripcion { get; set; }

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }
}

public partial class NomImporteNivel
{
    public int PkidImporteNivel { get; set; }

    public string Clave { get; set; }

    public decimal ImpSdi { get; set; }

    public decimal ImpImss15 { get; set; }

    public decimal ImpImss16 { get; set; }

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }
}

public partial class NomContratoLaboral
{
    public int PkidContratoLaboral { get; set; }

    public int FkidEmpresaNominaNom { get; set; }

    public int FkidPersonaNom { get; set; }

    public DateOnly FechaInicio { get; set; }

    public DateOnly FechaFin { get; set; }

    public int FkidPuestoNom { get; set; }

    public string NumeroContrato { get; set; }

    public string Vigencia { get; set; }

    public decimal SueldoMensual { get; set; }

    public int? FkidNombramientoNom { get; set; }

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }

    public virtual NomEmpresaNomina FkidEmpresaNominaNomNavigation { get; set; }

    public virtual Persona FkidPersonaNomNavigation { get; set; }

    public virtual NomPuesto FkidPuestoNomNavigation { get; set; }

    public virtual NomNombramiento FkidNombramientoNomNavigation { get; set; }
}

public partial class NomCatalogoSimple
{
    public int PkidCatalogoSimple { get; set; }

    public string Catalogo { get; set; }

    public string LegacyTable { get; set; }

    public int? LegacyId { get; set; }

    public string Clave { get; set; }

    public string Descripcion { get; set; }

    public string DescripcionCorta { get; set; }

    public int? FkidCatalogoPadreNom { get; set; }

    public decimal? ValorDecimal1 { get; set; }

    public decimal? ValorDecimal2 { get; set; }

    public int? ValorEntero1 { get; set; }

    public int? ValorEntero2 { get; set; }

    public DateTime? FechaInicio { get; set; }

    public DateTime? FechaFin { get; set; }

    public string DatoExtra1 { get; set; }

    public string DatoExtra2 { get; set; }

    public int? Orden { get; set; }

    public int? UsuarioCreacion { get; set; }

    public DateTime? FechaCreacion { get; set; }

    public int? UsuarioModificacion { get; set; }

    public DateTime? FechaModificacion { get; set; }

    public bool Activo { get; set; }
}
