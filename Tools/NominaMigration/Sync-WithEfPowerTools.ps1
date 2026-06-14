$ErrorActionPreference = 'Stop'

$root = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$modelsPath = Join-Path $root 'BackEnd\EG.Infraestructure\Models'

$catalogs = @(
    @{ Prefix = 'NomConcepto'; Entity = 'Concepto1'; Label = 'Concepto' },
    @{ Prefix = 'NomConceptoFactor'; Entity = 'ConceptoFactor'; Label = 'Factor de concepto' },
    @{ Prefix = 'NomConceptoFijo'; Entity = 'ConceptoFijo'; Label = 'Concepto fijo' },
    @{ Prefix = 'NomConceptoPorcentaje'; Entity = 'ConceptoPorcentaje'; Label = 'Concepto porcentaje' },
    @{ Prefix = 'NomConceptoProporcional'; Entity = 'ConceptoProporcional'; Label = 'Concepto proporcional' },
    @{ Prefix = 'NomConceptoTabular'; Entity = 'ConceptoTabular'; Label = 'Concepto tabular' },
    @{ Prefix = 'NomConceptoVariable'; Entity = 'ConceptoVariable'; Label = 'Concepto variable' },
    @{ Prefix = 'NomContratoTerceros'; Entity = 'ContratoTercero'; Label = 'Contrato de terceros' },
    @{ Prefix = 'NomCredito'; Entity = 'Credito'; Label = 'Credito' },
    @{ Prefix = 'NomDescuentoCredito'; Entity = 'DescuentoCredito'; Label = 'Descuento credito' },
    @{ Prefix = 'NomDescuentoInfonavit'; Entity = 'DescuentoInfonavit'; Label = 'Descuento Infonavit' },
    @{ Prefix = 'NomEstatusPago'; Entity = 'EstatusPago'; Label = 'Estatus de pago' },
    @{ Prefix = 'NomFactorInt'; Entity = 'FactorInt'; Label = 'Factor de integracion' },
    @{ Prefix = 'NomInfonavit'; Entity = 'Infonavit'; Label = 'Infonavit' },
    @{ Prefix = 'NomPeriodoActivo'; Entity = 'PeriodoActivo'; Label = 'Periodo activo' },
    @{ Prefix = 'NomSalarioMinimo'; Entity = 'SalarioMinimo'; Label = 'Salario minimo' },
    @{ Prefix = 'NomSueldoEspecial'; Entity = 'SueldoEspecial'; Label = 'Sueldo especial' },
    @{ Prefix = 'NomSueldoLiqFin'; Entity = 'SueldoLiqFin'; Label = 'Sueldo liquidacion finiquito' },
    @{ Prefix = 'NomSueldoMensual'; Entity = 'SueldoMensual'; Label = 'Sueldo mensual' },
    @{ Prefix = 'NomSueldoQuincenal'; Entity = 'SueldoQuincenal'; Label = 'Sueldo quincenal' },
    @{ Prefix = 'NomSueldoSemanal'; Entity = 'SueldoSemanal'; Label = 'Sueldo semanal' },
    @{ Prefix = 'NomTipoIncapacidad'; Entity = 'TipoIncapacidad'; Label = 'Tipo de incapacidad' },
    @{ Prefix = 'NomTipoPago'; Entity = 'TipoPago'; Label = 'Tipo de pago nomina' },
    @{ Prefix = 'NomTipoPension'; Entity = 'TipoPension'; Label = 'Tipo de pension' }
)

function Write-Utf8File {
    param(
        [string]$RelativePath,
        [string]$Content
    )

    $fullPath = Join-Path $root $RelativePath
    $directory = Split-Path $fullPath -Parent
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
    [System.IO.File]::WriteAllText($fullPath, ($Content -replace "`n", "`r`n"), [System.Text.UTF8Encoding]::new($false))
}

function Get-EntityProperties {
    param([string]$EntityName)

    $file = Join-Path $modelsPath "$EntityName.cs"
    if (-not (Test-Path $file)) {
        throw "No existe el modelo EF generado: $file"
    }

    $properties = New-Object System.Collections.Generic.List[object]
    foreach ($line in Get-Content -LiteralPath $file) {
        $trim = $line.Trim()
        if ($trim -match '^public\s+(?!virtual)(?<type>[A-Za-z0-9_<>?]+)\s+(?<name>[A-Za-z0-9_]+)\s+\{\s+get;\s+set;\s+\}$') {
            $properties.Add([pscustomobject]@{
                Type = $Matches['type']
                Name = $Matches['name']
            })
        }
    }

    return @($properties.ToArray())
}

function Get-PkName {
    param([array]$Properties)

    $pk = $Properties | Where-Object { $_.Name -like 'Pkid*' } | Select-Object -First 1
    if ($null -eq $pk) {
        throw 'No se encontro propiedad PK.'
    }

    return $pk.Name
}

