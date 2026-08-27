
# base_rtl_kernel_rules.mk -- package RTL kernels FROM SOURCE, discovered the same
# way base_rtl_rules.mk discovers prebuilt *.xo. In this directory a kernel is a
# package_<name>.tcl plus the .sv it packages; each is built into <name>.xo. Drop a
# new kernel's sources + package_<name>.tcl in the dir and it is picked up
# automatically -- no per-kernel lists.

APP_DIR = $(subdir)

RTL_PKG_TCLS  = $(wildcard $(UPPER_DIR)/$(APP_DIR)/package_*.tcl)
RTL_PKG_NAMES = $(patsubst package_%.tcl,%,$(notdir $(RTL_PKG_TCLS)))
RTL_PKG_SRCS  = $(wildcard $(UPPER_DIR)/$(APP_DIR)/*.sv) $(wildcard $(UPPER_DIR)/$(APP_DIR)/*.svh)
APP_BINARY_CONTAINERS = $(patsubst %, $(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/%.xo, $(RTL_PKG_NAMES))

BINARY_CONTAINER_OBJS += $(APP_BINARY_CONTAINERS)
KERNEL_OBJS           += $(RTL_PKG_NAMES)
GENERATED_KERNEL_OBJS += $(APP_BINARY_CONTAINERS)

PROJECT_OBJS += $(UPPER_DIR)/$(APP_DIR)

VIVADO ?= vivado

# package_<name>.tcl (+ every .sv in the dir) -> <name>.xo
$(TEMP_DIR)/$(UPPER_DIR)/$(APP_DIR)/%.xo: $(UPPER_DIR)/$(APP_DIR)/package_%.tcl $(RTL_PKG_SRCS)
	@${ECHO} ${BLUE}"packaging RTL kernel $* in $(<D)"${NC}
	mkdir -p $(@D)
	cd $(@D) && $(VIVADO) -mode batch -notrace \
	    -source $(abspath $<) -tclargs $(abspath $@) ${__HLS_DEVICE__}
	@[ -f $@ ] || { ${ECHO} ${RED}"RTL kernel $* packaging failed"${NC}; exit 1; }

unexport APP_DIR
unexport RTL_PKG_TCLS
unexport RTL_PKG_NAMES
unexport RTL_PKG_SRCS
unexport APP_BINARY_CONTAINERS
