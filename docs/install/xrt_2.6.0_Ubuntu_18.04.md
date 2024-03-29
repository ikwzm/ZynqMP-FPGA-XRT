Install XRT 2.6.0 to Ubuntu 18.04 or Debian 10
---------------------------------------------------------------------

### Download

```console
shell$ git clone --depth 1 --branch 2020.1_EDGE_0_Ubuntu_18.04 https://github.com/ikwzm/ZynqMP-FPGA-XRT.git
```

### Preparing for installation

please install python-pyopencl before installing XRT.

```console
shell$ sudo apt install -y python-pyopencl
```

If this package is not installed, it will try to install pyopencl with pip when installing xrt_202010.2.6.0_Ubuntu_18.04-arm64-xrt.deb.
To install pyopencl with pip, you had to compile a program written in C, and the installation failed due to various troubles.
Installing pyopencl pre-built for Debian/Ubuntu from the beginning will save you trouble.

### Install XRT Debian Package

Install xrt_202010.2.6.0_Ubuntu_18.04-arm64-xrt.deb with the apt command.
When installing this package, build the zocl kernel module using the dkms mechanism during the process. Therefore, installation takes time.


```console
shell$ sudo apt install ./xrt_202010.2.6.0_Ubuntu_18.04-arm64-xrt.deb
Reading package lists... Done
Building dependency tree
Reading state information... Done
Note, selecting 'xrt' instead of './xrt_202010.2.6.0_Ubuntu_18.04-arm64-xrt.deb'
The following packages were automatically installed and are no longer required:
  libgl2ps1.4 libibverbs1 liblept5 libnetcdf-c++4 libnl-route-3-200
  libopencv-flann-dev libopencv-flann3.2 libopencv-ml-dev libopencv-ml3.2
  libopencv-photo-dev libopencv-photo3.2 libopencv-shape-dev
  libopencv-shape3.2 libopencv-ts-dev libopencv-video-dev libopencv-video3.2
  libtcl8.6 libtesseract4 libtk8.6 libxss1
Use 'sudo apt autoremove' to remove them.
The following NEW packages will be installed:
  xrt
0 upgraded, 1 newly installed, 0 to remove and 50 not upgraded.
Need to get 0 B/8,150 kB of archives.
After this operation, 49.0 MB of additional disk space will be used.
Get:1 /home/fpga/work/ZynqMP-FPGA-XRT/xrt_202010.2.6.0_Ubuntu_18.04-arm64-xrt.deb xrt arm64 2.6.0 [8,150 kB]
Selecting previously unselected package xrt.
(Reading database ... 114691 files and directories currently installed.)
Preparing to unpack .../xrt_202010.2.6.0_Ubuntu_18.04-arm64-xrt.deb ...
Unpacking xrt (2.6.0) ...
Setting up xrt (2.6.0) ...
Unloading old XRT Linux kernel modules
rmmod: ERROR: Module zocl is not currently loaded
Invoking DKMS common.postinst for xrt
Loading new xrt-2.6.0 DKMS files...
Building for 4.19.0-xlnx-v2019.2-zynqmp-fpga
Building initial module for 4.19.0-xlnx-v2019.2-zynqmp-fpga
Done.

zocl:
Running module version sanity check.
 - Original module
   - No original module exists within this kernel
 - Installation
   - Installing to /lib/modules/4.19.0-xlnx-v2019.2-zynqmp-fpga/updates/dkms/

depmod...

DKMS: install completed.
Finished DKMS common.postinst
Loading new XRT Linux kernel modules
Skipping pyopencl installation...
```

### Install XRT-Setup Debian Package

```console
shell$ sudo apt install ./xrt-setup_2.6.0-1_arm64.deb
Reading package lists... Done
Building dependency tree
Reading state information... Done
Note, selecting 'xrt-setup' instead of './xrt-setup_2.6.0-1_arm64.deb'
The following NEW packages will be installed:
  xrt-setup
0 upgraded, 1 newly installed, 0 to remove and 71 not upgraded.
After this operation, 30.7 kB of additional disk space will be used.
Get:1 /home/fpga/work/ZynqMP-FPGA-XRT/xrt-setup_2.6.0-1_arm64.deb xrt-setup arm64 2.6.0-1 [1,276 B]
debconf: unable to initialize frontend: Dialog
debconf: (Dialog frontend will not work on a dumb terminal, an emacs shell buff\
er, or without a controlling terminal.)
debconf: falling back to frontend: Readline

Selecting previously unselected package xrt-setup.
(Reading database ... 115056 files and directories currently installed.)
Preparing to unpack .../xrt-setup_2.6.0-1_arm64.deb ...
```

