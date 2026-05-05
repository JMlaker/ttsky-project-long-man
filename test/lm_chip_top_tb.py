# SPDX-FileCopyrightText: © 2024 Tiny Tapeout
# SPDX-License-Identifier: Apache-2.0

import random
import itertools
import cocotb
from cocotb.clock import Clock
from cocotb.triggers import ClockCycles
from cocotb.triggers import FallingEdge, RisingEdge, Timer
from cocotb.regression import TestFactory  

# GLOBALs
WIDTH = 16
_initialization = True
_rx_state = 0  # Needs to be shared between async busses

async def init(dut, clk_ns):
    dut.rst_n.value = 0
    clock = Clock(dut.clk, clk_ns,  unit="ns")
    cocotb.start_soon(clock.start());
    dut.RDY.value = 0
    dut.LOAD.value = 0
    dut.DBG_ADDR.value = 0
    dut.SCLK.value = 1
    dut.MOSI.value = 0
    dut.CAPTURE.value = 0
    await ClockCycles(dut.clk, 32);
    # release reset
    dut.rst_n.value = 1
    await ClockCycles(dut.clk, 32);

async def send_data(dut, data):
    print("Sending data: 0x" + "{:04X}".format(data))
    for i in range(WIDTH):
        dut.SCLK.value = 1;
        dut.MOSI.value = (data >> i) & 0x1
        await ClockCycles(dut.clk, 12);
        # make data sample
        dut.SCLK.value = 0;
        await ClockCycles(dut.clk, 12);

    dut.SCLK.value = 1;

async def receive_data(dut):
    val = 0
    for i in range(WIDTH):
        dut.SCLK.value = 0;
        await ClockCycles(dut.clk, 12);
        dut.SCLK.value = 1;
        await ClockCycles(dut.clk, 12);
        val |= (int(dut.MISO.value) << (i))
    return val

################################# TESTS #################################
# DATA = [0xB00F, 0xDEAD, 0x1234]
# CLOCKS = [16, 63, 125, 250, 500, 1000]  # 62.5 MHz to 1 MHz
# DELAYS = [1, 10, 100, 1000]  # 1 ns to 1 us
CLOCKS = [16, 32, 256, 1000]  # 62.5 MHz to 1 MHz
DELAYS = [1,5,10]  # 1 ns to 1 us
LINE_DELAYS = list(set(itertools.product(DELAYS, repeat=4)))
LINE_DELAYS = LINE_DELAYS[0:len(LINE_DELAYS)//4]

async def update_tx(dut, linenum, delay):
    sig = getattr(dut, f"TX{linenum}")
    while True:
        await sig.value_change
        val = sig.value
        await Timer(delay, unit="ns")
        getattr(dut, f"RX{linenum}").value = val

async def update_ack(dut, delay):
    while True:
        await dut.RX_ACK.value_change
        val = dut.RX_ACK.value
        await Timer(delay, unit="ns")
        dut.TX_ACK.value = val

@cocotb.parametrize(
    clk_ns=CLOCKS,
    tx_delays_ns=LINE_DELAYS,
    ack_delay_ns=DELAYS
)
async def loopback_test(dut, clk_ns, tx_delays_ns, ack_delay_ns):
    for i in range(4):
        cocotb.start_soon(update_tx(dut, i, tx_delays_ns[i]))
    cocotb.start_soon(update_ack(dut, ack_delay_ns))
    DATA = [random.randint(0, 0xFFFF) for _ in range(10)]
    await init(dut, clk_ns);
    for data in DATA:
        await send_data(dut, data)
        await ClockCycles(dut.clk, 5)
        dut.LOAD.value = 1;
        await ClockCycles(dut.clk, 5)
        dut.LOAD.value = 0;

        while(dut.VLD.value == 0):
            await ClockCycles(dut.clk, 1)

        # read it
        await ClockCycles(dut.clk, 5)
        dut.CAPTURE.value = 1
        await ClockCycles(dut.clk, 5)
        dut.CAPTURE.value = 0
        await ClockCycles(dut.clk, 5)

        val = await receive_data(dut)

        assert val==data

        # Return ack
        dut.RDY.value = 1
        await ClockCycles(dut.clk, 5)
        dut.RDY.value = 0
        await ClockCycles(dut.clk, 5)

