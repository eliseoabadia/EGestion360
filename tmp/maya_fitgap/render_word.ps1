$ErrorActionPreference = 'Stop'
$taskRoot = 'C:\Desarrollo\Desarrollo\FullStack\EGestion360'
$taskWord = New-Object -ComObject Word.Application
$taskWord.Visible = $false
$taskWord.DisplayAlerts = 0
try {
    foreach ($taskName in @('01_Requerimientos_ERP_Universidad_Maya_Sin_RH', '02_FIT_GAP_EGestion360_Universidad_Maya_Sin_RH')) {
        $taskDocPath = Join-Path $taskRoot ('output\documentos\universidad-maya\' + $taskName + '.docx')
        $taskPdfPath = Join-Path $taskRoot ('tmp\maya_fitgap\' + $taskName + '.pdf')
        $taskDoc = $taskWord.Documents.Open($taskDocPath, $false, $true)
        try {
            $taskDoc.Repaginate()
            $taskDoc.ExportAsFixedFormat($taskPdfPath, 17)
            Write-Output ($taskName + ': ' + $taskDoc.ComputeStatistics(2) + ' pages')
        } finally {
            $taskDoc.Close(0)
            [void][Runtime.InteropServices.Marshal]::ReleaseComObject($taskDoc)
        }
    }
} finally {
    $taskWord.Quit()
    [void][Runtime.InteropServices.Marshal]::ReleaseComObject($taskWord)
}
