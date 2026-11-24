using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.General;
using EG.Domain.Interfaces;
using EG.Infraestructure.Models;
using Microsoft.EntityFrameworkCore;

namespace EG.Infrastructure;

public sealed class CatalogLookupQueries(EGestionContext context) : ICatalogLookupQueries
{
    // Auxiliary accounts are owned by a company; the remaining catalogs are shared reference data.
    public IQueryable<CatalogLookupValue> Query(CatalogLookupKind catalog, int? parentId = null, int? empresaId = null) => catalog switch
    {
        CatalogLookupKind.CuentaAuxiliarProveedor => context.CuentaContables.AsNoTracking()
            .Where(x => empresaId.HasValue && x.FkidEmpresaSis == empresaId.Value && x.Activo && x.IsCuentaDetalle == 1 && x.ClaveOrdNormalizada.StartsWith("2112"))
            .OrderBy(x => x.ClaveOrd)
            .Select(x => new CatalogLookupValue { Id = x.PkidCuentaContable, Text = x.ClaveOrd + " - " + x.Descripcion }),
        CatalogLookupKind.TipoProveedor => context.TipoProveedors.AsNoTracking().Where(x => x.Activo)
            .OrderBy(x => x.Descripcion).Select(x => new CatalogLookupValue { Id = x.PkIdTipoProveedor, Text = x.Descripcion }),
        CatalogLookupKind.EstatusProveedor => context.EstatusProveedors.AsNoTracking().Where(x => x.Activo)
            .OrderBy(x => x.Descripcion).Select(x => new CatalogLookupValue { Id = x.PkidEstatusProveedor, Text = x.Descripcion }),
        CatalogLookupKind.Pais => context.Paises.AsNoTracking().Where(x => x.Activo)
            .OrderBy(x => x.Nombre).Select(x => new CatalogLookupValue { Id = x.PkidPais, Text = x.Nombre }),
        CatalogLookupKind.Estado => context.Estados.AsNoTracking()
            .Where(x => x.Activo && (!parentId.HasValue || x.FkidPaisSis == parentId.Value))
            .OrderBy(x => x.Nombre).Select(x => new CatalogLookupValue { Id = x.PkidEstado, Text = x.Nombre }),
        CatalogLookupKind.Municipio => context.Municipios.AsNoTracking()
            .Where(x => x.Activo && (!parentId.HasValue || x.FkidEstadoSis == parentId.Value))
            .OrderBy(x => x.Nombre).Select(x => new CatalogLookupValue { Id = x.PkidMunicipio, Text = x.Nombre }),
        CatalogLookupKind.TipoBienCapitulo5000 => context.TipoBiens.AsNoTracking()
            .Where(x => x.Activo && x.FkidPartidaContaNavigation.Activo && x.FkidPartidaContaNavigation.Clave.StartsWith("5"))
            .OrderBy(x => x.CodigoClave)
            .Select(x => new CatalogLookupValue { Id = x.PkidTipoBien, Text = x.CodigoClave + " - " + x.Descripcion }),
        CatalogLookupKind.CuentaPresupuestalIngreso => context.VwCuentas.AsNoTracking()
            .Where(x => x.Activo && x.NivelCuenta == 7 && x.ClaveOrd.StartsWith("8 1"))
            .OrderBy(x => x.ClaveNombre).Select(x => new CatalogLookupValue { Id = x.PkIdCuenta, Text = x.ClaveNombre ?? string.Empty }),
        CatalogLookupKind.CuentaDepositoIngreso => context.VwCuentas.AsNoTracking()
            .Where(x => x.Activo && x.NivelCuenta == 7 && x.ClaveOrd.StartsWith("1"))
            .OrderBy(x => x.ClaveNombre).Select(x => new CatalogLookupValue { Id = x.PkIdCuenta, Text = x.ClaveNombre ?? string.Empty }),
        CatalogLookupKind.Programa => context.Set<Programa>().AsNoTracking()
            .Where(x => x.Activo && (!parentId.HasValue || x.FkidAnioSis == parentId.Value))
            .OrderBy(x => x.Clave).Select(x => new CatalogLookupValue { Id = x.PkidPrograma, Text = (x.Clave ?? "") + " - " + (x.Descripcion ?? "") }),
        CatalogLookupKind.Partida => context.Set<Partidum1>().AsNoTracking().Where(x => x.Activo)
            .OrderBy(x => x.Descripcion).Select(x => new CatalogLookupValue { Id = x.PkidPartida, Text = x.Descripcion ?? "" }),
        CatalogLookupKind.TipoGasto => context.TipoGastos.AsNoTracking().Where(x => x.Activo)
            .OrderBy(x => x.Clave).Select(x => new CatalogLookupValue { Id = x.PkidTipoGasto, Text = x.Clave + " - " + x.Descripcion }),
        CatalogLookupKind.CuentaAprobado or CatalogLookupKind.CuentaPorEjercer or CatalogLookupKind.CuentaModificado or
            CatalogLookupKind.CuentaComprometido or CatalogLookupKind.CuentaDevengado or CatalogLookupKind.CuentaEjercido or
            CatalogLookupKind.CuentaPagado or CatalogLookupKind.CuentaGasto => CuentaQuery(catalog, true),
        _ => throw new ArgumentOutOfRangeException(nameof(catalog))
    };

