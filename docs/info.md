<!---

This file is used to generate your project datasheet. Please fill in the information below and delete any unused
sections.

You can also include images in this folder and reference them in the markdown. Each image must be less than
512 kb in size, and the combined size of all images must be less than 1 MB.
-->

## How it works

1.	AXI Input Stage: AXI master asserts axis_valid with data on axis_data. When m_axis_ready is high, data is accepted and written to FIFO.

2.	FIFO Buffering: FIFO stores incoming bytes until the UART transmitter is ready to send. Read and write can occur simultaneously.

3.	UART Transmission:
•	Each byte is serialized at 115200 baud.
•	Start bit (0), data bits (8), parity bit, and stop bit (1) are sent.
•	tx_data_ready indicates when UART can accept new data.

4.	UART Reception:
•	Receiver detects start bit, samples bits at mid-baud intervals.
•	Extracts data, verifies parity, and asserts rx_valid.
•	If parity check fails, parity_err is asserted for one clock.

5.	Loopback Communication: The transmitted UART data (uart_tx) is internally connected to the receiver’s rx line, allowing full system verification.

## How to test

Explain how to use your project

## External hardware

List external hardware used in your project (e.g. PMOD, LED display, etc), if any
