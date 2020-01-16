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
    if [ grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null ]; then
        echo "(W)indows (S)ubsystem (L)inux - bash"
        return 1
    else
        return 0
    fi
}

__is_nix()
{
    return 0
}

__is_mac()
{
    #OSTYPE
    return 0
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

install_packer()
{
    if  [ $(__is_win) ]; then
        install_packer_win
    elif [ $(__is_nix) ]; then
        install_packer_nix
    elif [ $(__is_mac) ]; then
        install_packer_mac
    else
        __rise_error "Unknown platform! Cannot install packer!"
    fi
}

install_software()
{
    install_packer

    echo a | sudo -S apt-get update
    echo a | sudo -S apt-get -y install p7zip-full
}

help()
{
    echo Help instruction to be filled ...
}

install_software

if [ $# -eq 0 ]; then
    echo "No input parameters!!"
    help
else 
    echo Input parameters: "$@"
    $1 "${@:2}"
fi

