## 1. Purpose
Design a parameterized UART register block that configures UART operating modes, baud rate, status flags, and error handling. The block emphasizes clean RTL, scalability, and automation readiness. It provides interface between Host (ex. CPU) and the UART system in order for the Host to configure some UART parameters such Enable, Baud Rate, Mode and observe UART errors such as parity.

![Alt text](https://github.com/mwael2002/UART-register-file/blob/main/Screenshot%202026-05-23%20141217.png)

## 2. Directory content
### docs: Hardware Design Document (HDD) and Verification plan
### rtl: Design code written in systemverilog
### tb: Testbench code
### scripts: Tcl scripts for running regression
### results: Coverage reports and log files of all regression tests


