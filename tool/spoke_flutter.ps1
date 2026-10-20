[CmdletBinding()]
param(
    [ValidateSet('run', 'build')]
    [string]$Action = 'run',
    [string]$DeviceId
)

$ErrorActionPreference = 'Stop'
$projectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$googleMapsConfigPath = Join-Path $projectRoot 'google_maps.local.json'

if ($Action -eq 'build' -and -not [string]::IsNullOrWhiteSpace($DeviceId)) {
    throw '-DeviceId se usa únicamente con -Action run.'
}

$googleMapsApiKeyConfigured = $false
if (Test-Path -LiteralPath $googleMapsConfigPath) {
    $googleMapsConfig = Get-Content -LiteralPath $googleMapsConfigPath -Raw | ConvertFrom-Json
    $googleMapsApiKeyConfigured = -not [string]::IsNullOrWhiteSpace(
        [string]$googleMapsConfig.GOOGLE_MAPS_API_KEY
    )
}

$flutterArguments = @()
if ($Action -eq 'run') {
    $flutterArguments += 'run'
} else {
    $flutterArguments += @('build', 'apk', '--debug')
}

if ($googleMapsApiKeyConfigured) {
    $flutterArguments += '--dart-define=GOOGLE_MAPS_API_KEY_CONFIGURED=true'
}

if (-not [string]::IsNullOrWhiteSpace($DeviceId)) {
    $flutterArguments += @('-d', $DeviceId)
}

$flutterExitCode = 0
Push-Location $projectRoot
try {
    & flutter @flutterArguments
    $flutterExitCode = $LASTEXITCODE
} finally {
    Pop-Location
}

exit $flutterExitCode
