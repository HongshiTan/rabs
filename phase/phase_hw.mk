############################## Setting up Kernel Variables ##############################
# Kernel compiler global settings
VPP_FLAGS += -t $(TARGET) --platform $(DEVICE) --save-temps
ifneq ($(TARGET), hw)
	VPP_FLAGS += -g
endif

VPP_FLAGS += -I ./src/ --vivado.param general.maxThreads=32 --vivado.synth.jobs 32
VPP_FLAGS += --remote_ip_cache  ./.rabs_ipcache

# Kernel linker flags
VPP_LDFLAGS += --kernel_frequency $(FREQ)
VPP_LDFLAGS += --vivado.param general.maxThreads=32  --vivado.impl.jobs 32 --config ${DEFAULT_CFG}

$(BUILD_DIR)/kernel.xsa: $(BINARY_CONTAINER_OBJS) $(AIE_CONTAINER_OBJS)
	v++ -l $(XOCCLFLAGS) --config xclbin_overlay.cfg -o $@ $^


.PHONY: xo
xo: $(BINARY_CONTAINER_OBJS)
	@echo "build all xo:" $(BINARY_CONTAINER_OBJS)


############################## Setting Rules for Binary Containers (Building Kernels) ##############################
$(BUILD_DIR)/kernel.xclbin:  $(BINARY_CONTAINER_OBJS) $(AIE_CONTAINER_OBJS)
	@echo $(BINARY_CONTAINER_OBJS)
ifeq ($(__AIE_SET__), true)
	$(VPP) $(VPP_FLAGS) -l $(VPP_LDFLAGS) --temp_dir $(TEMP_DIR)  -o'$(BUILD_DIR)/kernel.xsa' $(BINARY_CONTAINER_OBJS) $(AIE_CONTAINER_OBJS)
	$(VPP) -p $(BUILD_DIR)/kernel.xsa $(AIE_CONTAINER_OBJS) --temp_dir $(TEMP_DIR)  -t $(TARGET) --platform $(DEVICE) -o $(BUILD_DIR)/kernel.xclbin  --package.out_dir $(PACKAGE_OUT)  --package.boot_mode=ospi

else ifeq ($(__PL_SET__), true)
	$(VPP) $(VPP_FLAGS) -l $(VPP_LDFLAGS) --temp_dir $(TEMP_DIR)  -o'$(BUILD_DIR)/kernel.link.xclbin' $(BINARY_CONTAINER_OBJS)
	$(VPP) -p $(BUILD_DIR)/kernel.link.xclbin --temp_dir $(TEMP_DIR) -t $(TARGET) --platform $(DEVICE) --package.out_dir $(PACKAGE_OUT) -o $(BUILD_DIR)/kernel.xclbin
else

endif

	cp $(TEMP_DIR)/reports/link/imp/impl_1_full_util_routed.rpt    ${BUILD_DIR}/report/  | true
	cp $(TEMP_DIR)/reports/link/imp/impl_1_kernel_util_routed.rpt  ${BUILD_DIR}/report/  | true
	cat $(TEMP_DIR)/link/vivado/vpl/runme.log |  grep scaled\ frequency >   ${BUILD_DIR}/clock.log | true





.PHONY: build
build: check-vitis  $(BINARY_CONTAINERS)

.PHONY: xclbin
xclbin: build


