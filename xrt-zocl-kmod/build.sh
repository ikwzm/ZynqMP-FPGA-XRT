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
# Linux Kernel Release Name
#
if [[ -z "$KERNEL_RELEASE" ]]; then
    KERNEL_RELEASE=`uname -r`
fi
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
THIS_DEBIAN_DIR=`readlink -f $THIS_SCRIPT_DIR/debian`
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
    do_help_option "-build, build     Remove build directories"
    do_help_option "-clean, clean     Remove build directories"
    do_help_option "-prepare, prepare Prepare build directories"
    do_help_option "-h, --help        Run Help command"
    do_help_option "-n, --dry-run     Don't actually run any command"
    do_help_option "-v, --verbose     Turn on verbosity"
    do_help_option "-A, --arch           <args> Architecture Name" "$ARCH"
    do_help_option "-B, --build-version  <args> Build version" "$XRT_VERSION_PATCH"
    do_help_option "-R, --kernel-release <args> Linux Kernel Release Name" "$KERNEL_RELEASE"
    do_help_option "-K, --kernel-source  <args> Linux kernel Source Directory" $kernel_src_dir
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
        -A | --arch )
            shift
            arch=$1
            ;;
	-B | --build-version )
	    shift
	    xrt_version_patch=$1
	    shift
	    ;;
        -R | --kernel-release )
            shift
            kernel_release=$1
            ;;
        -K | --kernel-source )
            shift
            kernel_src_dir=$1
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

if [[ -z "$deb_arch" ]]; then
    deb_arch=$arch
fi

if [[ -z "$kernel_release" ]]; then
    kernel_release="$KERNEL_RELEASE"
fi

if [[ -z "$kernel_src_dir" ]]; then
    if [[ -n "$KERNEL_SRC" ]]; then
        kernel_src_dir="$KERNEL_SRC"
    else
        kernel_src_dir="/lib/modules/$kernel_release/build"
    fi
fi

if [[ -z "$xrt_version_patch" ]]; then
    xrt_version_patch=$XRT_VERSION_PATCH
fi

source /etc/os-release
OS_HOST=$ID
if [[ $OS_HOST != "ubuntu" ]] && [[ $OS_HOST != "debian" ]]; then
    do_error "Please use ubuntu/debian machine for building, $OS_HOST not supported."
fi

if [ -z "${command_list}" ]; then
    command_list="clean prepare build"
fi

if [[ $verbose -ne 0 ]]; then
    echo "## $PROGRAM"
    echo "##   ARCH             = $arch"
    echo "##   KERNEL_RELEASE   = $kernel_release"
    echo "##   KERNEL_SRC_DIR   = $kernel_src_dir"
    echo "##   BUILD_DIR        = $BUILD_DIR"
    echo "##   XRT_DIR          = $XRT_DIR"
    echo "##   XRT_VERSION_PATCH= $xrt_version_patch"
    echo "##   OS_HOST          = $OS_HOST"
    echo "##   COMMAND_LIST     = $command_list"
fi

if [[ ! -d $THIS_DEBIAN_DIR ]]; then
    do_error "$THIS_DEBIAN_DIR is not accessible"
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
    run_command "cp -rf $THIS_DEBIAN_DIR/* $BUILD_DIR/debian"
    run_command "cp -rf $XRT_DIR/build/debian/copyright $BUILD_DIR/debian"
    run_command "cp -rf $XRT_DIR/build/debian/changelog $BUILD_DIR/debian"

    run_command "sed -i \"1d\" $BUILD_DIR/debian/changelog"
    run_command "sed -i \"1s/^/xrt-zocl (${XRT_MAJOR_VERSION}.${XRT_MINOR_VERSION}.${xrt_version_patch}) experimental;urgency=medium\n/\" $BUILD_DIR/debian/changelog"

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
    run_command "env XRT_VERSION_PATCH=$xrt_version_patch debian/rules xrt_src_dir=$BUILD_DIR/src kernel_release=$kernel_release arch=$arch deb_arch=$deb_arch kernel_src_dir=$kernel_src_dir binary"
    run_command "cd $THIS_SCRIPT_DIR"
}

set $command_list
while [ $# -gt 0 ]; do
    case "$1" in
	"help"   ) do_help    ;;
	"clean"  ) do_clean   ;;
	"prepare") do_prepare ;;
	"build"  ) do_build   ;;
    esac
    shift
done
