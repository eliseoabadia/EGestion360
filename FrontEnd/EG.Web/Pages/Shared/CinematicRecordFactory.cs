using System.Globalization;
using EG.Domain.DTOs.Responses.Adquisicion;
using EG.Domain.DTOs.Responses.Contabilidad;
using EG.Domain.DTOs.Responses.Presupuestales;
using EG.Domain.DTOs.Responses.PresupuestoComprometido;
using EG.Domain.DTOs.Responses.PresupuestoModificado;

namespace EG.Web.Pages.Shared;

public static class CinematicRecordFactory
{
    private static readonly CultureInfo DateCulture = new("es-MX");
    private static readonly CultureInfo NumberCulture = CultureInfo.InvariantCulture;

    public static CinematicRecordModel ForAnteproyecto(
        EgresoProyectadoResponse item,
        string currencySymbol,
        string currencyName) => new()
    {
        Eyebrow = "ANTEPROYECTO PRESUPUESTAL",
        Title = "Anteproyecto de egresos",
        Subtitle = Text(item.Descripcion),
        RecordCode = $"ANT-{item.PkidEgresoProyectado:000000}",
        Status = item.EstaAutorizado ? "AUTORIZADO" : "PROYECTADO",
        StatusTone = item.EstaAutorizado ? "success" : "info",
        Classification = "CONSULTA",
        HeroLabel = $"Total proyectado · {currencyName}",
        HeroValue = Money(item.Total, currencySymbol),
        Sections =
        [
            Section("01", "Identidad presupuestal",
                Field("Programa", item.ProgramaClaveNombre ?? Join(item.ProgramaClave, item.ProgramaDescripcion), wide: true),
                Field("Partida", item.PartidaClaveNombre ?? Join(item.PartidaClave, item.PartidaDescripcion), wide: true),
                Field("Área", item.AreaNombre),
                Field("Ejercicio", item.AnioClave?.ToString(NumberCulture)),
                Field("Fecha", item.Fecha.ToString("dd/MM/yyyy", DateCulture))),
            Section("02", "Clasificación operativa",
                Field("Fuente de financiamiento", item.FuenteFinanciamientoClaveNombre ?? Join(item.FuenteFinanciamientoClave, item.FuenteFinanciamientoDescripcion), wide: true),
                Field("Tipo de gasto", item.TipoGastoClaveNombre ?? Join(item.TipoGastoClave?.ToString(NumberCulture), item.TipoGastoDescripcion)),
                Field("Dígito identificador", item.DigitoIdentificadorClaveNombre ?? Join(item.DigitoIdentificadorClave, item.DigitoIdentificadorDescripcion)),
                Field("Destino de gasto", item.DestinoGastoClaveNombre ?? Join(item.DestinoGastoClave, item.DestinoGastoDescripcion)),
                Field("Proyecto PY", item.PyClaveNombre ?? Join(item.PyClave, item.PyDescripcion))),
            Section("03", "Distribución mensual",
                Month("Enero", item.Enero, currencySymbol), Month("Febrero", item.Febrero, currencySymbol), Month("Marzo", item.Marzo, currencySymbol),
                Month("Abril", item.Abril, currencySymbol), Month("Mayo", item.Mayo, currencySymbol), Month("Junio", item.Junio, currencySymbol),
                Month("Julio", item.Julio, currencySymbol), Month("Agosto", item.Agosto, currencySymbol), Month("Septiembre", item.Septiembre, currencySymbol),
                Month("Octubre", item.Octubre, currencySymbol), Month("Noviembre", item.Noviembre, currencySymbol), Month("Diciembre", item.Diciembre, currencySymbol))
        ]
    };

    public static CinematicRecordModel ForPresupuestoAutorizado(
        EgresoAutorizadoResponse item,
        string currencySymbol,
        string currencyName) => new()
    {
        Eyebrow = "CONTROL DE RECURSOS",
        Title = "Presupuesto autorizado",
        Subtitle = Text(item.Descripcion),
        RecordCode = $"AUT-{item.PkidEgresoAutorizado:000000}",
        Status = "AUTORIZADO",
        StatusTone = "success",
        HeroLabel = $"Monto autorizado · {currencyName}",
        HeroValue = Money(item.Total, currencySymbol),
        Sections = BudgetSections(item, currencySymbol)
    };

