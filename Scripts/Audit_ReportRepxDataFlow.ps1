param(
    [string]$Server = 'DESKTOP-B2UQJB2',
    [string]$Database = 'GestionEmpresarial',
    [string]$User = 'sa',
    [string]$Password = 'Sitio2010',
    [string]$ReportsPath = 'BackEnd\EG.ApiCoreBS\Reporting\ExportedXml',
    [string]$OutputPath = 'C:\tmp\EGestion360_ReportRepx_DataFlow.csv'
)

Add-Type -AssemblyName System.Data

function Get-AttributeValue {
    param(
        [string]$Text,
        [string]$Name
    )

    $match = [regex]::Match($Text, "$Name=""([^""]*)""")
    if ($match.Success) {
        return $match.Groups[1].Value
    }

    return ''
}

function Get-ProcedureObjectName {
    param([string]$ProcName)

    $clean = $ProcName.Trim().Replace('[', '').Replace(']', '')
    $parts = $clean.Split('.', [System.StringSplitOptions]::RemoveEmptyEntries)
    if ($parts.Count -ge 2) {
        return "[$($parts[0])].[$($parts[1])]"
    }

    return $ProcName
}

function Get-ParameterValue {
    param(
        [string]$Name,
        [string]$TypeName
    )

    $normalized = $Name.TrimStart('@').ToLowerInvariant()

    if ($TypeName -in @('date', 'datetime', 'datetime2', 'smalldatetime')) {
        if ($normalized -match 'fin|final') {
            return [datetime]'2026-06-26'
        }

        return [datetime]'2026-01-01'
    }

    if ($TypeName -match 'char|text') {
        if ($normalized -match 'fec|fecha|fin|inicio') {
            if ($normalized -match 'fin|final') {
                return '2026-06-26'
            }

            return '2026-01-01'
        }

        return ''
    }

    if ($TypeName -eq 'bit') {
        return $false
    }

    if ($TypeName -match 'int|decimal|numeric|money|float|real') {
        if ($normalized -match 'empresa') {
            return 6
        }

        if ($normalized -match 'empleado|usuario') {
            return 1
        }

        if ($normalized -match 'nivel') {
            return 10
        }

        if ($normalized -match 'mes|solo|cierre') {
            return 0
        }

        if ($normalized -match 'cuenta') {
            return 0
        }

        return 1
    }

    return ''
}

function Invoke-ProcedureAudit {
    param(
        [System.Data.SqlClient.SqlConnection]$Connection,
        [string]$ProcedureName
    )

    $objectName = Get-ProcedureObjectName $ProcedureName
    $command = $Connection.CreateCommand()
    $command.CommandType = [System.Data.CommandType]::StoredProcedure
    $command.CommandTimeout = 45
    $command.CommandText = $objectName

    $parameterCommand = $Connection.CreateCommand()
    $parameterCommand.CommandText = @"
SELECT
    prm.name,
    TYPE_NAME(prm.user_type_id) AS type_name
FROM sys.parameters prm
WHERE prm.object_id = OBJECT_ID(@objectName)
ORDER BY prm.parameter_id;
"@
    $objectParameter = $parameterCommand.Parameters.Add('@objectName', [System.Data.SqlDbType]::NVarChar, 300)
    $objectParameter.Value = $objectName

    $parameterReader = $parameterCommand.ExecuteReader()
    while ($parameterReader.Read()) {
        $parameterName = $parameterReader.GetString(0)
        $typeName = $parameterReader.GetString(1).ToLowerInvariant()
        $sqlParameter = [System.Data.SqlClient.SqlParameter]::new($parameterName, (Get-ParameterValue $parameterName $typeName))
        $command.Parameters.Add($sqlParameter) | Out-Null
    }
    $parameterReader.Close()

    $reader = $command.ExecuteReader()
    $resultSetCount = 0
    $rowCounts = @()
    $resultSetColumns = @()

    do {
        if ($reader.FieldCount -gt 0) {
            $resultSetCount++
            $columns = @()
            for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                $columns += $reader.GetName($i)
            }

            $rowCount = 0
            while ($reader.Read()) {
                $rowCount++
            }

            $resultSetColumns += ,$columns
            $rowCounts += $rowCount
        }
    } while ($reader.NextResult())

    $reader.Close()

    return [pscustomobject]@{
        Procedure = $objectName
        ResultSets = $resultSetCount
        FirstColumns = if ($resultSetColumns.Count -gt 0) { $resultSetColumns[0] } else { @() }
        RowCounts = $rowCounts
        Error = ''
    }
}

function Get-ReportInfo {
    param([System.IO.FileInfo]$File)

    $text = Get-Content -LiteralPath $File.FullName -Raw
    $rootMatch = [regex]::Match($text, '<XtraReportsLayoutSerializer[^>]*>')
    $root = if ($rootMatch.Success) { $rootMatch.Value } else { '' }

    $base64Match = [regex]::Match($text, 'ObjectType="DevExpress\.DataAccess\.Sql\.SqlDataSource[^"]*"[^>]*Base64="([^"]+)"')
    $queryName = ''
    $procName = ''

    if ($base64Match.Success) {
        $decoded = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($base64Match.Groups[1].Value))
        $queryMatch = [regex]::Match($decoded, '<Query[^>]*Name="([^"]+)"')
        $procMatch = [regex]::Match($decoded, '<ProcName>([^<]+)</ProcName>')

        if ($queryMatch.Success) {
            $queryName = $queryMatch.Groups[1].Value
        }

        if ($procMatch.Success) {
            $procName = $procMatch.Groups[1].Value
        }
    }

    $dataMembers = [regex]::Matches($text, 'DataMember="([^"]+)"') |
        ForEach-Object { $_.Groups[1].Value } |
        Sort-Object -Unique

    $legacyResultRefs = [regex]::Matches($text, '(\.|\[)Result\d+(\]|")') |
        ForEach-Object { $_.Value.Trim('"') } |
        Sort-Object -Unique

    $fieldNames = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
    foreach ($expressionMatch in [regex]::Matches($text, 'Expression="([^"]+)"')) {
        foreach ($fieldMatch in [regex]::Matches($expressionMatch.Groups[1].Value, '\[([^\]]+)\]')) {
            $field = $fieldMatch.Groups[1].Value
            if ([string]::IsNullOrWhiteSpace($field)) {
                continue
            }

            if ($field -eq $queryName -or $field -eq 'Parameters' -or $field -match '^Result\d+$' -or $field.Contains('.')) {
                continue
            }

            [void]$fieldNames.Add($field)
        }
    }

    return [pscustomobject]@{
        File = $File.Name
        Path = $File.FullName
        ReportName = Get-AttributeValue $root 'Name'
        RootDataMember = Get-AttributeValue $root 'DataMember'
        RequestParameters = Get-AttributeValue $root 'RequestParameters'
        QueryName = $queryName
        ProcedureName = $procName
        DataMembers = $dataMembers
        LegacyResultRefs = $legacyResultRefs
        Fields = @($fieldNames)
    }
}

$connectionString = "Server=$Server;Database=$Database;User Id=$User;Password=$Password;TrustServerCertificate=True"
$connection = [System.Data.SqlClient.SqlConnection]::new($connectionString)
$connection.Open()

try {
    $procedureCache = @{}
    $results = @()

    Get-ChildItem -LiteralPath $ReportsPath -Filter '*.repx' | Sort-Object Name | ForEach-Object {
        $report = Get-ReportInfo $_
        $audit = $null
        $missingFields = @()
        $status = 'Sin SP'
        $errorMessage = ''

        if (-not [string]::IsNullOrWhiteSpace($report.ProcedureName)) {
            $procedureObjectName = Get-ProcedureObjectName $report.ProcedureName
            if (-not $procedureCache.ContainsKey($procedureObjectName)) {
                try {
                    $procedureCache[$procedureObjectName] = Invoke-ProcedureAudit -Connection $connection -ProcedureName $report.ProcedureName
                }
                catch {
                    $procedureCache[$procedureObjectName] = [pscustomobject]@{
                        Procedure = $procedureObjectName
                        ResultSets = -1
                        FirstColumns = @()
                        RowCounts = @()
                        Error = $_.Exception.Message
                    }
                }
            }

            $audit = $procedureCache[$procedureObjectName]
            $columnSet = New-Object 'System.Collections.Generic.HashSet[string]' ([System.StringComparer]::OrdinalIgnoreCase)
            foreach ($column in $audit.FirstColumns) {
                [void]$columnSet.Add($column)
            }

            foreach ($field in $report.Fields) {
                if (-not $columnSet.Contains($field)) {
                    $missingFields += $field
                }
            }

            if ($audit.ResultSets -ne 1) {
                $status = 'Falla resultsets'
            }
            elseif ($report.LegacyResultRefs.Count -gt 0) {
                $status = 'Layout usa ResultN'
            }
            elseif ($missingFields.Count -gt 0) {
                $status = 'Campos faltantes'
            }
            elseif (-not [string]::Equals($report.RootDataMember, $report.QueryName, [System.StringComparison]::OrdinalIgnoreCase)) {
                $status = 'DataMember distinto'
            }
            else {
                $status = 'OK'
            }

            $errorMessage = $audit.Error
        }

        $results += [pscustomobject]@{
            ReportFile = $report.File
            ReportName = $report.ReportName
            Procedure = if ($audit -ne $null) { $audit.Procedure } else { '' }
            QueryName = $report.QueryName
            RootDataMember = $report.RootDataMember
            ResultSets = if ($audit -ne $null) { $audit.ResultSets } else { '' }
            RowCounts = if ($audit -ne $null) { $audit.RowCounts -join '|' } else { '' }
            RequestParameters = $report.RequestParameters
            LegacyResultRefs = $report.LegacyResultRefs -join '|'
            MissingFields = $missingFields -join '|'
            Status = $status
            Error = $errorMessage
        }
    }

    $results | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $OutputPath
    $results |
        Sort-Object Status, ReportFile |
        Format-Table -AutoSize ReportFile, Procedure, ResultSets, RowCounts, Status, MissingFields

    Write-Host "CSV=$OutputPath"
}
finally {
    $connection.Close()
}
