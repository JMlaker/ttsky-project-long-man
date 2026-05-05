# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

# FST ?= -fst # Use more efficient FST format # Doesn't seen to be working
TOPLEVEL_LANG ?= verilog
SRC_DIR = $(PWD)/../../src/*

ifneq ($(GATES),yes)

# defaults
SIM ?= icarus

# RTL simulation:
SIM_BUILD				= sim_build/rtl
VERILOG_SOURCES += $(wildcard $(SRC_DIR)/*.sv)
COMPILE_ARGS	  += -D SIM

else

SIM ?= questa

NETLIST_SRC     = $(PWD)/../../runs/wokwi/final/pnl
PDK_ROOT        ?= ~/.ciel/ciel/sky130/versions/8afc8346a57fe1ab7934ba5a6056ea8b43078e71/

SIM_BUILD				= sim_build/gl

SDF_FILE        ?= $(PWD)/../../runs/wokwi/final/sdf/nom_tt_*/*.sdf

# Gate level simulation:
ifeq ($(SIM),icarus)

COMPILE_ARGS    += -DGL_TEST
COMPILE_ARGS    += -DFUNCTIONAL
PLUSARGS        += -sdf-verbose
COMPILE_ARGS    += -gspecify
COMPILE_ARGS    += -ginterconnect
COMPILE_ARGS    += -T typ
COMPILE_ARGS    += -DUSE_POWER_PINS
COMPILE_ARGS    += -DUNIT_DELAY=\#1

# this gets copied in by the GDS action workflow
COMPILE_ARGS	  += -DGATES
PLUSARGS        += +SDF_FILE=$(SDF_FILE)
# COMPILE_ARGS    += -sdf-typ $(SDF_FILE)

else ifeq ($(SIM),questa)

COMPILE_ARGS    += -suppress 2892
COMPILE_ARGS    += -suppress 13522
COMPILE_ARGS    += -suppress 2912
# SIM_ARGS    += +pulse_e/0
# SIM_ARGS    += +pulse_r/0
SIM_ARGS    += -sdftyp /iDUT=$(SDF_FILE)

endif

VERILOG_SOURCES += $(wildcard $(NETLIST_SRC)/*.v)
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
