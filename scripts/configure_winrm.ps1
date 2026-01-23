# scripts/configure_winrm.ps1
# PURPOSE: Enable WinRM for Ansible (Lab/Dev Environment)
# WARNING: This enables Basic Auth and Unencrypted HTTP. Do not use in Production without TLS.

Write-Host "🚀 Configuring WinRM for Ansible..." -ForegroundColor Cyan

# 1. Enable WinRM and PS Remoting
Write-Host "Enabling PS Remoting..."
winrm quickconfig -force
Enable-PSRemoting -Force

# 2. Configure Firewall (Port 5985)
# Note: 'winrm quickconfig' usually does this, but we force it to be sure.
Write-Host "Adding Firewall Rule for TCP 5985..."
netsh advfirewall firewall add rule name="WinRM HTTP" dir=in action=allow protocol=TCP localport=5985

# 3. Enable Authentication (Basic & Unencrypted)
# Critical for Lab environments where we don't have valid SSL Certificates.
Write-Host "Configuring Auth Settings..."
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value true
Set-Item WSMan:\localhost\Service\Auth\Basic -Value true

# 4. Restart Service to apply changes
Write-Host "Restarting WinRM Service..."
Restart-Service WinRM

Write-Host "✅ WinRM Configured! Host is ready for Ansible." -ForegroundColor Green
