
function Enable-Wsl-Feature()
{
    Write-Host 'WSL feature enabling...'
    $ProgressPreference = 'SilentlyContinue'
    #[void](Read-Host 'Press Enter to continue…1')
    Enable-WindowsOptionalFeature -NoRestart -WarningAction SilentlyContinue -Online -All -FeatureName Microsoft-Windows-Subsystem-Linux
    Write-Host 'WSL feature enabled.'
    #[void](Read-Host 'Press Enter to continue…')
}

function Install-Wsl($spass)
{
    Set-Location '~'
    Write-Host 'WSL downloading...'
    $ProgressPreference = 'SilentlyContinue'
    Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile WslUbuntu1804.zip -UseBasicParsing
    Write-Host 'WSL downloaded. Extraction...'
    $ProgressPreference = 'SilentlyContinue'
    Expand-Archive -Path WslUbuntu1804.zip -DestinationPath WslUbuntu1804
    Write-Host 'Extracted. Installation started...'
    Set-Location 'WslUbuntu1804'
    .\ubuntu1804.exe install --root
    bash -c "useradd -m -p `$(openssl passwd -crypt $spass) -s /bin/bash wsluser"
    bash -c 'usermod -aG sudo wsluser'
    .\ubuntu1804.exe config --default-user wsluser
    Write-Host 'Done.'
    #Write-Host 'INSTALL GUEST ISO'
}

function Install-All()
{
    #Install-Wsl a

    Write-Host "Virtualbox installation..."
    Write-Host "Downloading..."
    $ProgressPreference = 'SilentlyContinue'
    Set-Location '~'
    Invoke-WebRequest -Uri "https://download.virtualbox.org/virtualbox/6.0.14/VirtualBox-6.0.14-133895-Win.exe" -OutFile "VirtualBox-6.0.14-133895-Win.exe"
    Write-Host "Installation..."
    .\VirtualBox-6.0.14-133895-Win.exe --silent
    Write-Host "Virtualbox installed."




    Set-Location '~'

    #Write-Host 'Stage 1 already executed. Part 1 skipped.'
    Write-Host "Configure PowerShell"
    #Set-ExecutionPolicy RemoteSigned -Force
    $ProgressPreference = 'SilentlyContinue'
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    # Write-Host 'WSL feature enabling...'
    # $ProgressPreference = 'SilentlyContinue'
    # Enable-WindowsOptionalFeature -NoRestart -WarningAction SilentlyContinue -Online -All -FeatureName Microsoft-Windows-Subsystem-Linux
    # Write-Host 'WSL feature enabled.'


    Write-Host "Install Chocolatey"
    $env:chocolateyVersion = '0.10.15'
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | Invoke-Expression

    #choco install virtualbox -y

    Write-Host "Install WinRM"
    netsh advfirewall firewall add rule name="WinRM-Install" dir=in localport=5985 protocol=TCP action=block
    Get-NetConnectionProfile | ForEach-Object { Set-NetConnectionProfile -InterfaceIndex $_.InterfaceIndex -NetworkCategory Private }
    winrm quickconfig -q
    winrm quickconfig -transport:http

    winrm set winrm/config '@{MaxTimeoutms="1800000"}'
    winrm set winrm/config/winrs '@{MaxMemoryPerShellMB="800"}'
    winrm set winrm/config/service '@{AllowUnencrypted="true"}'
    winrm set winrm/config/service/auth '@{Basic="true"}'
    winrm set winrm/config/client/auth '@{Basic="true"}'
    net stop winrm
    netsh advfirewall firewall delete rule name="WinRM-Install"

    Write-Host "Configure WinRM"
    netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in localport=5985 protocol=TCP action=allow
    net start winrm

    Write-Host "Install OpenSSH"
    netsh advfirewall firewall add rule name="OpenSSH-Install" dir=in localport=22 protocol=TCP action=block
    choco install openssh -y --version 8.0.0.1 -params '"/SSHServerFeature"' # /PathSpecsToProbeForShellEXEString:$env:windir\system32\windowspowershell\v1.0\powershell.exe"'
    net stop sshd
    netsh advfirewall firewall delete rule name="OpenSSH-Install"

    Write-Host "Configure OpenSSH"
    $sshd_config = "$($env:ProgramData)\ssh\sshd_config"
    (Get-Content $sshd_config).Replace("Match Group administrators", "# Match Group administrators") | Set-Content $sshd_config
    (Get-Content $sshd_config).Replace("AuthorizedKeysFile", "# AuthorizedKeysFile") | Set-Content $sshd_config
    net start sshd

    #echo $null > $executedName
    #Write-Host "Waiting for restart..."
    #Start-Sleep -s 10    
    #Restart-Computer




    [void](Read-Host 'Press Enter to continue…')

}