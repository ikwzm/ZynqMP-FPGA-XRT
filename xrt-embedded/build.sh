#!/usr/bin/env bash
#
# Script to build the xrt-zocl debian package
#
__copyright__='Copyright (C) 2023 ikwzm'
__version__='0.1'
__license__='BSD-2-Clause'
__author__='ikwzm'
__author_email__='ichiro_k@ca2.so-net.ne.jp'
__url__='https://github.com/ikwzm/ZynqMP-FPGA-XRT'
#
# XRT Version variables
#
XRT_MAJOR_VERSION=2
XRT_MINOR_VERSION=15
XRT_RELEASE_VERSION=202310
XRT_VERSION_PATCH=1
#
# Architecture Name
#
if [[ -z "$ARCH" ]]; then
    ARCH=`(uname -m | sed -e s/arm.*/arm/ -e s/aarch64.*/arm64/)`
fi
#
# Script Name
#
PROGRAM=`basename $0`
#
# Build Directoriy
#
THIS_SCRIPT=`readlink -f ${BASH_SOURCE[0]}`
THIS_SCRIPT_DIR=$(dirname "$THIS_SCRIPT")
BUILD_FOLDER=build
BUILD_DIR=$THIS_SCRIPT_DIR/$BUILD_FOLDER
#
# XRT Repository Path
#
if [[ -z "$XRT_DIR" ]]; then
    XRT_DIR=`readlink -f $THIS_SCRIPT_DIR/../XRT/`
fi

set -e
verbose=0
dry_run=0
error=0
command_list=""

do_help_option()
{
    if [[ -z "$2" ]]; then
        echo "    $1"
    else
        echo "    $1 (default=$2)"
    fi
}


do_help()
{
    echo "Usage: $PROGRAM [options] "
    echo "  options:"
    do_help_option "-build, build     Build debian package"
    do_help_option "-post, post       Rename debian package"
    do_help_option "-clean, clean     Remove build directories"
    do_help_option "-prepare, prepare Prepare build directories"
    do_help_option "-h, --help        Run Help command"
    do_help_option "-n, --dry-run     Don't actually run any command"
    do_help_option "-v, --verbose     Turn on verbosity"
    do_help_option "-A, --arch <args> Architecture Name" "$ARCH"
    echo ""
}

do_error()
{
    echo "## $PROGRAM: ERROR: $1" 1>&2
    error=1
}

run_command()
{
    if [[ $dry_run -ne 0 ]] || [[ $verbose -ne 0 ]]; then
	echo "$1"
    fi
    if [[ $dry_run -eq 0 ]]; then
	eval "$1"
    fi
}

while [[ $# -gt 0 ]]; do
    case "$1" in
	-h |--help )
	    command_list="$command_list help"
	    ;;
	-v | --verbose )
	    verbose=1
	    ;;
	-n | --dry-run )
	    dry_run=1
	    ;;
        -build | build | --build )
	    command_list="$command_list build"
	    ;;
        -clean | clean | --clean )
	    command_list="$command_list clean"
	    ;;
        -prepare | prepare | --prepare )
	    command_list="$command_list prepare"
	    ;;
        -post | post | --post )
	    command_list="$command_list post"
	    ;;
        -A | --arch )
            shift
            arch=$1
            ;;
	-B | --build-version )
	    shift
	    xrt_version_patch=$1
	    shift
	    ;;
        --* | -* )
           do_error "Unregognized option: $1"
           ;;
         * )
           do_error "Unregognized option: $1"
           ;;
    esac
    shift
done

if [[ -z "$arch" ]]; then
    arch="$ARCH"
fi

if [[ -z "$xrt_version_patch" ]]; then
    xrt_version_patch=$XRT_VERSION_PATCH
fi

source /etc/os-release
OS_HOST=$ID
OS_VERSION=$VERSION_ID
if [[ $OS_HOST != "ubuntu" ]] && [[ $OS_HOST != "debian" ]]; then
    do_error "Please use ubuntu/debian machine for building, $OS_HOST not supported."
