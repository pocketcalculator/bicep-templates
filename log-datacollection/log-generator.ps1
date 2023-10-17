# This script writes a new log entry at the specified interval indefinitely.
# Usage:
# .\GenerateCustomLogs.ps1 [interval to sleep]
#
# Press Ctrl+C to terminate script.
#
# Example:
# .\ GenerateCustomLogs.ps1 5

param (
    [Parameter(Mandatory=$true)][int]$sleepSeconds
)

$logFolder = "c:\logs"
if (!(Test-Path -Path $logFolder))
{
    mkdir $logFolder
}

$logFileName = "appoutput.log"
do
{
    $count++
    $randomContent = New-Guid
    $logRecord = "blue Thursday $(Get-Date -format s)Z $count $randomContent completed"
    $logRecord | Out-File "$logFolder\\$logFileName" -Encoding utf8 -Append
    Start-Sleep $sleepSeconds
}
while ($true)