using EG.Common;

namespace EG.ApiCoreBS.Reporting;

public sealed class StoredProcedureReportRegistry
{
    private readonly Dictionary<string, StoredProcedureReportDefinition> _reports;

    public StoredProcedureReportRegistry()
    {
        _reports = new(StringComparer.OrdinalIgnoreCase)
        {
            [ReportKeys.Poliza] = new StoredProcedureReportDefinition(
                ReportKeys.Poliza,
                "Reporte de poliza",
                "CONTA.SP_ReportePoliza",
                [
                    new StoredProcedureReportParameter("@PKIdPoliza", "PKIdPoliza", typeof(int), "pk", 0)
                ],
                [
                    new StoredProcedureReportField("ClavePoliza", "Clave", 75),
                    new StoredProcedureReportField("FechaPoliza", "Fecha", 75),
                    new StoredProcedureReportField("NombrePoliza", "Poliza", 180),
                    new StoredProcedureReportField("Descripcion", "Tipo", 90),
                    new StoredProcedureReportField("ClaveOrd", "Cuenta", 130),
                    new StoredProcedureReportField("DDetalle", "Detalle", 180),
                    new StoredProcedureReportField("ImporteDebe", "Debe", 80),
                    new StoredProcedureReportField("ImporteHaber", "Haber", 80)
                ],
                Constants.BD_CON),
            [ReportKeys.PaaasStoredProcedure] = new StoredProcedureReportDefinition(
                ReportKeys.PaaasStoredProcedure,
                "Reporte PAAAS por Stored Procedure",
                "[ORCO].[SP_ReportePAAAS]",
                [
                    new StoredProcedureReportParameter("@PKIdPAAAS", "PKIdPAAAS", typeof(int), "pk", 0)
                ],
                [
                    new StoredProcedureReportField("PKIdPAAAS", "PAAAS", 55),
                    new StoredProcedureReportField("AnioClave", "Anio", 60),
                    new StoredProcedureReportField("AreaNombre", "Area", 135),
                    new StoredProcedureReportField("Descripcion", "Descripcion", 190),
                    new StoredProcedureReportField("PartidaClave", "Partida", 70),
                    new StoredProcedureReportField("PartidaDescripcion", "Partida descripcion", 160),
                    new StoredProcedureReportField("TipoBienDescripcion", "Bien", 180),
                    new StoredProcedureReportField("Cantidad", "Cantidad", 70)
                ],
                Constants.BD_CON)
        };
    }

    public IEnumerable<StoredProcedureReportDefinition> Reports => _reports.Values;

    public bool TryGet(string reportName, out StoredProcedureReportDefinition definition) =>
        _reports.TryGetValue(reportName, out definition!);
}
