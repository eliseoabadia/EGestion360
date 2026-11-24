using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.General;

namespace EG.Domain.Interfaces;

public sealed class CatalogLookupValue
{
    public int Id { get; set; }
    public string Text { get; set; } = string.Empty;
}

public enum CatalogLookupKind
{
    CuentaAuxiliarProveedor,
    TipoProveedor,
    EstatusProveedor,
    Pais,
    Estado,
    Municipio,
    TipoBienCapitulo5000,
    CuentaPresupuestalIngreso,
    CuentaDepositoIngreso,
    Programa,
    Partida,
    TipoGasto,
    CuentaAprobado,
    CuentaPorEjercer,
    CuentaModificado,
    CuentaComprometido,
    CuentaDevengado,
    CuentaEjercido,
    CuentaPagado,
    CuentaGasto
}

public interface ICatalogLookupQueries
{
    IQueryable<CatalogLookupValue> Query(CatalogLookupKind catalog, int? parentId = null, int? empresaId = null);
    IQueryable<PeriodoPagoResponse> PeriodosPago();
    IQueryable<OrcoProyectoResponse> ProyectosActivos();
    IQueryable<CatalogLookupValue> QueryLegacy(CatalogLookupKind catalog, int? anioId = null);
}