    public static CinematicRecordModel ForPresupuestoDisponible(
        EgresoDisponibleResponse item,
        string currencySymbol,
        string currencyName) => new()
    {
        Eyebrow = "DISPONIBILIDAD PRESUPUESTAL",
        Title = "Presupuesto disponible",
        Subtitle = Text(item.Descripcion),
        RecordCode = $"DSP-{item.PkidEgresoAutorizado:000000}",
        Status = "DISPONIBLE",
        StatusTone = "success",
        HeroLabel = $"Saldo disponible · {currencyName}",
        HeroValue = Money(item.Total, currencySymbol),
        Sections =
        [
            Section("01", "Posición presupuestal",
                Field("Programa", item.ProgramaClaveNombre ?? Join(item.ProgramaClave, item.ProgramaDescripcion), wide: true),
                Field("Partida", item.PartidaClaveNombre ?? Join(item.PartidaClave, item.PartidaDescripcion), wide: true),
                Field("Área", item.AreaNombre),
                Field("Ejercicio", item.AnioClave?.ToString(NumberCulture)),
                Field("Fecha", item.Fecha.ToString("dd/MM/yyyy", DateCulture))),
            Section("02", "Clasificación operativa",
                Field("Fuente de financiamiento", item.FuenteFinanciamientoClaveNombre ?? Join(item.FuenteFinanciamientoClave, item.FuenteFinanciamientoDescripcion), wide: true),
                Field("Tipo de gasto", item.TipoGastoClaveNombre ?? Join(item.TipoGastoClave?.ToString(NumberCulture), item.TipoGastoDescripcion)),
                Field("Dígito identificador", item.DigitoIdentificadorClaveNombre ?? Join(item.DigitoIdentificadorClave, item.DigitoIdentificadorDescripcion)),
                Field("Destino de gasto", item.DestinoGastoClaveNombre ?? Join(item.DestinoGastoClave, item.DestinoGastoDescripcion)),
                Field("Proyecto PY", item.PyClaveNombre ?? Join(item.PyClave, item.PyDescripcion))),
            Section("03", "Disponibilidad mensual",
                Month("Enero", item.Enero, currencySymbol), Month("Febrero", item.Febrero, currencySymbol), Month("Marzo", item.Marzo, currencySymbol),
                Month("Abril", item.Abril, currencySymbol), Month("Mayo", item.Mayo, currencySymbol), Month("Junio", item.Junio, currencySymbol),
                Month("Julio", item.Julio, currencySymbol), Month("Agosto", item.Agosto, currencySymbol), Month("Septiembre", item.Septiembre, currencySymbol),
                Month("Octubre", item.Octubre, currencySymbol), Month("Noviembre", item.Noviembre, currencySymbol), Month("Diciembre", item.Diciembre, currencySymbol))
        ]
    };

