# ASIC Flow Digital IC Design Project

This repository contains a comprehensive digital IC design project based on the ASIC flow, including key components such as RTL design, synthesis, and verification.

## Block Diagram
![Final_SYS_Block_Diagram](https://github.com/user-attachments/assets/0b613801-0efb-43ed-a6f8-789bda7c86f0)

## Project Overview

- **Clock Domain 1 (REF_CLK):**
  - RegFile
  - ALU
  - Clock Gating
  - SYS_CTRL

- **Clock Domain 2 (UART_CLK):**
  - UART_TX
  - UART_RX
  - PULSE_GEN
  - Clock Dividers

- **Data Synchronizers:**
  - RST Synchronizer
  - Data Synchronizer
  - ASYNC FIFO

## Key Features

- **ALU Operations:** Addition, Subtraction, Multiplication, Division, AND, OR, NAND, NOR, XOR, XNOR, CMP, and Shift operations.
- **Register File Operations:** Write and read capabilities with specific command frames.
- **System Specifications:** REF_CLK at 50 MHz, UART_CLK at 3.6864 MHz, and always-on clock divider.

## Sequence of Operation

1. Perform configuration via Register File write operations.
2. Master sends various commands (RegFile and ALU operations).
3. Commands are processed by SYS_CTRL after reception through UART_RX.
4. Results are sent back to the master via UART_TX.

---

This README provides a brief overview of the project's structure and key functionalities.
