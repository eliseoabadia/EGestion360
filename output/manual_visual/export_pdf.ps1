$ErrorActionPreference = 'Stop'
$docx = (Resolve-Path -LiteralPath 'output\manual_visual\Manual_visual_presupuesto_a_orden_compra.docx').Path
$pdf = Join-Path (Split-Path -Parent $docx) 'Manual_visual_presupuesto_a_orden_compra.pdf'
$word = New-Object -ComObject Word.Application
$word.Visible = $false
$word.DisplayAlerts = 0
$word.AutomationSecurity = 3
try {
    $document = $word.Documents.Open($docx, $false, $true, $false)
    try {
        $document.SaveAs2($pdf, 17)
    }
    finally {
        $document.Close($false)
    }
}
finally {
    $word.Quit()
    [System.Runtime.InteropServices.Marshal]::ReleaseComObject($word) | Out-Null
}
Write-Output $pdf