    public IQueryable<CatalogLookupValue> QueryLegacy(CatalogLookupKind catalog, int? anioId = null)
    {
        if (catalog == CatalogLookupKind.Programa)
        {
            return context.Set<Programa>().AsNoTracking()
                .Where(x => !anioId.HasValue || x.MatrizConversions.Any(matrix => matrix.FkidAnioSis == anioId.Value && matrix.Activo))
                .Select(x => new CatalogLookupValue { Id = x.PkidPrograma, Text = x.Clave }).Distinct();
        }
        if (catalog == CatalogLookupKind.Partida)
        {
            return context.Set<Partidum1>().AsNoTracking().Where(x => x.Activo)
                .Select(x => new CatalogLookupValue { Id = x.PkidPartida, Text = x.Descripcion }).Distinct();
        }
        return CuentaQuery(catalog, false).Distinct();
    }

    private IQueryable<CatalogLookupValue> CuentaQuery(CatalogLookupKind catalog, bool activeOnly)
    {
        var prefix = catalog switch
        {
            CatalogLookupKind.CuentaAprobado => "8 2 1",
            CatalogLookupKind.CuentaPorEjercer => "8 2 2",
            CatalogLookupKind.CuentaModificado => "8 2 3",
            CatalogLookupKind.CuentaComprometido => "8 2 4",
            CatalogLookupKind.CuentaDevengado => "8 2 5",
            CatalogLookupKind.CuentaEjercido => "8 2 6",
            CatalogLookupKind.CuentaPagado => "8 2 7",
            CatalogLookupKind.CuentaGasto => "5",
            _ => throw new ArgumentOutOfRangeException(nameof(catalog))
        };
        return context.VwCuentas.AsNoTracking()
            .Where(x => (!activeOnly || x.Activo) && x.NivelCuenta == 7 && x.ClaveOrd.StartsWith(prefix))
            .OrderBy(x => x.ClaveNombre).Select(x => new CatalogLookupValue { Id = x.PkIdCuenta, Text = x.ClaveNombre ?? "" });
    }

    public IQueryable<PeriodoPagoResponse> PeriodosPago() => context.VwPeriodoPagos.AsNoTracking()
        .Where(x => x.Activo).OrderBy(x => x.Orden ?? x.LegacyId ?? x.PkidCatalogoSimple)
        .Select(x => new PeriodoPagoResponse
        {
            PkidCatalogoSimple = x.PkidCatalogoSimple,
            LegacyId = x.LegacyId,
            Descripcion = x.Descripcion,
            DescripcionCorta = x.DescripcionCorta,
            Orden = x.Orden,
            Activo = x.Activo
        });

    public IQueryable<OrcoProyectoResponse> ProyectosActivos() => context.Pies.AsNoTracking()
        .Where(x => x.Activo).Select(x => new OrcoProyectoResponse
        {
            PkidProyecto = x.PkidPy,
            Descripcion = x.Descripcion ?? string.Empty,
            Activo = x.Activo
        });
}
