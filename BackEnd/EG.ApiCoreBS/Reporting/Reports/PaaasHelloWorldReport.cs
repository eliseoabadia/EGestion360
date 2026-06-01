using DevExpress.Drawing;
using DevExpress.Drawing.Printing;
using DevExpress.XtraPrinting;
using DevExpress.XtraReports.UI;
using System.Drawing;

namespace EG.ApiCoreBS.Reporting.Reports;

public sealed class PaaasHelloWorldReport : XtraReport
{
    public PaaasHelloWorldReport(ReportRequest request)
    {
        Name = nameof(PaaasHelloWorldReport);
        DisplayName = "Hola mundo PAAAS";
        PaperKind = DXPaperKind.Letter;
        Margins = new DXMargins(40, 40, 40, 40);

        var detail = new DetailBand
        {
            HeightF = 260
        };

        detail.Controls.AddRange(new XRControl[]
        {
            new XRLabel
            {
                Text = "Hola mundo desde DevExpress Reporting",
                BoundsF = new RectangleF(0, 20, 730, 40),
                Font = new DXFont("Arial", 18, DXFontStyle.Bold),
                ForeColor = Color.FromArgb(22, 91, 170),
                TextAlignment = TextAlignment.MiddleCenter
            },
            new XRLabel
            {
                Text = $"Reporte: {ReportKeys.PaaasHelloWorld}",
                BoundsF = new RectangleF(0, 85, 730, 26),
                Font = new DXFont("Arial", 10),
                TextAlignment = TextAlignment.MiddleCenter
            },
            new XRLabel
            {
                Text = $"PK recibido: {request.PrimaryKey?.ToString() ?? "sin pk"}",
                BoundsF = new RectangleF(0, 120, 730, 30),
                Font = new DXFont("Arial", 12, DXFontStyle.Bold),
                TextAlignment = TextAlignment.MiddleCenter
            },
            new XRLabel
            {
                Text = "Este ejemplo prueba el flujo generico: boton en tabla, visor DevExpress/DevExtreme y proveedor de reportes por nombre.",
                BoundsF = new RectangleF(60, 170, 610, 55),
                Font = new DXFont("Arial", 10),
                TextAlignment = TextAlignment.TopCenter,
                Multiline = true
            }
        });

        Bands.AddRange(new Band[]
        {
            new TopMarginBand(),
            detail,
            new BottomMarginBand()
        });
    }
}
