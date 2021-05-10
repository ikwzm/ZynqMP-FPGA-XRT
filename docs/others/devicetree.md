Device Tree Example
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
                        #size-cells = <2>;
                        zyxclmm_drm {
                                compatible = "xlnx,zocl";
                                status = "okay";
                                reg = <0x0 0xA0000000 0x0 0x10000>;
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
