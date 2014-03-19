# If KERNELRELEASE is defined, we've been invoked from the
# kernel build system and can use its language.
ifneq ($(KERNELRELEASE),)
    obj-m := module.o
    module-objs := task.o
# Otherwise we were called directly from the command
# line; invoke the kernel build system.
else
    KDIR ?= /lib/modules/$(shell uname -r)/build
    SRC := $(shell pwd)

default:
	$(MAKE) -C $(KDIR) M=$(SRC) modules

endif

install:
	cp *.ko $(DESTDIR)

distclean:
	@rm -rf .*.cmd *.o *.mod.c *.ko .tmp_versions Module.markers Module.symvers modules.order