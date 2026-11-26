[CmdletBinding()]
param([ValidatePattern('^[A-Za-z0-9_-]+\.sql$')][string]$OutputName = '20261125_Consistencia_Procedimientos.sql')

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$output = Join-Path (Join-Path $repoRoot 'Scripts') $OutputName
if (Test-Path -LiteralPath $output) {
    throw 'El incremental ya existe. Utiliza otro OutputName para conservar el historial de cambios aplicado.'
}
$connection = [System.Data.SqlClient.SqlConnection]::new('Data Source=.;Initial Catalog=GestionEmpresarial;Integrated Security=True;TrustServerCertificate=True;Application Name=EGestion360-DbPreparation;Connect Timeout=5')

# Tokeniza literales, identificadores y comentarios para no cambiar texto de
# negocio ni NOLOCK escrito dentro de comentarios/cadenas. Solo retira el hint
# individual WITH (NOLOCK) y la sintaxis heredada alias (NOLOCK).
$lexer = [regex]::new("(?s)'(?:''|[^'])*'|\[(?:\]\]|[^\]])*\]|`"(?:`"`"|[^`"])*`"|--[^\r\n]*|/\*.*?\*/|\s+|[A-Za-z_][A-Za-z_0-9]*|.")
$sql = [System.Text.StringBuilder]::new()
[void]$sql.AppendLine("-- Generado a partir de los modulos actuales; no contiene copias de datos.")
[void]$sql.AppendLine("SET NOCOUNT ON; SET XACT_ABORT ON; SET LOCK_TIMEOUT 5000;")
[void]$sql.AppendLine("IF DB_NAME() <> N'GestionEmpresarial' THROW 51200, 'Destino incorrecto.', 1;")
[void]$sql.AppendLine("IF (SELECT is_read_committed_snapshot_on FROM sys.databases WHERE database_id=DB_ID())<>1 THROW 51201, 'Se requiere RCSI activo.', 1;")
[void]$sql.AppendLine('BEGIN TRY')
[void]$sql.AppendLine('BEGIN TRANSACTION;')
$summary = [System.Collections.Generic.List[object]]::new()
try {
    $connection.Open()
    $command = $connection.CreateCommand()
    $command.CommandText = @'
SELECT o.object_id, QUOTENAME(s.name)+'.'+QUOTENAME(o.name) AS QualifiedName,
 m.definition,m.uses_ansi_nulls,m.uses_quoted_identifier,
 CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),m.definition)),2) AS DefinitionHash,
 CASE WHEN EXISTS(SELECT 1 FROM sys.crypt_properties cp WHERE cp.major_id=o.object_id) THEN 1 ELSE 0 END AS SignedModule
FROM sys.sql_modules m JOIN sys.objects o ON o.object_id=m.object_id JOIN sys.schemas s ON s.schema_id=o.schema_id
WHERE o.is_ms_shipped=0 AND o.type IN('P','V') AND
 (m.definition LIKE '%NOLOCK%' OR m.definition LIKE '%READUNCOMMITTED%' OR m.definition LIKE '%READ UNCOMMITTED%' OR
 o.name IN('spDocumentoGuardar','spDocumentoAnotacionCrear','spDocumentoAnotacionEliminar','spDocumentoEliminar','sp_NotificacionCrear','spEliminarUsuarioSucursal','SP_CargaInicialConteo'))
ORDER BY s.name,o.name;
'@
    $reader = $command.ExecuteReader()
    while ($reader.Read()) {
        $id = $reader.GetInt32(0)
        $name = $reader.GetString(1)
        $definition = $reader.GetString(2)
        $originalHash = $reader.GetString(5)
        $tokens = @($lexer.Matches($definition) | Where-Object { $_.Value -notmatch '^\s+$|^--|^/\*' })
        $edits = [System.Collections.Generic.List[object]]::new()
        $hints = 0
        $isolation = 0
        for ($i=0; $i -lt $tokens.Count-3; $i++) {
            if ($tokens[$i].Value -ieq 'WITH' -and $tokens[$i+1].Value -eq '(' -and
                $tokens[$i+2].Value -iin @('NOLOCK','READUNCOMMITTED') -and $tokens[$i+3].Value -eq ')') {
                $edits.Add(@{ Offset=$tokens[$i].Index; Length=$tokens[$i+3].Index+$tokens[$i+3].Length-$tokens[$i].Index; Value='' })
                $hints++
            }
        }
        for ($i=1; $i -lt $tokens.Count-2; $i++) {
            if ($tokens[$i].Value -eq '(' -and $tokens[$i+1].Value -iin @('NOLOCK','READUNCOMMITTED') -and
                $tokens[$i+2].Value -eq ')' -and $tokens[$i-1].Value -ine 'WITH' -and
                $tokens[$i-1].Value -match '^(\[.*\]|[A-Za-z_][A-Za-z_0-9]*)$') {
                $edits.Add(@{Offset=$tokens[$i].Index;Length=$tokens[$i+2].Index+1-$tokens[$i].Index;Value=''})
                $hints++
            }
        }
        for ($i=0; $i -lt $tokens.Count-5; $i++) {
            if (($tokens[$i..($i+5)].Value -join ' ') -ieq 'SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED') {
                $edits.Add(@{Offset=$tokens[$i+5].Index;Length=$tokens[$i+5].Length;Value='COMMITTED'})
                $isolation++
            }
        }
        $transactionNames = @('[SIS].[spDocumentoGuardar]','[SIS].[spDocumentoAnotacionCrear]',
            '[SIS].[spDocumentoAnotacionEliminar]','[SIS].[spDocumentoEliminar]',
            '[SIS].[sp_NotificacionCrear]','[SIS].[spEliminarUsuarioSucursal]','[ALMA].[SP_CargaInicialConteo]')
        $addAbort = $name -in $transactionNames -and $definition -notmatch '(?i)SET\s+XACT_ABORT\s+ON'
        if ($addAbort) {
            $countStatements = @([regex]::Matches($definition,'(?im)^\s*SET\s+NOCOUNT\s+ON\s*;'))
            if ($countStatements.Count -ne 1) { throw "NOCOUNT ambiguo: $name" }
            $hit = $countStatements[0]
            $edits.Add(@{Offset=$hit.Index+$hit.Length;Length=0;Value="`r`n    SET XACT_ABORT ON;"})
        }
        if ($name -eq '[SIS].[spEliminarUsuarioSucursal]' -and $definition -notmatch 'EG20261125') {
            $returns = @($tokens | Where-Object { $_.Value -ieq 'RETURN' })
            if ($returns.Count -ne 1) { throw 'RETURN de spEliminarUsuarioSucursal no coincide con el revisado.' }
            $edits.Add(@{Offset=$returns[0].Index;Length=0;Value="COMMIT TRANSACTION; -- EG20261125: cierra la transaccion propia sin asignacion.`r`n            "})
        }
        if ($edits.Count -eq 0) { continue }
        if ($reader.GetInt32(6) -ne 0) { throw "Modulo firmado requiere preservar firma: $name" }
        foreach ($edit in ($edits | Sort-Object Offset -Descending)) {
            $definition=$definition.Remove($edit.Offset,$edit.Length).Insert($edit.Offset,$edit.Value)
        }
        # Conserva el cuerpo exacto, salvo las ediciones seleccionadas y CREATE -> ALTER.
        $first = $tokens[0]
        if ($first.Value -ieq 'CREATE') {
            $definition=$definition.Remove($first.Index,$first.Length).Insert($first.Index,'ALTER')
            if ($tokens[1].Value -ieq 'OR') { throw "CREATE OR ALTER requiere revision adicional: $name" }
        } elseif ($first.Value -ine 'ALTER') { throw "Cabecera no soportada: $name" }
        $quoted = $definition.Replace("'", "''")
        [void]$sql.AppendLine("-- $name : hints retirados=$hints; XACT_ABORT=$addAbort")
        [void]$sql.AppendLine("IF CONVERT(varchar(64),HASHBYTES('SHA2_256',CONVERT(varbinary(max),OBJECT_DEFINITION($id))),2) <> '$originalHash' OR OBJECT_DEFINITION($id) IS NULL THROW 51202, 'El modulo cambio desde la preparacion.', 1;")
        [void]$sql.AppendLine("SET ANSI_NULLS $(if($reader.GetBoolean(3)){'ON'}else{'OFF'}); SET QUOTED_IDENTIFIER $(if($reader.GetBoolean(4)){'ON'}else{'OFF'});")
        [void]$sql.AppendLine("EXEC sys.sp_executesql N'$quoted';")
        $summary.Add([pscustomobject]@{Module=$name;HintsRemoved=$hints;ReadCommitted=$isolation;XactAbortAdded=$addAbort})
    }
    $reader.Close()
    [void]$sql.AppendLine('COMMIT TRANSACTION;')
    [void]$sql.AppendLine('END TRY BEGIN CATCH IF XACT_STATE()<>0 ROLLBACK TRANSACTION; THROW; END CATCH;')
    [System.IO.File]::WriteAllText($output,$sql.ToString(),[System.Text.UTF8Encoding]::new($false))
    $summary | ConvertTo-Json -Compress
} finally { $connection.Dispose() }
