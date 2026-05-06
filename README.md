![](../../workflows/gds/badge.svg) ![](../../workflows/docs/badge.svg) ![](../../workflows/test/badge.svg) ![](../../workflows/fpga/badge.svg)

# Project Long Man: A Quasi-Asyncronous Die-to-Die Interconnect
This repository holds everything required for submission to Tiny Tapeout's SKY130 shuttle.

For the upstream development repo, see [Michael0x18/ECE755_ProjectLM](https://github.com/Michael0x18/ECE755_ProjectLM).

## Overview
The core of the project is a quasi-asyncronous interconnect that would allow 16 bits of data to transfer 2 bits at a time between two dies, regardless of clock domains. At the Tiny Tapeout clock limit of 66 MHz, this interconnect would out preform any standard serial communication in terms of clock cycles till completion.

Each asyncronous transactions decodes 2 bits into a one-hot signal, which toggles its respective TX line. Once the RX side receives a transition on a line, it send encodes the transitioned line back into a 2 bit value and sends an ACK pulse back to the TX side. After the TX recieves the ACK, it send the next 2 bits. This repeats for a total of 8 transactions for a total of 16 bits. On the final transaction, the RX hold the ACK until an external signal is asserted.

Built into the design a simple SPI interface to send the data into the TX side and read out of the RX side simultaneously.

Additionally, the UIO pins are dedicated debug pins to test certain signals after tapeout.

## Asynchronous Logic
Instead of standard NULL convention where the TX and RX lines go low after each transaction, we instead read toggles on each line as a representation of new data. This essentially halves the switching rate of the TX-RX lanes with some minor added logic on the decoder and encoder.

As an example, observe the following transaction:
- T=time : TX-RX data   : decoded value
- T=0    : `4'b0110`    : `X`
- T=1    : `4'b1110`    : `2'b11`
- T=2    : `4'b1100`    : `2'b01`
- T=3    : `4'b1100`    : `X`

## Usage
As we are only taping out a single unit on 1 tile, we will be tying the TX and RX side together so that any data that gets sent into the chip should be the same as the data sent out.

The SPI interface would require and external controller. It uses the standard SCLK, MOSI, and MISO pins, activating the interface when SCLK starts.

After reset, hold the CAPTURE line high. Data should then be streamed in over the MOSI line. After 16 bits have been sent, the LOAD line should be pulsed which starts the asynchronous transaction. Once all 16 bits have been sent, the RX side will assert VLD, letting you drop the CAPTURE line and stream the RX data over the MISO and (and new TX data at the same time if desired). Once the data has been read, pulse the RDY signal to finish the transaction, reassert the CAPTURE line, and repeat.

## Pinout
- `UI[3:0]`  : `RX[3:0]` : One-hot encoded asyncronous RX signal
- `UI[4]`    : `TX_ACK`  : Acknowledge line for the TX side
- `UI[5]`    : `LOAD`    : Load the SPI data into the TX side
- `UI[6]`    : `RDY`     : Lets the RX side send the final ACK pulse
- `UI[7]`    : `MOSI`    : MOSI line for the SPI interface

- `UO[3:0]`  : `RX[3:0]` : One-hot encoded asyncronous TX signal
- `UO[4]`    : `RX_ACK`  : Acknowledge line for the RX side
- `UO[5]`    : `DONE`    : Asserted once the final ACK pulse has been recieved
- `UO[6]`    : `VLD`     : Asserted from RX side when final data has been recieved
- `UO[7]`    : `MISO`    : MISO line for the SPI interface

- `UIO[3:0]` : `DBG_ADDR[3:0]` : Debug address input
- `UIO[4]`   : `UNUSED`  : 
- `UIO[5]`   : `DBG_OUT` : Debug output
- `UIO[6]`   : `SCLK`    : SCLK line for the SPI interface
- `UIO[7]`   : `CAPTURE` : Held high to capture RX value, held low when reading from MISO

## Motivation
We are students at the University of Wisconsin - Madison. This project was completed as a course project for ECE755: VLSI Systems Design. The goal of the course was to preform the VLSI flow for an eventual tapeout.

This project in particular was chosen more as an exploration in the asynchronous design space.

