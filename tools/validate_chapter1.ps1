param([switch]$Visual)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$gameRoot = Join-Path $projectRoot 'game'
$localRoot = Join-Path $PSScriptRoot 'local'
$profileRoot = Join-Path $localRoot 'profile'

New-Item -ItemType Directory -Force -Path $localRoot, $profileRoot | Out-Null

if ($env:CHRONUS_GODOT) {
    $godotExe = (Resolve-Path -LiteralPath $env:CHRONUS_GODOT).Path
} else {
    $portableExe = Join-Path $localRoot 'Godot_v4.5.1-stable_win64_console.exe'
    if (Test-Path -LiteralPath $portableExe) {
        $godotExe = $portableExe
    } else {
        $command = Get-Command godot, godot4 -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $command) {
            throw 'Godot 4.5.1+ não encontrada. Instale-a ou defina CHRONUS_GODOT para o executável.'
        }
        $godotExe = $command.Source
    }
}

$oldAppData = $env:APPDATA
$oldLocalAppData = $env:LOCALAPPDATA
try {
    $env:APPDATA = $profileRoot
    $env:LOCALAPPDATA = Join-Path $profileRoot 'Local'
    New-Item -ItemType Directory -Force -Path $env:LOCALAPPDATA | Out-Null

    $editorLog = Join-Path $localRoot 'chapter1-editor.log'
    & $godotExe --headless --editor --path $gameRoot --log-file $editorLog --quit
    if ($LASTEXITCODE -ne 0) { throw 'Falha na importação/editor Godot.' }

    foreach ($name in @('chapter_smoke', 'chapter_flow', 'chapter_traversal', 'menu_smoke', 'progression_smoke', 'save_io')) {
        $logPath = Join-Path $localRoot "$name.log"
        $scriptPath = "res://tests/$name.gd"
        if ($name -eq 'save_io') {
            & $godotExe --headless --path $gameRoot --log-file $logPath --script $scriptPath
        } else {
            & $godotExe --headless --path $gameRoot --log-file $logPath --script $scriptPath -- --test
        }
        if ($LASTEXITCODE -ne 0) { throw "Falha no teste $name." }
    }

    if ($Visual) {
        $visualLog = Join-Path $localRoot 'chapter1-visual.log'
        & $godotExe --path $gameRoot --log-file $visualLog --script res://tests/visual_capture.gd -- --test
        if ($LASTEXITCODE -ne 0) { throw 'Falha na captura visual.' }
    }

    Write-Output 'Validação automatizada do Capítulo I concluída.'
} finally {
    $env:APPDATA = $oldAppData
    $env:LOCALAPPDATA = $oldLocalAppData
}
