[CmdletBinding()]
param(
    [string]$ProjectRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path,
    [string]$TaskPrefix = 'LibreBooking',
    [string]$RunAsUser = 'SYSTEM',
    [switch]$Force
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

$runJobCmd = Join-Path $ProjectRoot 'ops\windows\run-job.cmd'
if (-not (Test-Path -LiteralPath $runJobCmd)) {
    throw "run-job.cmd が見つかりません: $runJobCmd"
}

$logDir = Join-Path $ProjectRoot 'output\tasklogs'
New-Item -ItemType Directory -Path $logDir -Force | Out-Null

$tasks = @(
    @{ Name = 'autorelease';      Job = 'autorelease.php';      Schedule = 'MINUTE'; Modifier = 1; Start = '00:00' },
    @{ Name = 'sendreminders';    Job = 'sendreminders.php';    Schedule = 'MINUTE'; Modifier = 1; Start = '00:00' },
    @{ Name = 'sendmissedcheckin';Job = 'sendmissedcheckin.php';Schedule = 'MINUTE'; Modifier = 1; Start = '00:00' },
    @{ Name = 'sendwaitlist';     Job = 'sendwaitlist.php';     Schedule = 'MINUTE'; Modifier = 1; Start = '00:00' },
    @{ Name = 'sendseriesend';    Job = 'sendseriesend.php';    Schedule = 'DAILY';  Modifier = 1; Start = '00:00' },
    @{ Name = 'sessioncleanup';   Job = 'sessioncleanup.php';   Schedule = 'DAILY';  Modifier = 1; Start = '00:00' },
    @{ Name = 'deleteolddata';    Job = 'deleteolddata.php';    Schedule = 'DAILY';  Modifier = 1; Start = '01:00' }
)

foreach ($task in $tasks) {
    $taskName = "$TaskPrefix-$($task.Name)"
    $logPath = Join-Path $logDir "$($task.Name).log"
    $escapedRunJob = $runJobCmd.Replace('"', '""')
    $escapedLog = $logPath.Replace('"', '""')
    $taskCommand = "\"$escapedRunJob\" $($task.Job) >> \"$escapedLog\" 2>&1"

    $arguments = @(
        '/Create',
        '/TN', $taskName,
        '/TR', "cmd.exe /c $taskCommand",
        '/SC', $task.Schedule,
        '/MO', $task.Modifier,
        '/ST', $task.Start,
        '/RU', $RunAsUser,
        '/F'
    )

    if ($Force) {
        Write-Host "[INFO] タスクを強制再登録: $taskName"
    } else {
        Write-Host "[INFO] タスク登録: $taskName"
    }

    & schtasks.exe @arguments | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "タスク登録に失敗しました: $taskName"
    }
}

Write-Host '[OK] LibreBooking ジョブタスクの登録が完了しました。'