    public static CinematicRecordModel ForRequisicion(RequisicionResponse item, string currencySymbol = "$") => new()
    {
        Eyebrow = "REQUISICIÓN DE COMPRA",
        Title = "Requisición",
        Subtitle = Text(item.Descripcion),
        RecordCode = $"REQ-{item.PkidRequisicion:000000}",
        Status = item.BloqueadaPorCotizacion ? "EN COTIZACIÓN" : item.Activo ? "ACTIVA" : "INACTIVA",
        StatusTone = item.BloqueadaPorCotizacion ? "warning" : item.Activo ? "success" : "danger",
        HeroLabel = "Importe de la requisición",
        HeroValue = Money(item.Importe, currencySymbol),
        Sections =
        [
            Section("01", "Ficha de solicitud",
                Field("Empresa", item.EmpresaNombre, wide: true),
                Field("Área solicitante", Join(item.AreaClave, item.AreaNombre), wide: true),
                Field("Solicitante", item.SolicitanteCompleto, wide: true),
                Field("Fecha de requisición", item.FechaRequisicion.ToString("dd/MM/yyyy", DateCulture)),
                Field("Tipo", item.Servicio ? "Servicio" : "Bien"),
                Field("Compra directa", item.CompraDirecta.HasValue ? item.CompraDirecta.Value ? "Sí" : "No" : null)),
            Section("02", "Objetivo y vigencia",
                Field("Descripción", item.Descripcion, wide: true, emphasized: true),
                Field("Observaciones", item.Observaciones, wide: true),
                Field("Requiere desde", Date(item.FechaRequiereInicio)),
                Field("Requiere hasta", Date(item.FechaRequiereFin)),
                Field("Oficio", item.Oficio),
                Field("Fecha de oficio", Date(item.FechaOficio))),
            Section("03", "Clasificación presupuestal",
                Field("Programa", Join(item.ProgramaClave, item.ProgramaDescripcion), wide: true),
                Field("Fuente de financiamiento", Join(item.FuenteFinanciamientoClave, item.FuenteFinanciamientoDescripcion), wide: true),
                Field("Tipo de gasto", Join(item.TipoGastoClave?.ToString(NumberCulture), item.TipoGastoDescripcion)),
                Field("Dígito identificador", Join(item.DigitoIdentificadorClave, item.DigitoIdentificadorDescripcion)),
                Field("Destino de gasto", Join(item.DestinoGastoClave, item.DestinoGastoDescripcion))),
            Section("04", "Cadena de validación",
                Field("Jefe de almacén", item.JefeAlmacenCompleto),
                Field("Supervisó", item.SupervisoCompleto),
                Field("Autorizó", item.AutorizoCompleto),
                Field("Cotizaciones activas", item.CotizacionesActivas.ToString(NumberCulture), emphasized: item.CotizacionesActivas > 0))
        ]
    };

    public static CinematicRecordModel ForMatrizConversion(MatrizConversionResponse item) => new()
    {
        Eyebrow = "MATRIZ CONTABLE",
        Title = "Matriz de conversión",
        Subtitle = Join(item.ProgramaClave, item.PartidaDescripcion),
        RecordCode = $"MCV-{item.PkidMatrizConversion:000000}",
        Status = item.Activo ? "OPERATIVA" : "INACTIVA",
        StatusTone = item.Activo ? "success" : "danger",
        HeroLabel = "Regla de conversión",
        HeroValue = Text(item.ProgramaClave),
        Sections =
        [
            Section("01", "Clave de conversión",
                Field("Programa", item.ProgramaClave, emphasized: true),
                Field("Partida", item.PartidaDescripcion, wide: true),
                Field("Tipo de gasto", Join(item.TipoGastoClave.ToString(NumberCulture), item.TipoGastoDescripcion), wide: true)),
            Section("02", "Cuentas de aprobación",
                Field("Aprobado", item.CuentaAprobadoNombre, wide: true),
                Field("Por ejercer", item.CuentaPorEjercerNombre, wide: true),
                Field("Modificado", item.CuentaModificadoNombre, wide: true)),
            Section("03", "Cuentas de ejercicio",
                Field("Comprometido", item.CuentaComprometidoNombre, wide: true),
                Field("Devengado", item.CuentaDevengadoNombre, wide: true),
                Field("Ejercido", item.CuentaEjercidoNombre, wide: true),
                Field("Pagado", item.CuentaPagadoNombre, wide: true),
                Field("Gasto", item.CuentaGastoNombre, wide: true))
        ]
    };

    public static CinematicRecordModel ForMatrizIngreso(MatrizIngresoResponse item) => new()
    {
        Eyebrow = "MATRIZ CONTABLE",
        Title = "Matriz de conversión de ingresos",
        Subtitle = Join(item.ProgramaClave, item.ProgramaDescripcion),
        RecordCode = $"MCI-{item.PkidMatrizIngreso:000000}",
        Status = item.Activo ? "OPERATIVA" : "INACTIVA",
        StatusTone = item.Activo ? "success" : "danger",
        HeroLabel = "Programa de ingreso",
        HeroValue = Text(item.ProgramaClave),
        Sections =
        [
            Section("01", "Identidad de la regla",
                Field("Programa", Join(item.ProgramaClave, item.ProgramaDescripcion), wide: true, emphasized: true),
                Field("Origen de recursos", item.OrigenDescripcion, wide: true)),
            Section("02", "Cuentas presupuestales",
                Field("Presupuesto autorizado", item.CuentaAutorizadoNombre, wide: true),
                Field("Por ejecutar", item.CuentaPorEjecutarNombre, wide: true),
                Field("Modificado", item.CuentaModificadoNombre, wide: true),
                Field("Devengado", item.CuentaDevengadoNombre, wide: true),
                Field("Recaudado", item.CuentaRecaudadoNombre, wide: true),
                Field("Depósito", item.CuentaDepositoNombre, wide: true))
        ]
    };

