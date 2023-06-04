APP :=  $(basename $(app:app/%=%))
APP :=  $(basename $(APP:%/=%))


FREQ := 300

EXECUTABLE := $(APP).app
BUILD_DIR := ./build_dir_$(APP)
TEMP_DIR := ./_x_$(APP)

DEFAULT_CFG  = app/$(APP)/kernel.cfg

include src/data_struct/Makefile
include app/$(APP)/kernel.mk


CFG_FILE ?= app/$(APP)/kernel.cfg