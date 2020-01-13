#!/bin/bash
set -e

__rise_error()
{
    echo ERROR: $1
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
    echo install_packer_win
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
    __rise_error "No input parameters!!"
    help
else 
    echo Input parameters: "$@"
    $1 "${@:2}"
fi

