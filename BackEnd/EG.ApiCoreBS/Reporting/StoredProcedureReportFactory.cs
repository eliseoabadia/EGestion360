using DevExpress.DataAccess;
using DevExpress.DataAccess.Sql;
using DevExpress.Drawing;
using DevExpress.Drawing.Printing;
using DevExpress.XtraPrinting;
using DevExpress.XtraReports.Parameters;
using DevExpress.XtraReports.UI;
using System.Drawing;

namespace EG.ApiCoreBS.Reporting;

public sealed class StoredProcedureReportFactory
{
    private const float ReportWidth = 980;

    public XtraReport Create(StoredProcedureReportDefinition definition, ReportRequest request)
    {
        var report = new XtraReport
        {
            Name = SanitizeReportName(definition.ReportName),
            DisplayName = definition.DisplayName,
            PaperKind = DXPaperKind.Letter,
            Landscape = true,
            Margins = new DXMargins(40, 40, 40, 40),
            DataMember = definition.QueryName,
            RequestParameters = false
        };

        ConfigureParameters(report, definition, request);
        var dataSource = CreateDataSource(definition);
        report.DataSource = dataSource;
        report.ComponentStorage.Add(dataSource);

        BuildDefaultLayout(report, definition);
        return report;
    }

    private static void ConfigureParameters(
        XtraReport report,
        StoredProcedureReportDefinition definition,
        ReportRequest request)
    {
        foreach (var parameterDefinition in definition.Parameters)
        {
            var parameter = new Parameter
            {
                Name = parameterDefinition.ReportParameterName,
                Type = parameterDefinition.Type,
                Value = ResolveParameterValue(parameterDefinition, request),
                Visible = false
            };

            report.Parameters.Add(parameter);
        }
    }

    private static SqlDataSource CreateDataSource(StoredProcedureReportDefinition definition)
    {
        var dataSource = new SqlDataSource(definition.ConnectionName)
        {
            Name = $"{SanitizeReportName(definition.ReportName)}DataSource"
        };

        var query = new StoredProcQuery(definition.QueryName, definition.StoredProcedureName);
        foreach (var parameter in definition.Parameters)
        {
            query.Parameters.Add(new QueryParameter(
                parameter.StoredProcedureParameterName,
                typeof(Expression),
                new Expression($"?{parameter.ReportParameterName}", parameter.Type)));
        }

        dataSource.Queries.Add(query);
        return dataSource;
    }

    private static object? ResolveParameterValue(
        StoredProcedureReportParameter parameterDefinition,
        ReportRequest request)
    {
        var rawValue = request.GetValue(parameterDefinition.RequestParameterName) ??
                       request.GetValue(parameterDefinition.ReportParameterName);

        if (string.IsNullOrWhiteSpace(rawValue))
        {
            return parameterDefinition.DefaultValue;
        }

        var targetType = Nullable.GetUnderlyingType(parameterDefinition.Type) ?? parameterDefinition.Type;
        return Convert.ChangeType(rawValue, targetType);
    }

    private static void BuildDefaultLayout(XtraReport report, StoredProcedureReportDefinition definition)
    {
        var title = new ReportHeaderBand { HeightF = 86 };
        title.Controls.AddRange(new XRControl[]
        {
            new XRLabel
            {
                Text = definition.DisplayName,
                BoundsF = new RectangleF(0, 8, ReportWidth, 30),
                Font = new DXFont("Arial", 18, DXFontStyle.Bold),
                ForeColor = Color.FromArgb(22, 91, 170),
                TextAlignment = TextAlignment.MiddleLeft
            },
            new XRLabel
            {
                Text = $"Origen: {definition.StoredProcedureName}",
                BoundsF = new RectangleF(0, 44, ReportWidth, 22),
                Font = new DXFont("Arial", 9),
                ForeColor = Color.FromArgb(90, 90, 90),
                TextAlignment = TextAlignment.MiddleLeft
            }
        });

        var header = new PageHeaderBand { HeightF = 30 };
        header.Controls.Add(CreateHeaderTable(definition));

        var detail = new DetailBand { HeightF = 26 };
        detail.Controls.Add(CreateDetailTable(definition));

        var footer = new PageFooterBand { HeightF = 30 };
        footer.Controls.Add(CreatePageInfo());

        report.Bands.AddRange(new Band[]
        {
            new TopMarginBand(),
            title,
            header,
            detail,
            footer,
            new BottomMarginBand()
        });
    }

    private static XRTable CreateHeaderTable(StoredProcedureReportDefinition definition)
    {
        var table = CreateTable();
        var row = new XRTableRow();

        foreach (var field in definition.Fields)
        {
            row.Cells.Add(new XRTableCell
            {
                Text = field.Caption,
                WidthF = field.Width,
                Font = new DXFont("Arial", 8, DXFontStyle.Bold),
                BackColor = Color.FromArgb(232, 238, 246),
                TextAlignment = TextAlignment.MiddleLeft,
                Padding = new PaddingInfo(4, 4, 0, 0)
            });
        }

        table.Rows.Add(row);
        return table;
    }

    private static XRTable CreateDetailTable(StoredProcedureReportDefinition definition)
    {
        var table = CreateTable();
        var row = new XRTableRow();

        foreach (var field in definition.Fields)
        {
            var cell = new XRTableCell
            {
                WidthF = field.Width,
                Font = new DXFont("Arial", 8),
                TextAlignment = TextAlignment.MiddleLeft,
                Padding = new PaddingInfo(4, 4, 0, 0)
            };
            cell.ExpressionBindings.Add(new ExpressionBinding("BeforePrint", "Text", $"[{field.FieldName}]"));
            row.Cells.Add(cell);
        }

        table.Rows.Add(row);
        return table;
    }

    private static XRTable CreateTable() =>
        new()
        {
            BoundsF = new RectangleF(0, 0, ReportWidth, 26),
            Borders = BorderSide.All,
            BorderColor = Color.FromArgb(202, 210, 220)
        };

    private static XRPageInfo CreatePageInfo() =>
        new()
        {
            BoundsF = new RectangleF(0, 0, ReportWidth, 24),
            Font = new DXFont("Arial", 8),
            PageInfo = PageInfo.NumberOfTotal,
            TextAlignment = TextAlignment.MiddleRight
        };

    private static string SanitizeReportName(string reportName) =>
        reportName.Replace(".", string.Empty, StringComparison.Ordinal)
            .Replace("-", string.Empty, StringComparison.Ordinal);
}
