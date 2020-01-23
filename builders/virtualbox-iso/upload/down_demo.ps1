
Invoke-WebRequest -Uri "https://releases.hashicorp.com/packer/1.5.1/packer_1.5.1_windows_amd64.zip" -OutFile "packer_1.5.1_windows_amd64.zip"
Expand-Archive -Path packer_1.5.1_windows_amd64.zip -DestinationPath .


Invoke-WebRequest -Uri "https://releases.hashicorp.com/vagrant/2.2.6/vagrant_2.2.6_x86_64.msi" -OutFile "vagrant_2.2.6_x86_64.msi"
#msiexec /qn /i vagrant_2.2.6_x86_64.msi VAGRANTAPPDIR=.


Invoke-WebRequest -Uri https://download.virtualbox.org/virtualbox/6.1.0/VirtualBox-6.1.0-135406-Win.exe -OutFile "VirtualBox-6.1.0-135406-Win.exe"
VirtualBox-6.1.0-135406-Win.exe -extract -path .
msiexec /i C:\Users\adarze\AppData\Local\Temp\VirtualBox\VirtualBox-6.1.0-r135406.msi