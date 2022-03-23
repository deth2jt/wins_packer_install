###
#
# Common
#
###
$ErrorActionPreference = "Stop"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# Installs NuGet Package Manager
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

# Installs Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

#install edge 
choco install microsoft-edge-insider -y
'"C:\Program Files (x86)\Microsoft\Edge Beta\Application\msedge.exe" "https://www.xbox.com/en-US/play"' | Out-File -FilePath c:\foo-bar.bat

#Remote desktop setup
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\' -Name "fDenyTSConnections" -Value 0
Set-ItemProperty 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp\' -Name "UserAuthentication" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"

# Installs git, and updates path
choco install git -y
$CurrentPath = (Get-Itemproperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path).Path
$NewPath = $CurrentPath + ";$($env:ProgramFiles)\Git\cmd"
Set-ItemProperty -path 'hklm:\system\currentcontrolset\control\session manager\environment' -Name Path -Value $NewPath

# Disable the DSC LCM so external services cannot interfere with configuration
[DscLocalConfigurationManager()]
Configuration LCMSettings {
  Node localhost
  {
    Settings
    {
      RefreshMode = "Disabled"
    }
  }
}
LCMSettings
Set-DscLocalConfigurationManager -Path .\LCMSettings -Verbose

# Install DSC Resource Modules for customization during deployment
Update-Module -Force -Verbose
Install-Module -Name CertificateDsc -Force -Verbose # certificate installation
Install-Module -Name NetworkingDsc -Force -Verbose # allows setting IP/network settings
Install-Module -Name ComputerManagementDsc -Force -Verbose # Computer renaming, ProductKey Installation

#install bluetooth driver 
#$blurl= "https://ftp.hp.com/pub/softpaq/sp75001-75500/sp75330.exe"
#Write-Verbose "Downloading blueooth driver" -Verbose
#Invoke-WebRequest -UseBasicParsing -Uri $blurl -OutFile sp75330.exe
#Write-Verbose "Starting Installation of blueooth driver" -Verbose
#Start-Process 'sp75330.exe' '/S /v /qn REBOOT=ReallySuppress' -Wait -Passthru

#windows update
#takes too long
#[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Install-Module -Name PSWindowsUpdate -Force -Verbose
#Get-WindowsUpdate -AcceptAll -Install -Verbose