param(
    [string]$BaseUrl = "http://localhost:5058",
    [string]$Endpoint = "/api/Navigate/ping",
    [int]$TotalRequests = 1000,
    [int]$Concurrency = 50,
    [int]$TimeoutSeconds = 10,
    [string]$Token = ""
)

$ErrorActionPreference = "Stop"

$project = Join-Path $PSScriptRoot "EgestionStressRunner\EgestionStressRunner.csproj"
$argsList = @(
    "run",
    "--project", $project,
    "--no-restore",
    "--",
    "--base-url", $BaseUrl,
    "--endpoint", $Endpoint,
    "--requests", $TotalRequests,
    "--concurrency", $Concurrency,
    "--timeout", $TimeoutSeconds
)

if (-not [string]::IsNullOrWhiteSpace($Token)) {
    $argsList += @("--token", $Token)
}

& dotnet @argsList
