param(
    [Parameter(Mandatory)][string]$Source,
    [Parameter(Mandatory)][string]$Contract
)

$ErrorActionPreference = 'Stop'
$root = (Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$sourcePath = (Resolve-Path (Join-Path $root $Source)).Path
$contractPath = (Resolve-Path (Join-Path $root $Contract)).Path
$applicationRoot = Join-Path $root 'BackEnd\EG.Application\'
if (!$sourcePath.StartsWith($applicationRoot) -or !$contractPath.StartsWith($applicationRoot)) {
    throw 'Sólo se admiten archivos de Application revisados explícitamente.'
}
$implementation = [IO.File]::ReadAllText($sourcePath)
$contractText = [IO.File]::ReadAllText($contractPath)
if ([regex]::Matches($contractText, '\binterface\s+').Count -ne 1) {
    throw 'El archivo contiene varios contratos; requiere separación explícita de la familia.'
}
$class = [regex]::Match($implementation, 'public (?:sealed )?class\s+(\w+)(?:\([^{}]*\))?\s*:\s*(?:(?<base>(?:AdquisicionCrudAppService|StoredProcedureCrudAppService)<[^{}]+?>)\s*,\s*)?(I\w+)\s*\{')
if (!$class.Success) { throw 'La clase requiere revisión de herencia o constructores.' }
$className = $class.Groups[1].Value
$interfaceName = $class.Groups[2].Value
$interface = [regex]::Match($contractText, "interface\s+$interfaceName\s*(?::\s*IAdquisicionCrudAppService<(?<response>\w+)>)?\s*\{")
if (!$interface.Success) { throw 'Contrato no compatible: revisar herencia antes de moverlo.' }
$sourceNamespace = [regex]::Match($implementation, 'namespace\s+([\w.]+)').Groups[1].Value
$contractNamespace = [regex]::Match($contractText, 'namespace\s+([\w.]+)').Groups[1].Value
$applicationImports = @([regex]::Matches($implementation, '(?m)^using EG.Application[^;]+;'))
if ($applicationImports.Count -ne 1 -or $applicationImports[0].Value -ne "using $contractNamespace;") {
    throw 'La implementación tiene otras dependencias de Application que requieren extracción previa.'
}
$feature = $className -replace '(AppService|Service)$', ''
$businessClass = "${feature}OperationsService"
$businessInterface = "I${feature}Operations"
$businessNamespace = $sourceNamespace.Replace('EG.Application.', 'EG.Business.').Replace('EG.ApiCoreBS.Services.', 'EG.Business.Services.')
$folder = $businessNamespace.Replace('EG.Business.Services.', '').Replace('.', '\')
$target = Join-Path $root "BackEnd\EG.Business\Services\$folder\$businessClass.cs"
$targetContract = Join-Path $root "BackEnd\EG.Business\Interfaces\$businessInterface.cs"
if ((Test-Path -LiteralPath $target) -or (Test-Path -LiteralPath $targetContract)) {
    throw 'Destino existente: no se sobrescribe código.'
}
$declarations = [Collections.Generic.List[string]]::new()
$imports = [Collections.Generic.HashSet[string]]::new()
$null = $imports.Add('using EG.Common.GenericModel;')
foreach ($item in [regex]::Matches($contractText, '(?m)^using [^;]+;')) {
    if ($item.Value -notmatch '^using EG.Application') { $null = $imports.Add($item.Value) }
}
if ($interface.Groups['response'].Success) {
    $baseContract = [IO.File]::ReadAllText((Join-Path $root 'BackEnd\EG.Application\Modules\GRP\Interfaces\Adquisicion\IAdquisicionCrudAppService.cs'))
    foreach ($item in [regex]::Matches($baseContract, '(?m)^\s*(Task(?:<[^;]+>)?\s+\w+\([^;]*\));')) {
        $declarations.Add($item.Groups[1].Value.Trim().Replace('TResponse', $interface.Groups['response'].Value))
    }
}
foreach ($item in [regex]::Matches($contractText, '(?m)^\s*(Task(?:<[^;]+>)?\s+\w+\([^;]*\));')) {
    $declarations.Add($item.Groups[1].Value.Trim())
}
if ($declarations.Count -eq 0) { throw 'El contrato no contiene operaciones Task reconocibles.' }
$businessContract = @($imports) + @('', 'namespace EG.Business.Interfaces;', '', "public interface $businessInterface", '{')
$facade = @($imports) + @("using $contractNamespace;", 'using EG.Business.Interfaces;', '', "namespace $sourceNamespace;", '', "public sealed class $className($businessInterface service) : $interfaceName", '{')
foreach ($declaration in $declarations) {
    $method = [regex]::Match($declaration, '^(?<return>Task(?:<.+>)?)\s+(?<name>\w+)\((?<parameters>.*)\)$', 'Singleline')
    if (!$method.Success) { throw 'Declaración no compatible.' }
    $parameters = $method.Groups['parameters'].Value -replace '\s+', ' '
    $parameterParts = [Collections.Generic.List[string]]::new()
    $depth = 0
    $partStart = 0
    for ($index = 0; $index -lt $parameters.Length; $index++) {
        if ($parameters[$index] -in @('<', '(')) { $depth++ }
        if ($parameters[$index] -in @('>', ')')) { $depth-- }
        if ($parameters[$index] -eq ',' -and $depth -eq 0) {
            $parameterParts.Add($parameters.Substring($partStart, $index - $partStart))
            $partStart = $index + 1
        }
    }
    $parameterParts.Add($parameters.Substring($partStart))
    if ($depth -ne 0 -or $parameters -match '\b(ref|out)\b') { throw 'Parámetro requiere revisión explícita.' }
    $arguments = @($parameterParts | Where-Object { $_ -match '\S' } | ForEach-Object {
        (($_ -split '=')[0].Trim() -split '\s+')[-1]
    }) -join ', '
    $businessContract += "    $declaration;"
    $facade += "    public $($method.Groups['return'].Value) $($method.Groups['name'].Value)($parameters) => service.$($method.Groups['name'].Value)($arguments);"
}
$businessContract += '}'
$facade += '}'
$registrationPath = Join-Path $root 'BackEnd\EG.ApiCoreBS\Extensions\ServiceCollectionExtensions.cs'
$registrations = [IO.File]::ReadAllText($registrationPath)
$existing = "services.AddScoped<$interfaceName, $className>();"
if (!$registrations.Contains($existing)) { throw 'No existe un registro simple del servicio; revisar composición.' }
$registrations = $registrations.Replace($existing,
    "services.AddScoped<EG.Business.Interfaces.$businessInterface, $businessNamespace.$businessClass>();`r`n            $existing")
$business = $implementation.Replace("using $contractNamespace;", 'using EG.Business.Interfaces;').Replace($sourceNamespace, $businessNamespace)
$business = $business.Replace('AdquisicionCrudAppService<', 'AdquisicionCrudOperationsService<').Replace('StoredProcedureCrudAppService<', 'StoredProcedureCrudOperationsService<')
if ($class.Groups['base'].Success -and !$business.Contains('using EG.Business.Services.Adquisicion;')) {
    $business = "using EG.Business.Services.Adquisicion;`r`n" + $business.TrimStart([char]0xFEFF)
}
$business = [regex]::Replace($business, "\b$interfaceName\b", $businessInterface)
$business = [regex]::Replace($business, "\b$className\b", $businessClass)
# Todas las comprobaciones preceden a las modificaciones. No se crean respaldos.
$businessRoot = (Resolve-Path (Join-Path $root 'BackEnd\EG.Business')).Path
if (!$target.StartsWith($businessRoot + '\')) { throw 'Destino fuera de Business.' }
New-Item -ItemType Directory -Path (Split-Path $target) -Force | Out-Null
Move-Item -LiteralPath $sourcePath -Destination $target
[IO.File]::WriteAllText($target, $business, [Text.UTF8Encoding]::new($true))
[IO.File]::WriteAllLines($targetContract, $businessContract, [Text.UTF8Encoding]::new($true))
[IO.File]::WriteAllLines($sourcePath, $facade, [Text.UTF8Encoding]::new($true))
[IO.File]::WriteAllText($registrationPath, $registrations, [Text.UTF8Encoding]::new($true))
Write-Output "$className -> $businessClass ($($declarations.Count) operaciones)"