    public static CinematicRecordModel ForSolicitudSuficiencia(SolicitudSuficienciaResponse item, string currencySymbol = "$") => new()
    {
        Eyebrow = "VALIDACIÓN PRESUPUESTAL",
        Title = "Solicitud de suficiencia",
        Subtitle = Text(item.RequisicionDescripcion),
        RecordCode = $"SUF-{item.PkidSolicitudSuficiencia:000000}",
        Status = Text(item.EstatusDescripcion),
        StatusTone = item.Estatus >= 3 ? "success" : item.Activo ? "warning" : "danger",
        HeroLabel = "Importe solicitado",
        HeroValue = Money(item.RequisicionImporte, currencySymbol),
        Sections =
        [
            Section("01", "Solicitud y origen",
                Field("Empresa", item.EmpresaNombre, wide: true),
                Field("Requisición", item.RequisicionDescripcion, wide: true, emphasized: true),
                Field("Fecha de requisición", Date(item.FechaRequisicion)),
                Field("Fecha de solicitud", item.FechaSolicitud.ToString("dd/MM/yyyy", DateCulture)),
                Field("Estatus", item.EstatusDescripcion)),
            Section("02", "Justificación",
                Field("Justificación", item.Justificacion, wide: true),
                Field("Gasto no programable", item.GastoNoProgramable, wide: true),
                Field("Compromiso de nómina", item.IdCompromisoNomina?.ToString(NumberCulture))),
            Section("03", "Trazabilidad",
                Field("Creación", DateTimeText(item.FechaCreacion)),
                Field("Última modificación", DateTimeText(item.FechaModificacion)),
                Field("Estado del registro", item.Activo ? "Activo" : "Inactivo"))
        ]
    };

    public static CinematicRecordModel ForAutorizacionSuficiencia(AutorizacionSuficienciaResponse item) => new()
    {
        Eyebrow = "AUTORIZACIÓN DE RECURSOS",
        Title = "Autorización de suficiencia",
        Subtitle = Text(item.RequisicionDescripcion),
        RecordCode = $"AUS-{item.PkidAutorizacionSuficiencia:000000}",
        Status = Text(item.EstatusDescripcion),
        StatusTone = item.Estatus >= 3 ? "success" : item.Activo ? "warning" : "danger",
        HeroLabel = "Responsable de autorización",
        HeroValue = Text(item.AutorizadoPorNombre),
        Sections =
        [
            Section("01", "Resolución presupuestal",
                Field("Empresa", item.EmpresaNombre, wide: true),
                Field("Requisición", item.RequisicionDescripcion, wide: true, emphasized: true),
                Field("Solicitud de suficiencia", item.FkidSolicitudSuficienciaPres.ToString(NumberCulture)),
                Field("Fecha de solicitud", item.FechaSolicitud.ToString("dd/MM/yyyy", DateCulture)),
                Field("Fecha de autorización", item.FechaAutorizacion.ToString("dd/MM/yyyy", DateCulture))),
            Section("02", "Dictamen",
                Field("Justificación", item.Justificacion, wide: true),
                Field("Observaciones", item.Observaciones, wide: true),
                Field("Gasto no programable", item.GastoNoProgramable),
                Field("Estatus", item.EstatusDescripcion)),
            Section("03", "Trazabilidad",
                Field("Autorizó", item.AutorizadoPorNombre, wide: true),
                Field("Creación", DateTimeText(item.FechaCreacion)),
                Field("Última modificación", DateTimeText(item.FechaModificacion)))
        ]
    };

