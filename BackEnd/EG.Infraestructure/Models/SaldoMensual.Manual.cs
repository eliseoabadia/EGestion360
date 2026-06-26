// <manual> Navigation properties used by migrated monthly close services. </manual>
#nullable disable

namespace EG.Infraestructure.Models;

public partial class SaldoMensual
{
    public virtual Anio FkidAnioSisNavigation { get; set; }

    public virtual CuentaContable FkidCuentaContableNavigation { get; set; }

    public virtual Usuario UsuarioCreacionNavigation { get; set; }

    public virtual Usuario UsuarioModificacionNavigation { get; set; }
}
