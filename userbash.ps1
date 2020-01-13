Enable-WindowsOptionalFeature -NoRestart -Online -FeatureName Microsoft-Windows-Subsystem-Linux
#Force restart
# After restart
#If the download is taking a long time, turn off the progress bar by setting 
$ProgressPreference = 'SilentlyContinue'
Invoke-WebRequest -Uri https://aka.ms/wsl-ubuntu-1804 -OutFile WslUbuntu1804.zip -UseBasicParsing
Expand-Archive -Path WslUbuntu1804.zip -DestinationPath WslUbuntu1804
cd WslUbuntu1804
.\ubuntu1804.exe install --root
wsl
useradd -m -p $(openssl passwd -crypt a) -s /bin/bash wsluser
usermod -aG sudo wsluser
exit
.\ubuntu1804.exe config --default-user wsluser
#bash -c "echo a | sudo -S apt-get update"