    public static CinematicRecordModel ForCotizacion(CotizacionResponse item, string currencySymbol = "$") => new()
    {
        Eyebrow = "COTIZACIÓN DE PROVEEDOR",
        Title = "Cotización de proveedor",
        Subtitle = Text(item.RequisicionDescripcion),
        RecordCode = $"COT-{item.PkidCotizacion:000000}",
        Status = item.Activo ? "ACTIVA" : "INACTIVA",
        StatusTone = item.Activo ? "success" : "danger",
        HeroLabel = "Total cotizado",
        HeroValue = Money(item.TotalCotizado, currencySymbol),
        Sections =
        [
            Section("01", "Proveedor y solicitud",
                Field("Proveedor", Join(item.ProveedorClave, item.ProveedorNombre), wide: true, emphasized: true),
                Field("RFC", item.ProveedorRfc),
                Field("Requisición", item.RequisicionDescripcion, wide: true),
                Field("Tipo", item.Servicio ? "Servicio" : "Bien"),
                Field("Bienes cotizados", item.TotalDetalles.ToString(NumberCulture))),
            Section("02", "Calendario de respuesta",
                Field("Fecha de solicitud", item.FechaSolicitud.ToString("dd/MM/yyyy", DateCulture)),
                Field("Fecha de cotización", Date(item.FechaProveedorCotiza)),
                Field("Compromiso del proveedor", Date(item.FechaProveedorCompromiso)),
                Field("Entrega", item.Entrega),
                Field("Vigencia", item.Vigencia)),
            Section("03", "Condiciones",
                Field("Condiciones", item.Condiciones, wide: true),
                Field("Comentarios", item.Comentarios, wide: true),
                Field("Documento", item.FlDocumento))
        ]
    };

    public static CinematicRecordModel ForOrdenCompra(OrdenCompraResponse item) => new()
    {
        Eyebrow = "ORDEN DE COMPRA",
        Title = "Orden de compra",
        Subtitle = Text(item.Descripcion),
        RecordCode = Text(item.NumeroOrdenCompra) == "—" ? $"OC-{item.PkidOrdenCompra:000000}" : item.NumeroOrdenCompra,
        Status = Text(item.EstatusDescripcion),
        StatusTone = item.EstaAutorizada ? "success" : item.Activo ? "warning" : "danger",
        HeroLabel = $"Total de la orden · {Text(item.MonedaNombre)}",
        HeroValue = Money(item.Total, Text(item.MonedaSimbolo) == "—" ? "$" : item.MonedaSimbolo),
        Sections =
        [
            Section("01", "Orden y proveedor",
                Field("Empresa", item.EmpresaNombre, wide: true),
                Field("Proveedor", Join(item.ProveedorClave, item.ProveedorNombre), wide: true, emphasized: true),
                Field("RFC", item.ProveedorRfc),
                Field("Requisición", item.RequisicionDescripcion, wide: true),
                Field("Compra directa", item.CompraDirecta ? "Sí" : "No")),
            Section("02", "Importes y control",
                Field("Subtotal", Money(item.Subtotal, item.MonedaSimbolo)),
                Field("IVA", Money(item.Iva, item.MonedaSimbolo)),
                Field("Total", Money(item.Total, item.MonedaSimbolo), emphasized: true),
                Field("Moneda", item.MonedaNombre),
                Field("Tipo de cambio", item.TipoCambio?.ToString("N4", NumberCulture)),
                Field("Póliza", Join(item.ClavePoliza, item.FkidPolizaConta?.ToString(NumberCulture)))),
            Section("03", "Calendario de cumplimiento",
                Field("Fecha de orden", item.FechaOrdenCompra.ToString("dd/MM/yyyy", DateCulture)),
                Field("Fecha requerida", Date(item.FechaRequerida)),
                Field("Fecha de entrega", Date(item.FechaEntrega)),
                Field("Vigencia", Date(item.FechaVigencia)),
                Field("Detalles", item.TotalDetalles.ToString(NumberCulture)),
                Field("Partidas", item.TotalPartidas.ToString(NumberCulture))),
            Section("04", "Observaciones",
                Field("Descripción", item.Descripcion, wide: true),
                Field("Observaciones", item.Observaciones, wide: true),
                Field("Motivo de cancelación", item.MotivoCancelacion, wide: true))
        ]
    };

