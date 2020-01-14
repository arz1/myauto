#!/bin/bash
set -e

__rise_error()
{
    echo ERROR: $1
    exit 1
}

__is_wsl()
{
    if grep -qE "(Microsoft|WSL)" /proc/version &> /dev/null ; then
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
    local destination_path=/mnt/c/Windows/System32/

    wget $source_path
    7z e $archive_name
    mv packer.exe $destination_path
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
    if [ __is_wsl ]; then
        install_packer_win
    elif [ __is_nix ]; then
        install_packer_nix
    elif [ __is_mac ]; then
        install_packer_mac
    else
        __rise_error "Unknown platform! Cannot install packer!"
    fi
}

help()
{
    echo Help instruction to be filled ...
}

if [ $# -eq 0 ]; then
    echo "No input parameters!!"
    help
else 
    echo Input parameters: "$@"
    $1 "${@:2}"
fi

