[CmdletBinding()]
param(
    [string]$TaskPrefix = 'LibreBooking'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Test-IsAdministrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($identity)
    return $principal.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}

if (-not (Test-IsAdministrator)) {
    throw '管理者権限で PowerShell を実行してください。'
}

$taskNames = @(
    "$TaskPrefix-autorelease",
    "$TaskPrefix-sendreminders",
    "$TaskPrefix-sendmissedcheckin",
    "$TaskPrefix-sendwaitlist",
    "$TaskPrefix-sendseriesend",
    "$TaskPrefix-sessioncleanup",
    "$TaskPrefix-deleteolddata"
)

foreach ($taskName in $taskNames) {
    Write-Host "[INFO] タスク削除: $taskName"
    & schtasks.exe /Delete /TN $taskName /F | Out-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "削除対象が見つからないか、削除に失敗しました: $taskName"
    }
}

Write-Host '[OK] タスク削除処理が完了しました。'
