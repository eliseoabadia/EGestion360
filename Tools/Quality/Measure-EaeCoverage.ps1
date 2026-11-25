[CmdletBinding()]
param([switch]$AsJson)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$viewsRoot = Join-Path $repoRoot 'FrontEnd\EG.Web\Pages'
$views = @(Get-ChildItem -LiteralPath $viewsRoot -Recurse -File -Filter '*.razor' | ForEach-Object {
    $source = [IO.File]::ReadAllText($_.FullName)
    [pscustomobject]@{
        Path = $_.FullName.Substring($repoRoot.Length + 1).Replace('\', '/')
        UsesSharedEditor = $source -match '<BaseCrudDialog\b|<BaseEntityForm\b'
        UsesSharedGrid = $source -match '<GenericDataGrid\b|<GenericTable\b'
        UsesMudDialog = $source -match '<MudDialog\b'
        HasInlineCode = $source -match '@code\s*\{'
        # A syntactic hint: dynamic, conditional and repeated fields require manual review.
        StaticFieldTags = [regex]::Matches($source, '<Mud(?:TextField|NumericField|Select|DatePicker|TimePicker|CheckBox|Switch)\b').Count
        HasSemanticSections = $source -match 'crud-form-section|eae-form-section|<CrudFormSection\b|<FormSection\b|<MudTabs\b|<MudExpansionPanels\b'
    }
})

$controllerRoot = Join-Path $repoRoot 'BackEnd\EG.ApiCoreBS\Controllers'
$directContextControllers = @(Get-ChildItem -LiteralPath $controllerRoot -Recurse -File -Filter '*.cs' |
    Where-Object { [IO.File]::ReadAllText($_.FullName) -match '\bEGestionContext\b' } |
    ForEach-Object { $_.FullName.Substring($repoRoot.Length + 1).Replace('\', '/') })

$report = [pscustomobject]@{
    Scope = 'Inventario sintáctico del código fuente; no certifica UI, seguridad ni comportamiento de cada pantalla.'
    RazorViews = $views.Count
    ViewsUsingSharedEditors = @($views | Where-Object UsesSharedEditor).Count
    ViewsUsingSharedGrids = @($views | Where-Object UsesSharedGrid).Count
    ViewsWithInlineCode = @($views | Where-Object HasInlineCode).Count
    DirectContextControllerCount = $directContextControllers.Count
    DirectContextControllersToReview = $directContextControllers
    DirectGenericServiceControllerCount = @(Get-ChildItem -LiteralPath $controllerRoot -Recurse -File -Filter '*.cs' |
        Where-Object { [IO.File]::ReadAllText($_.FullName) -match '\bGenericService\s*<' }).Count
    Views = $views
}

if ($AsJson) {
    $report | ConvertTo-Json -Depth 5
}
else {
    $report | Select-Object Scope, RazorViews, ViewsUsingSharedEditors, ViewsUsingSharedGrids,
        ViewsWithInlineCode, DirectContextControllerCount, DirectGenericServiceControllerCount
}