fi
if   [[ $OS_HOST == "ubuntu" ]]; then
    OS_NAME="Ubuntu_${VERSION_ID}"
elif [[ $OS_HOST == "debian" ]]; then
    OS_NAME="Debian_${VERSION_ID}"
fi

if [ -z "${command_list}" ]; then
    command_list="clean prepare build post"
fi

if [[ $verbose -ne 0 ]]; then
    echo "## $PROGRAM"
    echo "##   ARCH             = $arch"
    echo "##   BUILD_DIR        = $BUILD_DIR"
    echo "##   XRT_DIR          = $XRT_DIR"
    echo "##   XRT_VERSION_PATCH= $xrt_version_patch"
    echo "##   OS_HOST          = $OS_HOST"
    echo "##   OS_NAME          = $OS_NAME"
    echo "##   COMMAND_LIST     = $command_list"
fi

if [[ $error -ne 0 ]]; then
    do_help
    exit 1
fi

do_clean()
{
    if [[ $verbose -gt 0 ]]; then
	echo "## $PROGRAM: Clean $THIS_SCRIPT_DIR/$BUILD_FOLDER"
    fi
    run_command "/bin/rm -rf $THIS_SCRIPT_DIR/$BUILD_FOLDER"
}

do_prepare()
{
    if [[ $verbose -gt 0 ]]; then
	echo "## $PROGRAM: Prepare $BUILD_DIR"
    fi
    if [[ $dry_run -eq 0 ]] && [[ -d $BUILD_DIR ]]; then
	do_error "$BUILD_DIR is already exists"
	exit 1
    fi
    run_command "mkdir -p $BUILD_DIR"
    run_command "cd $BUILD_DIR"
    run_command "rsync -r $XRT_DIR/* $BUILD_DIR --exclude=build"

    run_command "mkdir -p $BUILD_DIR/debian"
    run_command "cp -rf $XRT_DIR/build/debian/* $BUILD_DIR/debian"

    run_command "sed -i \"1d\" $BUILD_DIR/debian/changelog"
    run_command "sed -i \"1s/^/xrt (${XRT_MAJOR_VERSION}.${XRT_MINOR_VERSION}.${xrt_version_patch}) experimental;urgency=medium\n/\" $BUILD_DIR/debian/changelog"

    run_command "cd $THIS_SCRIPT_DIR"
}

do_build()
{
    if [[ $verbose -gt 0 ]]; then
	echo "## $PROGRAM: Build"
    fi
    if [[ $dry_run -eq 0 ]] && [[ ! -d $BUILD_DIR ]]; then
	do_error "$BUILD_DIR does not exist"
	exit 1
    fi
    run_command "cd $BUILD_DIR"
    run_command "env XRT_VERSION_PATCH=$xrt_version_patch debian/rules binary"
    run_command "cd $THIS_SCRIPT_DIR"
}

do_post()
{
    old_tag="${XRT_MAJOR_VERSION}.${XRT_MINOR_VERSION}.${xrt_version_patch}_${arch}"
    new_tag="${XRT_RELEASE_VERSION}.${XRT_MAJOR_VERSION}.${XRT_MINOR_VERSION}.${xrt_version_patch}_${OS_NAME}-${arch}"
    run_command "mv xrt-embedded_${old_tag}.deb xrt_embedded_${new_tag}.deb"
    run_command "mv xrt-zocl-dkms_${old_tag}.deb xrt_zocl_dkms_${new_tag}.deb"
    run_command "mv xrt-embedded-dbgsym_${old_tag}.ddeb xrt_embedded_dbgsym_${new_tag}.ddeb"
}

set $command_list
while [ $# -gt 0 ]; do
    case "$1" in
	"help"   ) do_help    ;;
	"clean"  ) do_clean   ;;
	"prepare") do_prepare ;;
	"build"  ) do_build   ;;
	"post"   ) do_post    ;;
    esac
    shift
done
