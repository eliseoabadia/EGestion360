param(
    [string]$Server = 'DESKTOP-B2UQJB2',
    [string]$Database = 'GestionEmpresarial',
    [string]$User = 'sa',
    [string]$Password = 'Sitio2010',
    [string]$OutputPath = 'C:\tmp\EGestion360_ReportSP_Audit.csv'
)

Add-Type -AssemblyName System.Data

function Get-ParameterValue {
    param(
        [string]$Name,
        [string]$TypeName
    )

    if ($TypeName -in @('date', 'datetime', 'datetime2', 'smalldatetime')) {
        if ($Name -match 'fin|final') {
            return [datetime]'2026-06-25'
        }

        return [datetime]'2026-01-01'
    }

    if ($TypeName -eq 'bit') {
        return $false
    }

    if ($TypeName -match 'int|decimal|numeric|money|float|real') {
        if ($Name -match 'empresa') {
            return 6
        }

        if ($Name -match 'empleado|usuario') {
            return 1
        }

        if ($Name -match 'nivel') {
            return 10
        }

        if ($Name -match 'mes|solo|cierre') {
            return 0
        }

        if ($Name -match 'cuenta') {
            return 0
        }

        return 1
    }

    return ''
}

$connectionString = "Server=$Server;Database=$Database;User Id=$User;Password=$Password;TrustServerCertificate=True"
$connection = [System.Data.SqlClient.SqlConnection]::new($connectionString)
$connection.Open()

try {
    $listCommand = $connection.CreateCommand()
    $listCommand.CommandText = @"
SELECT
    SCHEMA_NAME(p.schema_id) AS schema_name,
    p.name AS proc_name
FROM sys.procedures p
WHERE
    (p.name LIKE 'SPR[_]%' OR p.name LIKE 'SP[_]Reporte%' OR p.name LIKE '%Reporte%')
    AND SCHEMA_NAME(p.schema_id) IN ('CONTA','ALMA','SICOP','ORCO','PRES')
ORDER BY schema_name, proc_name;
"@

    $reader = $listCommand.ExecuteReader()
    $procedures = @()
    while ($reader.Read()) {
        $procedures += [pscustomobject]@{
            Schema = $reader.GetString(0)
            Name = $reader.GetString(1)
        }
    }
    $reader.Close()

    $results = @()

    foreach ($procedure in $procedures) {
        $procedureName = "[$($procedure.Schema)].[$($procedure.Name)]"
        $command = $connection.CreateCommand()
        $command.CommandType = [System.Data.CommandType]::StoredProcedure
        $command.CommandTimeout = 30
        $command.CommandText = $procedureName

        $parameterCommand = $connection.CreateCommand()
        $parameterCommand.CommandText = @"
SELECT
    prm.name,
    TYPE_NAME(prm.user_type_id) AS type_name
FROM sys.parameters prm
WHERE prm.object_id = OBJECT_ID(@objectName)
ORDER BY prm.parameter_id;
"@
        $parameter = $parameterCommand.Parameters.Add('@objectName', [System.Data.SqlDbType]::NVarChar, 300)
        $parameter.Value = $procedureName

        $parameterReader = $parameterCommand.ExecuteReader()
        while ($parameterReader.Read()) {
            $parameterName = $parameterReader.GetString(0)
            $typeName = $parameterReader.GetString(1).ToLowerInvariant()
            $sqlParameter = [System.Data.SqlClient.SqlParameter]::new($parameterName, (Get-ParameterValue $parameterName $typeName))
            $command.Parameters.Add($sqlParameter) | Out-Null
        }
        $parameterReader.Close()

        try {
            $reportReader = $command.ExecuteReader()
            $resultSetCount = 0
            $columns = @()

            do {
                if ($reportReader.FieldCount -gt 0) {
                    $resultSetCount++
                    $names = @()
                    for ($i = 0; $i -lt $reportReader.FieldCount; $i++) {
                        $names += $reportReader.GetName($i)
                    }
                    $columns += ($names -join '|')
                }

                while ($reportReader.Read()) {
                }
            } while ($reportReader.NextResult())

            $reportReader.Close()

            $results += [pscustomobject]@{
                Procedure = $procedureName
                ResultSets = $resultSetCount
                Columns = $columns -join ' || '
                Error = ''
            }
        }
        catch {
            $results += [pscustomobject]@{
                Procedure = $procedureName
                ResultSets = -1
                Columns = ''
                Error = $_.Exception.Message
            }
        }
    }

    $results | Export-Csv -NoTypeInformation -Encoding UTF8 -LiteralPath $OutputPath
    $results |
        Sort-Object @{ Expression = 'ResultSets'; Descending = $true }, Procedure |
        Format-Table -AutoSize Procedure, ResultSets, Error
    Write-Host "CSV=$OutputPath"
}
finally {
    $connection.Close()
}
