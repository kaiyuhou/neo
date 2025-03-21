#!/bin/bash
#
# Set up the development environment.
#

set -euo pipefail

SCRIPT_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
cd "$SCRIPT_DIR"

msg() {
    echo -e "[+] ${1-}" >&2
}

die() {
    echo -e "[!] ${1-}" >&2
    exit 1
}

[ $UID -eq 0 ] && die 'Please run this script without root privilege'

#
# Output a short name of the Linux distribution
#
get_distro() {
    if test -f /etc/os-release; then # freedesktop.org and systemd
        . /etc/os-release
        echo $NAME | cut -f 1 -d ' ' | tr '[:upper:]' '[:lower:]'
    elif type lsb_release >/dev/null 2>&1; then # linuxbase.org
        lsb_release -si | tr '[:upper:]' '[:lower:]'
    elif test -f /etc/lsb-release; then
        . /etc/lsb-release
        echo "$DISTRIB_ID" | tr '[:upper:]' '[:lower:]'
    elif test -f /etc/arch-release; then
        echo "arch"
    elif test -f /etc/debian_version; then
        # Older Debian, Ubuntu
        echo "debian"
    elif test -f /etc/SuSe-release; then
        # Older SuSE
        echo "opensuse"
    elif test -f /etc/fedora-release; then
        # Older Fedora
        echo "fedora"
    elif test -f /etc/redhat-release; then
        # Older Red Hat, CentOS
        echo "centos"
    elif type uname >/dev/null 2>&1; then
        # Fall back to uname
        echo "$(uname -s)"
    else
        die 'Unable to determine the distribution'
    fi
}

#
# Check if the AUR package exists (0: yes; 1: no)
#
aur_pkg_exists() {
    RETURN_CODE="$(curl -I "https://aur.archlinux.org/packages/$1" 2>/dev/null \
        | head -n1 | cut -d ' ' -f 2)"
    if [ "$RETURN_CODE" = "200" ]; then
        return 0    # package found
    elif [ "$RETURN_CODE" = "404" ]; then
        return 1    # package not found
    else
        die "AUR HTTP $RETURN_CODE for $1"
    fi
    unset RETURN_CODE
}

#
# Build and install the package with PKGBUILD
#
makepkg_arch() {
    TARGET="$1"
    shift
    msg "Building $TARGET..."
    pushd "$TARGET"
    makepkg -sri $@
    popd # "$TARGET"
}

#
# Build and install the package with PKGBUILD
#
makepkg_ubuntu() {
    export MAKEFLAGS="-j$(nproc)"
    [[ -z "${CFLAGS+x}" ]] && export CFLAGS=""
    [[ -z "${CXXFLAGS+x}" ]] && export CXXFLAGS=""

    TARGET="$1"
    shift
    msg "Building $TARGET..."
    pushd "$TARGET"
    sed -i PKGBUILD \
        -e 's|\<python\> |python3 |g' \
        -e '/[[:space:]]*rm -rf .*\$pkgdir\>.*$/d'
    source PKGBUILD
    srcdir="$(realpath src)"
    pkgdir=/
    mkdir -p "$srcdir"
    # prepare the sources
    i=0
    for s in ${source[@]}; do
        target=${s%%::*}
        url=${s#*::}
        if [[ "$target" == "$url" ]]; then
            target=$(basename "${url%%#*}" | sed 's/\.git$//')
        fi
        # fetch the source files if they do not exist already
        if [[ ! -e "$target" ]]; then
            # only support common tarballs and git sources
            if [[ "$url" == git+http* ]]; then
                git clone $(echo ${url%%#*} | sed -e 's/^git+//') $target
                # check out the corresponding revision if there is a fragment
                fragment=${url#*#}
                if [[ "$fragment" != "$url" ]]; then
                    pushd $target
                    git checkout ${fragment#*=}
                    popd
                fi
            elif [[ "$url" == *.tar.* ]]; then
                curl -L "$url" -o "$target" >/dev/null 2>&1
            else
                die "Unsupported source URL $url"
            fi
        fi
        # create links in the src directory
        ln -sf "../$target" "$srcdir/$target"
        # extract tarballs if the target is not in noextract
        if [[ "$target" == *.tar.* && ! " ${noextract[@]} " =~ " $target " ]]; then
            tar -C "$srcdir" -xf "$srcdir/$target"
        fi
        i=$((i + 1))
    done
    # execute the PKGBUILD functions
    pushd "$srcdir"
    [ "$(type -t prepare)" = "function" ] && prepare
    [ "$(type -t build)" = "function" ] && build
    [ "$(type -t check)" = "function" ] && check
    sudo bash -c "pkgdir=\"$pkgdir\"; srcdir=\"$srcdir\";
                  source \"$srcdir/../PKGBUILD\"; package"
    popd # "$srcdir"
    popd # "$TARGET"
}

#
# Build and install package from AUR
#
aur_install() {
    TARGET="$1"
    shift
    if ! aur_pkg_exists "$TARGET"; then
        die "AUR package $TARGET not found"
    fi
    if [[ -d "$TARGET" ]]; then
        cd "$TARGET"; git pull; cd ..
    else
        git clone "https://aur.archlinux.org/$TARGET.git"
    fi
    (makepkg_$(get_distro) "$TARGET" $@)
    rm -rf "$TARGET"
}

#
# Install pre-built cmake manually
#
install_cmake() {
    CMAKE_VER=3.19.6
    URL="https://github.com/Kitware/CMake/releases/download/v${CMAKE_VER}/cmake-${CMAKE_VER}-Linux-x86_64.tar.gz"
    TARBALL="$(basename $URL)"
    DIR="${TARBALL%.tar.gz}"
    curl -LO "$URL"
    tar xf "$TARBALL"
    sudo rsync -av "$DIR"/* /usr/local/
    rm -rf "$TARBALL" "$DIR"
}

main() {
    DISTRO="$(get_distro)"

    if [ "$DISTRO" = "arch" ]; then
        makedepends=(make cmake clang spin-git)
        depends=(libnet ipvsadm squid)
        experiment_depends=(astyle python-toml bc)

        if ! pacman -Q yay >/dev/null 2>&1; then
            aur_install yay --needed --noconfirm --asdeps
        fi
        yay -S --needed --noconfirm --removemake ${makedepends[@]} $@
        yay -S --needed --noconfirm --removemake ${depends[@]} $@
        yay -S --needed --noconfirm --removemake ${experiment_depends[@]} $@

    elif [ "$DISTRO" = "ubuntu" ]; then
        script_depends=(build-essential curl git bison rsync)
        makedepends=(make cmake clang libnet1-dev)
        depends=(libnet1 ipvsadm squid)
        experiment_depends=(astyle python3-toml bc)
        aur_pkgs=(spin-git)

        sudo apt update -y -qq
        sudo apt install -y -qq ${script_depends[@]}
        sudo apt install -y -qq ${makedepends[@]}
        sudo apt install -y -qq ${depends[@]}
        sudo apt install -y -qq ${experiment_depends[@]}
        for pkg in ${aur_pkgs[@]}; do
            aur_install "$pkg"
        done
        install_cmake   # for ubuntu 18 (cmake 3.10)

    else
        die "Unsupported distribution: $DISTRO"
    fi

    msg "Finished"
}


main $@

# vim: set ts=4 sw=4 et:
