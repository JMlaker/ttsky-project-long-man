# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# FST ?= -fst # Use more efficient FST format # Doesn't seen to be working
# defaults
SIM ?= icarus
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../src/*

ifneq ($(GATES),yes)

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(wildcard $(SRC_DIR)/*.sv)
COMPILE_ARGS	  += -D SIM

else

COCOTB_TEST_FILTER        = gate_level

NETLIST_SRC     = $(PWD)/../runs/wokwi/final/pnl
PDK_ROOT        ?= ~/.ciel/ciel/sky130/versions/8afc8346a57fe1ab7934ba5a6056ea8b43078e71/

SIM_BUILD				= sim_build/gl

SDF_FILE        ?= $(wildcard $(PWD)/../runs/wokwi/final/sdf/nom_tt_*/*.sdf)

# Gate level simulation:
ifeq ($(SIM),icarus)

COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DSIM
COMPILE_ARGS    += -DUNIT_DELAY=\#1

VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

else ifeq ($(SIM),questa)

COMPILE_ARGS    += -suppress 2892
COMPILE_ARGS    += -suppress 13522
COMPILE_ARGS    += -suppress 2912
COMPILE_ARGS    += -suppress 2685
COMPILE_ARGS    += -suppress 2718
# SIM_ARGS    += +pulse_e/0
# SIM_ARGS    += +pulse_r/0
SIM_ARGS    += -sdftyp /iDUT=$(SDF_FILE)
VERILOG_SOURCES += $(wildcard $(NETLIST_SRC)/*.v)

endif

VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/primitives.v
VERILOG_SOURCES += $(PDK_ROOT)/sky130A/libs.ref/sky130_fd_sc_hd/verilog/sky130_fd_sc_hd.v


endif

# Allow sharing configuration between design and testbench via `include`:
VERILOG_INCLUDE_DIRS += $(SRC_DIR)

# Include the testbench sources:
VERILOG_SOURCES += $(wildcard *_tb.sv)
TOPLEVEL = $(basename $(wildcard *_tb.sv))

$(info TOPLEVEL=$(TOPLEVEL))

# List test modules to run, separated by commas and without the .py suffix:
COCOTB_TEST_MODULES = $(TOPLEVEL)

# include cocotb's make rules to take care of the simulator setup
include $(shell cocotb-config --makefiles)/Makefile.sim

waves:
	gtkwave $(TOPLEVEL).vcd >/dev/null 2>&1 &

