## 1. Purpose
Design a parameterized UART register block that configures UART operating modes, baud rate, status flags, and error handling. The block emphasizes clean RTL, scalability, and automation readiness. It provides interface between Host (ex. CPU) and the UART system in order for the Host to configure some UART parameters such Enable, Baud Rate, Mode and observe UART errors such as parity.
## 2. Directory content
### docs: hardware design document (HDD) and Verification plan
### rtl: Design code written in systemverilog
### tb: testbench code
### scripts: tcl scripts for running regression
### results: log files of all regression tests
