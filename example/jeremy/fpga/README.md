# Verilog Ethernet Custom board (Kintex XC7K160TFFG676-2) Example Design

## Introduction

The design by default listens to UDP port 1234 at IP address 192.168.13.128 and
will echo back any packets received.  The design will also respond correctly
to ARP requests. ICMP ping does not work.

*  FPGA: xc7k160tffg676-2
*  PHY: 10G BASE-R PHY IP core and internal GTH transceiver

Tested with

* A custom board with the xc7k160t
* 10GTek 10GBase-SR (850nm MM) SFP+ module
* 50MHz LVCMOS33 system clock (converted to 125MHz with MMCM)
* 156.25MHz MGT reference clock (this exact frequency is required by the PCS/PMA) - Mouser part number `520-E2LMV7CN156250TR`
* SFP connected to MGT bank 115, transceiver 3 (X0Y3)
* Mellanox ConnectX-3 with the same 10GTek SFP+ module

## How to build

Run make to build.  Ensure that the Xilinx Vivado toolchain components are
in PATH.  

## How to test

Run make program to program the board with Vivado.  Then run

    netcat -u 192.168.1.128 1234

to open a UDP connection to port 1234.  Any text entered into netcat will be
echoed back after pressing enter.

It is also possible to use hping to test the design by running

    hping 192.168.1.128 -2 -p 1234 -d 1024
