function Enable-Wsl-Feature()
{
    Write-Host 'WSL feature enabling...'
    $ProgressPreference = 'SilentlyContinue'
    Enable-WindowsOptionalFeature -NoRestart -WarningAction SilentlyContinue -Online -FeatureName Microsoft-Windows-Subsystem-Linux
    Write-Host 'WSL feature enabled.'
}

function Install-Wsl()
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
    ./ubuntu1804.exe install --root
    bash -c 'useradd -m -p $(openssl passwd -crypt a) -s /bin/bash wsluser'
    bash -c 'usermod -aG sudo wsluser'
    ./ubuntu1804.exe config --default-user wsluser
    Write-Host 'Done.'
    Write-Host 'INSTALL GUEST ISO'
}

function Install-Wsl-Software()
{
    Set-Location '~'
    Write-Host 'Software installation...'
    bash -c 'echo a | sudo -S apt-get update'
    bash -c 'echo a | sudo -S apt-get -y install p7zip-full'
    Write-Host 'Software installed.'
}