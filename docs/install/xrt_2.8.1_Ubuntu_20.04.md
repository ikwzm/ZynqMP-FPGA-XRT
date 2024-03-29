Install XRT 2.8.1 to Ubuntu 20.04
---------------------------------------------------------------------

### Download

```console
shell$ git clone --depth 1 --branch 2020.2_EDGE_1_Ubuntu_20.04 https://github.com/ikwzm/ZynqMP-FPGA-XRT.git
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

Install xrt_202020.2.8.1_Edge_Ubuntu_20.04-arm64.deb with the apt command.
When installing this package, build the zocl kernel module using the dkms mechanism during the process. Therefore, installation takes time.


```console
shell$ sudo apt-get install ./xrt_202020.2.8.1_Edge_Ubuntu_20.04-arm64.deb
Reading package lists... Done
Building dependency tree
Reading state information... Done
Note, selecting 'xrt' instead of './xrt_202020.2.8.1_Edge_Ubuntu_20.04-arm64.deb'
The following NEW packages will be installed:
  xrt
  0 upgraded, 1 newly installed, 0 to remove and 449 not upgraded.
  Need to get 0 B/6307 kB of archives.
  After this operation, 40.2 MB of additional disk space will be used.
  Get:1 /home/fpga/debian/ZynqMP-FPGA-XRT/xrt_202020.2.8.1_Edge_Ubuntu_20.04-arm64.deb xrt arm64 2.8.1 [6307 kB]
  Selecting previously unselected package xrt.
  (Reading database ... 211957 files and directories currently installed.)
  Preparing to unpack .../xrt_202020.2.8.1_Edge_Ubuntu_20.04-arm64.deb ...
  Unpacking xrt (2.8.1) ...
  Setting up xrt (2.8.1) ...
  Unloading old XRT Linux kernel modules
  rmmod: ERROR: Module zocl is not currently loaded
  Invoking DKMS common.postinst for xrt
  Loading new xrt-2.8.1 DKMS files...
  Building for 5.4.0-xlnx-v2020.2-zynqmp-fpga
  Building initial module for 5.4.0-xlnx-v2020.2-zynqmp-fpga
  Done.

zocl.ko:
Running module version sanity check.
 - Original module
    - No original module exists within this kernel
     - Installation
        - Installing to /lib/modules/5.4.0-xlnx-v2020.2-zynqmp-fpga/updates/dkms/

depmod....

DKMS: install completed.
Finished DKMS common.postinst
Loading new XRT Linux kernel modules
```

### Install XRT-Setup Debian Package

```console
shell$ apt-get install ./xrt-setup_2.8.0-1_arm64.deb
Reading package lists... Done
Building dependency tree
Reading state information... Done
Note, selecting 'xrt-setup' instead of './xrt-setup_2.8.0-1_arm64.deb'
The following NEW packages will be installed:
  xrt-setup
  0 upgraded, 1 newly installed, 0 to remove and 449 not upgraded.
  After this operation, 43.0 kB of additional disk space will be used.
  Get:1 /home/fpga/debian/ZynqMP-FPGA-XRT/xrt-setup_2.8.0-1_arm64.deb xrt-setup arm64 2.8.0-1 [1336 B]
  Selecting previously unselected package xrt-setup.
  (Reading database ... 212195 files and directories currently installed.)
  Preparing to unpack .../xrt-setup_2.8.0-1_arm64.deb ...
  Unpacking xrt-setup (2.8.0-1) ...
  Setting up xrt-setup (2.8.0-1) ...
```

