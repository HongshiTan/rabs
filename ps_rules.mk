
mkfile_path := $(abspath $(lastword $(filter-out $(lastword $(MAKEFILE_LIST)), $(MAKEFILE_LIST))))
subdir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

temp_dir:=   $(dir  $(patsubst %/,%, $(dir $(mkfile_path))))
upperdir := $(notdir $(patsubst %/,%,$(dir $(temp_dir))))

UPPER_DIR := $(upperdir)


include  mk/base/base_hls_rules.mk
include  mk/base/base_rtl_rules.mk

unexport subdir
unexport temp_dir
unexport upperdir