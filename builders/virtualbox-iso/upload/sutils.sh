#!/bin/bash
set -e

__rise_error()
{
    echo ERROR: $1
    echo Processing aborted.
    exit 2
}

__is_wsl()
{
    if [[ "$(< /proc/sys/kernel/osrelease)" == *Microsoft ]]; then
        echo "(W)indows (S)ubsystem (L)inux - bash" >&2
        echo 0
    else
        echo 1
    fi
}

__is_nix()
{
    echo 0
}

__is_mac()
{
    #OSTYPE
    echo 0
}

install_packer_win()
{
    local platform=windows
    local archive_name=packer_1.5.1_${platform}_amd64.zip
    local source_path=https://releases.hashicorp.com/packer/1.5.1/${archive_name}
    local file_name=packer.exe
    local destination_path=/mnt/c/Windows/System32/

    if [ -w $destination_path ] ; then
        wget -nv $source_path
        echo Packer installation started...
        7z e $archive_name
        mv --force $file_name $destination_path
        rm $archive_name
        echo Packer installation finished.
    else
        __rise_error "Cannot write to path "${destination_path}" Try run WLS with elevated Windows privilages."
    fi
}

install_packer_nix()
{
    echo install_packer_nix
}

install_packer_mac()
{
    echo install_packer_mac
}

install_vagrant_win()
{
    local install_name=vagrant_2.2.6_x86_64.msi
    local source_path=https://releases.hashicorp.com/vagrant/2.2.6/${install_name}
    local win_user=$1

    __goto_winhome

    if [ -w . ] ; then
        wget -nv $source_path
        echo Vagrant installation started...
        cmd.exe /c "start /wait msiexec.exe /a "${install_name}" /qn TARGETDIR=C:\\"
        rm $install_name
        rm "/mnt/c/"${install_name}
        setx.exe /M PATH "%PATH%;C:\Hashicorp\Vagrant\bin"
        echo Vagrant installation finished.
        echo Machine restart adviced...
    else
        __rise_error "Cannot write to path saved in %HOMEPATH%. Try run WLS with elevated Windows privilages."
    fi
}

install_vagrant_nix()
{
    echo install_vagrant_nix
}

install_vagrant_mac()
{
    echo install_vagrant_mac
}

__goto_winhome()
{
    local winhome=$(wslpath $(cmd.exe /C "echo %USERPROFILE%" | tr -d '\r'))
    cd $winhome
}

__install_virtualbox_certs_win()
{
    local install_name=VBoxGuestAdditions_6.0.14.iso
    local source_path=https://download.virtualbox.org/virtualbox/6.0.14/${install_name}

    echo Virtualbox certs installation started...
    echo Download guest additions. Please wait...

    wget -nv $source_path

    local dir_name=VBoxGuestAdditions_6.0.14

    7z x -y -o$dir_name $install_name
    
    # Ignore if certs already installed.
    cmd.exe /c "${dir_name}\\cert\\VBoxCertUtil.exe add-trusted-publisher ${dir_name}\\cert\\vbox*.cer --root ${dir_name}\\cert\\vbox*.cer" || :

    rm ./$install_name
    rm -rf ./$dir_name

    echo Virtualbox certs installation finished.
}

install_virtualbox_win()
{
    local install_name=VirtualBox-6.0.14-133895-Win.exe
    local source_path=https://download.virtualbox.org/virtualbox/6.0.14/${install_name}

    local msi_name_x64=VirtualBox-6.0.14-r133895-MultiArch_amd64.msi
    local msi_name_x86=VirtualBox-6.0.14-r133895-MultiArch_x86.msi
    
    __goto_winhome    

    if [ -w . ] ; then
        # wget -nv $source_path   
        # echo Virtualbox installation started...
        # ./$install_name --silent
        # echo Virtualbox installation cleaning...
        # rm ./$install_name
        # echo Virtualbox installation finished.

        __install_virtualbox_certs_win

        echo Virtualbox installation started...
        echo Download. Please wait...

        wget -nv $source_path        
        echo Download finished. Extracting.
        #./$install_name --extract --silent --path .
        #echo Installation files extracted. Execution...
        #cmd.exe /c "start /wait msiexec.exe /i "${msi_name_x64}" /qn /L*V mylog.log"
        #cmd.exe /c "start /B /wait """" ${install_name} --silent --ignore-reboot"
        cmd.exe /c "${install_name} --silent --ignore-reboot"
        echo Virtualbox installation cleaning...
        #rm ./$install_name
        #rm ./$msi_name_x64
        #rm ./$msi_name_x86
        echo Virtualbox installation finished.

        #//certutil -addstore "TrustedPublisher" oracle.cer
        #start /wait VirtualBox-6.1.0-135406-Win.exe --silent

    else
        __rise_error "Cannot write to path saved in %HOMEPATH%. Try run WLS with elevated Windows privilages."
    fi    
}

install_virtualbox_nix()
{
    echo install_virtualbox_nix    
}

install_virtualbox_mac()
{
    echo install_virtualbox_mac    
}

install_packer()
{
    if [ $(__is_wsl) -eq 0 ]; then
        install_packer_win
    elif [ $(__is_nix) -eq 0 ]; then
        install_packer_nix
    elif [ $(__is_mac) -eq 0 ]; then
        install_packer_mac
    else
        __rise_error "Unknown platform! Cannot install packer!"
    fi
}

install_vagrant()
{
    if [ $(__is_wsl) -eq 0 ]; then
        install_vagrant_win
    elif [ $(__is_nix) -eq 0 ]; then
        install_vagrant_nix
    elif [ $(__is_mac) -eq 0 ]; then
        install_vagrant_mac
    else
        __rise_error "Unknown platform! Cannot install vagrant!"
    fi
}

install_virtualbox()
{
    if [ $(__is_wsl) -eq 0 ]; then
        install_virtualbox_win
    elif [ $(__is_nix) -eq 0 ]; then
        install_virtualbox_nix
    elif [ $(__is_mac) -eq 0 ]; then
        install_virtualbox_mac
    else
        __rise_error "Unknown platform! Cannot install virtualbox!"
    fi
}

install_software()
{
    local spass=$1

    echo $spass | sudo -S apt-get update
    echo $spass | sudo -S apt-get -y install p7zip-full

    install_virtualbox
    #install_packer
    #install_vagrant
}

help()
{
    echo Help instruction to be filled ...
}

#install_software

if [ $# -eq 0 ]; then
    echo "No input parameters!!"
    help
else 
    echo Input parameters: "$@"
    $1 "${@:2}"
fi