    private static IReadOnlyList<CinematicRecordSection> BudgetSections(EgresoAutorizadoResponse item, string currencySymbol) =>
    [
        Section("01", "Identidad presupuestal",
            Field("Programa", item.ProgramaClaveNombre ?? Join(item.ProgramaClave, item.ProgramaDescripcion), wide: true),
            Field("Partida", item.PartidaClaveNombre ?? Join(item.PartidaClave, item.PartidaDescripcion), wide: true),
            Field("Área", item.AreaNombre),
            Field("Ejercicio", item.AnioClave?.ToString(NumberCulture)),
            Field("Fecha", item.Fecha.ToString("dd/MM/yyyy", DateCulture)),
            Field("Origen", item.FkidEgresoProyectadoPres.HasValue ? $"Anteproyecto {item.FkidEgresoProyectadoPres}" : "Registro directo")),
        Section("02", "Clasificación operativa",
            Field("Fuente de financiamiento", item.FuenteFinanciamientoClaveNombre ?? Join(item.FuenteFinanciamientoClave, item.FuenteFinanciamientoDescripcion), wide: true),
            Field("Tipo de gasto", item.TipoGastoClaveNombre ?? Join(item.TipoGastoClave?.ToString(NumberCulture), item.TipoGastoDescripcion)),
            Field("Dígito identificador", item.DigitoIdentificadorClaveNombre ?? Join(item.DigitoIdentificadorClave, item.DigitoIdentificadorDescripcion)),
            Field("Destino de gasto", item.DestinoGastoClaveNombre ?? Join(item.DestinoGastoClave, item.DestinoGastoDescripcion)),
            Field("Proyecto PY", item.PyClaveNombre ?? Join(item.PyClave, item.PyDescripcion)),
            Field("Póliza", item.FkidPolizaConta?.ToString(NumberCulture))),
        Section("03", "Distribución autorizada",
            Month("Enero", item.Enero, currencySymbol), Month("Febrero", item.Febrero, currencySymbol), Month("Marzo", item.Marzo, currencySymbol),
            Month("Abril", item.Abril, currencySymbol), Month("Mayo", item.Mayo, currencySymbol), Month("Junio", item.Junio, currencySymbol),
            Month("Julio", item.Julio, currencySymbol), Month("Agosto", item.Agosto, currencySymbol), Month("Septiembre", item.Septiembre, currencySymbol),
            Month("Octubre", item.Octubre, currencySymbol), Month("Noviembre", item.Noviembre, currencySymbol), Month("Diciembre", item.Diciembre, currencySymbol))
    ];

    private static CinematicRecordSection Section(string code, string title, params CinematicRecordField[] fields) => new()
    {
        Code = code,
        Title = title,
        Fields = fields
    };

    private static CinematicRecordField Field(string label, string? value, bool wide = false, bool emphasized = false) => new()
    {
        Label = label,
        Value = Text(value),
        Wide = wide,
        Emphasized = emphasized
    };

    private static CinematicRecordField Month(string label, decimal? value, string currencySymbol) =>
        Field(label, Money(value, currencySymbol), emphasized: value.GetValueOrDefault() > 0m);

    private static string Text(string? value) => string.IsNullOrWhiteSpace(value) ? "—" : value.Trim();

    private static string Join(string? code, string? description)
    {
        var left = Text(code);
        var right = Text(description);
        return left == "—" ? right : right == "—" ? left : $"{left} · {right}";
    }

    private static string Money(decimal? value, string currencySymbol) =>
        $"{currencySymbol}{value.GetValueOrDefault().ToString("N2", NumberCulture)}";

    private static string Date(DateTime? value) =>
        value?.ToString("dd/MM/yyyy", DateCulture) ?? "—";

    private static string DateTimeText(DateTime? value) =>
        value?.ToString("dd/MM/yyyy HH:mm", DateCulture) ?? "—";
}
