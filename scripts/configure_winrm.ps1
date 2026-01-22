# scripts/configure_winrm.ps1
# PURPOSE: Bootstrapper to enable WinRM for Ansible management
# USAGE: Run this via RDP or User Data on the target Windows Server ONCE.

Write-Host "Configuring WinRM for Ansible..." -ForegroundColor Cyan

# 1. Ensure the network connection is Private (WinRM firewall rules restrict Public networks)
$networkProfile = Get-NetConnectionProfile
if ($networkProfile.NetworkCategory -ne 'Private') {
    Write-Host "Setting Network Profile to Private..."
    Set-NetConnectionProfile -InterfaceIndex $networkProfile.InterfaceIndex -NetworkCategory Private
}

# 2. Enable PowerShell Remoting (Force ensures it runs without prompt)
Enable-PSRemoting -Force

# 3. Configure Auth: Allow Basic (Required for simple Ansible setups)
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true

# 4. Configure Traffic: Allow Unencrypted (Required unless you generate valid Certs)
# Note: In Prod, use HTTPS. For this Lab/Demo, HTTP is acceptable.
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true

# 5. Restart WinRM Service to apply changes
Restart-Service WinRM

Write-Host "WinRM Configured successfully. Host is ready for Ansible." -ForegroundColor Green