function Get-ClaveNombreExpression {
    param([array]$Properties)

    $names = @($Properties | ForEach-Object { $_.Name })
    if ($names -contains 'Clave' -and $names -contains 'Descripcion') {
        return 'ClaveNombre => $"{Clave} - {Descripcion}".Trim('' '', ''-'');'
    }

    if ($names -contains 'Clave' -and $names -contains 'Nombre') {
        return 'ClaveNombre => $"{Clave} - {Nombre}".Trim('' '', ''-'');'
    }

    foreach ($candidate in @('Descripcion', 'Nombre', 'NombreContrato', 'MotivoCredito', 'MotivoInfonavit', 'Referencia')) {
        if ($names -contains $candidate) {
            return "ClaveNombre => $candidate ?? string.Empty;"
        }
    }

    $pk = Get-PkName $Properties
    return "ClaveNombre => $pk.ToString();"
}

function Get-PropertyLines {
    param(
        [array]$Properties,
        [bool]$IsResponse
    )

    $lines = New-Object System.Collections.Generic.List[string]
    foreach ($property in $Properties) {
        if ($property.Type -eq 'string') {
            $lines.Add("        public string $($property.Name) { get; set; } = string.Empty;")
        }
        else {
            $lines.Add("        public $($property.Type) $($property.Name) { get; set; }")
        }

        if ($IsResponse -and $property.Name -like 'Pkid*') {
            $alias = $property.Name -replace '^Pkid', 'PkidNom'
            if ($alias -ne $property.Name) {
                $lines.Add(@"
        public int $alias
        {
            get => $($property.Name);
            set => $($property.Name) = value;
        }
"@)
            }
        }
    }

    if ($IsResponse) {
        $lines.Add("        public string $(Get-ClaveNombreExpression $Properties)")
    }

    return $lines -join "`n`n"
}

$resolved = foreach ($catalog in $catalogs) {
    $properties = Get-EntityProperties $catalog.Entity
    [pscustomobject]@{
        Prefix = $catalog.Prefix
        Entity = $catalog.Entity
        Label = $catalog.Label
        Dto = "$($catalog.Prefix)Dto"
        Response = "$($catalog.Prefix)Response"
        Service = "$($catalog.Prefix)AppService"
        Properties = $properties
        Pk = Get-PkName $properties
    }
}

$dtoClasses = foreach ($catalog in $resolved) {
@"
    public class $($catalog.Dto)
    {
$(Get-PropertyLines $catalog.Properties $false)
    }
"@
}

Write-Utf8File 'BackEnd\EG.Domain\Modules\Nomina\DTOs\Requests\Catalogos\NominaCatalogosDto.cs' @"
using System;

namespace EG.Domain.DTOs.Requests.Nomina
{
$($dtoClasses -join "`n`n")
}
"@

$responseClasses = foreach ($catalog in $resolved) {
@"
    public class $($catalog.Response)
    {
$(Get-PropertyLines $catalog.Properties $true)
    }
"@
}

Write-Utf8File 'BackEnd\EG.Domain\Modules\Nomina\DTOs\Responses\Catalogos\NominaCatalogosResponse.cs' @"
using System;

namespace EG.Domain.DTOs.Responses.Nomina
{
$($responseClasses -join "`n`n")
}
"@

$mappingLines = foreach ($catalog in $resolved) {
@"
            config.NewConfig<$($catalog.Entity), $($catalog.Dto)>().TwoWays();
            config.NewConfig<$($catalog.Entity), $($catalog.Response)>().TwoWays();
            config.NewConfig<$($catalog.Response), $($catalog.Dto)>().TwoWays();
"@
}

Write-Utf8File 'BackEnd\EG.Business\Mapping\Nomina\NominaCatalogosMappingProfile.cs' @"
using Mapster;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;

namespace EG.Business.Mapping.Nomina
{
    public class NominaCatalogosMappingProfile : IRegister
    {
        public void Register(TypeAdapterConfig config)
        {
$($mappingLines -join "`n`n")
        }
    }
}
"@

$serviceClasses = foreach ($catalog in $resolved) {
@"
    public class $($catalog.Service) : NominaCrudAppService<$($catalog.Entity), $($catalog.Dto), $($catalog.Response)>
    {
        public $($catalog.Service)(GenericService<$($catalog.Entity), $($catalog.Dto), $($catalog.Response)> service)
            : base(service, "$($catalog.Pk)", "$($catalog.Label)", (dto, id) => dto.$($catalog.Pk) = id)
        {
        }
    }
"@
}

Write-Utf8File 'BackEnd\EG.Application\Modules\Nomina\Services\Catalogos\NominaCatalogServices.cs' @"
using EG.Business.Services;
using EG.Domain.DTOs.Requests.Nomina;
using EG.Domain.DTOs.Responses.Nomina;
using EG.Infraestructure.Models;

namespace EG.Application.Services.Nomina
{
$($serviceClasses -join "`n`n")
}
"@

Write-Host "Synced Nomina DTOs, mappings, and services to EF Power Tools models."
