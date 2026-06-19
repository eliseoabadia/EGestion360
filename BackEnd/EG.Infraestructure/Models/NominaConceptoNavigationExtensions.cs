namespace EG.Infraestructure.Models;

public partial class ConceptoFijo
{
    public virtual Concepto1 FkidConceptoNomNavigation { get; set; } = null!;
    public virtual Puesto FkidPuestoNomNavigation { get; set; } = null!;
}

public partial class ConceptoProporcional
{
    public virtual Concepto1? FkidConceptoNomNavigation { get; set; }
    public virtual Puesto? FkidPuestoNomNavigation { get; set; }
}

public partial class ConceptoTabular
{
    public virtual Concepto1 FkidConceptoNomNavigation { get; set; } = null!;
    public virtual Puesto FkidPuestoNomNavigation { get; set; } = null!;
}

public partial class Puesto
{
    public virtual Puesto? FkidPuestoPadreNomNavigation { get; set; }
    public virtual Nivel1? FkidNivelNomNavigation { get; set; }
    public virtual ClasePuesto? FkidClasePuestoNomNavigation { get; set; }
}

public partial class Nivel1
{
    public virtual Universo? FkidUniversoNomNavigation { get; set; }
}
