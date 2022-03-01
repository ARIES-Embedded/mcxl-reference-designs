# MCXL Reference Designs

## Table Of Contents
1. Introduction
2. Reference Designs
3. License

## 1. Introduction

This repository provides reference design projects for the MCXL SoM (Cyclone 10 LP).
The designs implement the VexRiscv (open source RISC-V softcore) running FreeRTOS, as well as Intel Triple Speed Ethernet MAC and the SLL MBMC IP.
They can be used to evaluate the MCXL SoM or as starting point for development.

## 2. Reference Designs

Three Quartus projects are available, one for the MCXL-S (SDRAM variant) and two for the MCXL-H (HyperBus variant). All implement a RISC-V core with FreeRTOS, a UART core and GPIO routed to the PMod connectors and Gigabit Ethernet using the Intel TSE MAC. The **mcxl_h_ethernet** and **mcxl_s_ethernet** projects use only 128 KiB on-chip memory to provide RAM for the RISC-V core. The **mcxl_h_ethernet_hyperbus** project also implements the [SLL Hyperbus IP Core](https://synaptic-labs.com/sll-hyperbus-memory-controller-hbmc-ip/) available with a time-limited 30 minutes free trial license providing additional 32 MiB of HyperRAM and 128 MiB of HyperFlash.

## 3. License

The **MCXL Reference Designs** are released under the MIT License.  
The **SLL MBMC** HyperBus IP Core is available to ARIES customers as a time-limited trial version.
[VexRiscv](https://github.com/SpinalHDL/VexRiscv) is released under the MIT License.  
The [printf-library](https://github.com/eyalroz/printf) is released under the MIT License.
