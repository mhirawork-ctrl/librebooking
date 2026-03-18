[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string[]]$CampusCidrs,
    [int[]]$Ports = @(80, 443, 8080),
    [string]$RuleGroup = 'LibreBooking'
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

if (-not $CampusCidrs -or $CampusCidrs.Count -eq 0) {
    throw '学内CIDRを1つ以上指定してください。'
}

$remoteAddressValue = ($CampusCidrs | Where-Object { $_ -and $_.Trim().Length -gt 0 }) -join ','
if (-not $remoteAddressValue) {
    throw '有効な学内CIDRが指定されていません。'
}

Write-Host "[INFO] 既存の $RuleGroup ルールを削除します。"
Get-NetFirewallRule -Group $RuleGroup -ErrorAction SilentlyContinue | Remove-NetFirewallRule

foreach ($port in $Ports) {
    $displayName = "$RuleGroup-Allow-TCP-$port-CampusOnly"
    Write-Host "[INFO] 受信許可ルールを作成: $displayName"
    New-NetFirewallRule `
        -DisplayName $displayName `
        -Group $RuleGroup `
        -Direction Inbound `
        -Action Allow `
        -Enabled True `
        -Profile Domain,Private `
        -Protocol TCP `
        -LocalPort $port `
        -RemoteAddress $remoteAddressValue `
        -Description "Allow LibreBooking TCP $port only from campus CIDRs." | Out-Null
}

Write-Host ''
Write-Host '[OK] 学内CIDR向けの受信許可ルールを適用しました。'
Write-Host '[WARN] この設定は Windows Firewall の既定受信ポリシーが Block の前提です。'
Write-Host '[WARN] 80/443/8080 を広く許可する既存ルールがある場合は無効化してください。'
