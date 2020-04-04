ZynqMP-FPGA-XRT
=====================================================================

Overview
---------------------------------------------------------------------

### Introduction

This repository provides the XRT(Xilinx Runtime) Debian Package for ZynqMP-FPGA-Linux.

### What is XRT

XRT (Xilinx Runtime) is an environment for running programs developed in the development environment (Vitis) provided by Xilinx on the platform.
The source code of XRT is published on github.

  * https://github.com/ikwzm/XRT

### What is ZynqMP-FPGA-Linux

I have released Debian GNU/Linux on github for UltraZed/Ultra96/Ultra96-V2.
I have also released Ubuntu18.04 on github for Ultra96/Ultra96-V2.

  * https://github.com/ikwzm/ZynqMP-FPGA-Linux
  * https://github.com/ikwzm/ZynqMP-FPGA-Ubuntu18.04-Ultra96

The Debian Package published in this repository is for ZynqMP-FPGA-Linux or
ZynqMP-FPGA-Ubuntu18.04-Ultra96 mentioned above.


Install
---------------------------------------------------------------------

### Download

```console
shell$ git clone https://github.com/ikwzm/ZynqMP-FPGA-XRT.git
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

Device Tree
---------------------------------------------------------------------

The Debian Package installed in the previous section contains the Linux kernel module zocl for XRT's MPSoC Edge Device. However, zocl is not effective just installed on Linux. Device Tree is required to enable zocl.

ZynqMP-FPGA-Linux supports Device Tree Overlay. Device Tree Overlay actively adds and deletes FPGA programs and kernel modules running Linux. zocl is also enabled using Device Tree Overlay.

The following is an example of Device Tree Overlay to enable zocl.

```devicetree:zocl.dts
/dts-v1/; /plugin/;
/ {
        fragment@0 {
                target-path = "/fpga-full";
                __overlay__ {
                        firmware-name = "streaming_lap_filter5.bin";
                };
        };
        fragment@1 {
                target-path = "/amba_pl@0";
                __overlay__ {
                        #address-cells = <2>;
                        #size-cells = <1>;
                        zyxclmm_drm {
                                compatible = "xlnx,zocl";
                                status = "okay";
                                reg = <0x0 0xA0000000 0x10000>;
                        };
                        fclk0 {
                                compatible    = "ikwzm,fclkcfg-0.10.a";
                                clocks        = <&zynqmp_clk 0x47>;
                                insert-rate   = "100000000";
                                insert-enable = <1>;
                                remove-rate   = "1000000";
                                remove-enable = <0>;
                        };
                };
        };
};

```

In this example, the zyxclmm_drm node shows the device tree for zocl.

In addition, there are two more important points in this Device Tree.
The first is that PL Clock 0 is set to 100MHz in fclk0.

Second, the firmware-name property is added to the fpga-full node to specify a bitstream file.
This causes the specified bitstream file to be programmed into the FPGA when the Device Tree is overlaid.

The bitstream included in the xclbin file built by Xilinx's software development environment Vitis is actually for Partial Reconfiguration.

Partial Reconfiguration is a technology that dynamically rewrites only a specified area while the FPGA is originally programmed and operating.
That is, the base bitstream file must be programmed into the FPGA before Partial Reconfiguration.
At the time of Partial Reconfiguration, unlike the normal FPGA program, reset is not performed for the entire FPGA.

When zocl programs the xclbin file into the FPGA, it programs in Partial Reconfiguration mode.
Therefore, the base bitstream file must be programmed into the FPGA before enabling the zocl driver.

Examples
---------------------------------------------------------------------

 * https://github.com/ikwzm/ZynqMP-FPGA-XRT-Example-1-Ultra96

