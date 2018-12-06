# Registry editing
$WindowsUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\"
$AutoUpdatePath = "HKLM:SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"

If(Test-Path -Path $WindowsUpdatePath) {
    Remove-Item -Path $WindowsUpdatePath -Recurse
}

New-Item $WindowsUpdatePath -Force
New-Item $AutoUpdatePath -Force

Set-ItemProperty -Path $AutoUpdatePath -Name NoAutoUpdate -Value 1

# Disable scheduled task for windows update.
Get-ScheduledTask -TaskPath "\Microsoft\Windows\WindowsUpdate\" | Disable-ScheduledTask

# Grant ownership and full permission to the administrators user group
takeown /F C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /A /R
icacls C:\Windows\System32\Tasks\Microsoft\Windows\UpdateOrchestrator /grant Administrators:F /T

# Disable all UpdateOrchestrator scheduled tasks
Get-ScheduledTask -TaskPath "\Microsoft\Windows\UpdateOrchestrator\" | Disable-ScheduledTask

# Stop and disable Windows Automatic Updates service
Stop-Service wuauserv
Set-Service wuauserv -StartupType Disabled

# Grant ownership and full permission to the administrators user group
takeown /F C:\Windows\System32\Tasks\Microsoft\Windows\WaaSMedic /A /R
icacls C:\Windows\System32\Tasks\Microsoft\Windows\WaaSMedic /grant Administrators:F /T

If (Get-ScheduledTask -TaskPath "\Microsoft\Windows\WaaSMedic\") {
	Get-ScheduledTask -TaskPath "\Microsoft\Windows\WaaSMedic\" | Disable-ScheduledTask
}

# Stop and disable the Windows Update Medic Service
# This is currently getting access denied.
# Stop-Service WaaSMedicSvc
# Set-Service WaaSMedicSvc -StartupType Disabled

Write-Output "Windows Automatic Updates Disable script finished executing."
Read-Host "Press any key to continue. . ."
