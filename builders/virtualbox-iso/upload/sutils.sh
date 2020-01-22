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
        wget $source_path
        7z e $archive_name
        mv --force $file_name $destination_path
        rm $archive_name
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

    cmd.exe /c "cd %HOMEPATH%"

    if [ -w . ] ; then
        wget $source_path
        
        cmd.exe /c "start /wait msiexec.exe /a "${install_name}" /qn TARGETDIR=C:\\"
        rm $install_name
        rm "/mnt/c/"${install_name}
        setx.exe /M PATH "%PATH%;C:\Hashicorp\Vagrant\bin"
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

install_virtualbox_win()
{
    local name=VirtualBox-6.1.0-135406-Win
    local msi_name=${name}.msi
    local exe_name=${name}.exe
    local source_path=https://download.virtualbox.org/virtualbox/6.1.0/${install_name}

    cmd.exe /c "cd %HOMEPATH%"

    if [ -w . ] ; then
        wget $source_path   
        $exe_name -extract -path .     
        cmd.exe /c "start /wait msiexec.exe /i "${msi_name}" /qn"
        rm $exe_name
        rm $msi_name
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
        __rise_error "Unknown platform! Cannot install packer!"
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
        __rise_error "Unknown platform! Cannot install packer!"
    fi
}

install_software()
{
    local spass=$1

    echo $spass | sudo -S apt-get update
    echo $spass | sudo -S apt-get -y install p7zip-full

    install_virtualbox
    install_packer
    install_vagrant
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

