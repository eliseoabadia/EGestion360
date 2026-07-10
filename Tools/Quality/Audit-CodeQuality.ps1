[CmdletBinding()]
param(
    [switch]$FailOnViolations
)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$violations = [System.Collections.Generic.List[object]]::new()

function Invoke-Ripgrep {
    param([string[]]$Arguments)

    $output = & rg @Arguments 2>$null
    if ($LASTEXITCODE -gt 1) {
        throw "rg fallo con codigo ${LASTEXITCODE}: $($Arguments -join ' ')"
    }

    return @($output)
}

function Add-Violations {
    param(
        [string]$Rule,
        [string[]]$Matches
    )

    foreach ($match in $Matches) {
        $violations.Add([pscustomobject]@{
            Rule = $Rule
            Match = $match
        })
    }
}

Push-Location $repoRoot
try {
    $emptyCatches = Invoke-Ripgrep @(
        '-n', '-U',
        '--glob', '*.cs',
        '--glob', '*.razor',
        'catch\s*(\([^)]*\))?\s*\{\s*\}',
        'FrontEnd', 'BackEnd'
    )
    Add-Violations 'EG001 catch vacio' $emptyCatches

    $rawSnackbarErrors = Invoke-Ripgrep @(
        '-n',
        '--glob', '*.razor',
        '--glob', '*.cs',
        '(Snackbar|MudSnackbar)\.Add\([^\r\n]*(ex|exception)\.Message',
        'FrontEnd'
    )
    Add-Violations 'EG002 excepcion tecnica enviada a Snackbar' $rawSnackbarErrors

    $rawResponseErrors = Invoke-Ripgrep @(
        '-n',
        '--glob', '*.razor',
        '--glob', '*.cs',
        'Message\s*=\s*\$?[^;\r\n]*(ex|exception)\.Message|return\s+[^;\r\n]*(ex|exception)\.Message',
        'FrontEnd'
    )
    $rawResponseErrors = @($rawResponseErrors | Where-Object {
        $_ -notmatch 'Helpers[\\/]UserFacingExceptionMessages\.cs'
    })
    Add-Violations 'EG003 excepcion tecnica asignada a una respuesta visual' $rawResponseErrors

    $grpRoot = (Resolve-Path 'FrontEnd\EG.Web\Pages\Modules\GRP').Path
    Get-ChildItem -LiteralPath $grpRoot -Recurse -Filter '*.razor' | ForEach-Object {
        $relative = $_.FullName.Substring($grpRoot.Length + 1)
        $area = ($relative -split '[\\/]')[0]
        $routes = Select-String -LiteralPath $_.FullName -Pattern '^@page\s+"([^"]+)"' |
            ForEach-Object { $_.Matches[0].Groups[1].Value }

        if ($routes.Count -eq 0) {
            return
        }

        $areaPatterns = switch ($area) {
            'Adquisiciones' { @('Adquisicion', 'Adquisiciones', 'Contratos') }
            'Configuration' { @('configuracion') }
            default { @($area) }
        }

        $aligned = $false
        foreach ($route in $routes) {
            foreach ($pattern in $areaPatterns) {
                if ($route -match ('(?i)/' + [regex]::Escape($pattern) + '(?:/|$)')) {
                    $aligned = $true
                    break
                }
            }

            if ($aligned) {
                break
            }
        }

        if (-not $aligned) {
            $violations.Add([pscustomobject]@{
                Rule = 'EG004 carpeta funcional no coincide con sus rutas'
                Match = "$relative => $($routes -join ' | ')"
            })
        }
    }

    $filterRegistration = Select-String `
        -LiteralPath 'BackEnd\EG.ApiCoreBS\Program.cs' `
        -Pattern 'ApiResultSanitizationFilter' `
        -Quiet
    if (-not $filterRegistration) {
        $violations.Add([pscustomobject]@{
            Rule = 'EG005 sanitizacion global de API no registrada'
            Match = 'BackEnd\EG.ApiCoreBS\Program.cs'
        })
    }

    Write-Host "Auditoria EGestion360"
    Write-Host "  Catch vacios:                 $($emptyCatches.Count)"
    Write-Host "  Snackbar con ex.Message:      $($rawSnackbarErrors.Count)"
    Write-Host "  Respuestas visuales tecnicas: $($rawResponseErrors.Count)"
    Write-Host "  Violaciones totales:          $($violations.Count)"

    if ($violations.Count -gt 0) {
        Write-Host ''
        $violations | Format-Table -AutoSize | Out-Host
    }

    if ($FailOnViolations -and $violations.Count -gt 0) {
        exit 1
    }
}
finally {
    Pop-Location
}
