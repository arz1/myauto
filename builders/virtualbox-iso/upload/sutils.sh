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

    if [ -w . ] ; then
        wget $source_path
        
        cmd.exe /c "start /wait msiexec.exe /a c:\Users\Administrator\vagrant_2.2.6_x86_64.msi /qn TARGETDIR=c:\avagh55"
        #cmd.exe /c "start /wait msiexec.exe /a c:\users\Administrator\vagrant_2.2.6_x86_64.msi /qn TARGETDIR=c:\vagh"
        # rm $install_name from avagh55
        rm $install_name
    else
        __rise_error "Cannot write to path "${destination_path}" Try run WLS with elevated Windows privilages."
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

install_software()
{
    local spass=$1
    
    echo $spass | sudo -S apt-get update
    echo $spass | sudo -S apt-get -y install p7zip-full

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

