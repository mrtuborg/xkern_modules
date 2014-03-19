TMP_DIR:=.tmp
REPO_URL?=git://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
SOURCES_DIR=$(PWD)
 
export CC:=$(CROSS_COMPILE)gcc
export LD:=$(CROSS_COMPILE)gcc
export AR:=$(CROSS_COMPILE)ar
export RANLIB:=$(CROSS_COMPILE)ranlib

ifdef KDIR
	WORKTREE_DIR:=$(PWD)/$(KDIR)
	REPO_BRANCH?=$(shell git --git-dir=$(KDIR)/.git rev-parse --abbrev-ref HEAD 2> /dev/null)
all: define-vars check-vars .build
else
	WORKTREE_DIR:=$(PWD)/$(TMP_DIR)/linux
	REPO_BRANCH?=master
all:  define-vars check-vars .default_repo_dir .build
endif

.PHONY: define-vars
define-vars:
	$(eval export CROSS_DUMPMACHINE:=$(shell $(CC) -dumpmachine))
	$(eval export ARCH:=$(shell echo $(CROSS_DUMPMACHINE) | awk '{split($$1,a,"-");print a[1]}'))
	$(eval export TARGET_CORE:=$(shell echo $(CROSS_DUMPMACHINE) | awk '{split($$1,a,"-");print a[2]}'))
	$(eval export COMPILER_VERSION:=$(shell $(CC) -v 2>&1 | tail -1 | awk '{ print $$3 }'))
	$(eval export TARGET_CPU:=$(shell echo $(ARCH)))
	$(eval export OS_VER=$(shell uname -r | awk '{split($$1,a,"-");print a[1]}' |  awk '{split($$1,a,".");print a[1],".",a[2]}' | sed 's/ //g'))
	$(eval export OS_TYPE=$(shell uname ))

PHONY: check-vars
check-vars:
	$(info )
	$(info ------------------------------------)
	$(info TARGET_CPU: $(TARGET_CPU))
	$(info ARCH: $(ARCH))
	$(info CROSS_COMPILE: $(CROSS_COMPILE))
	$(info TARGET_CORE: $(TARGET_CORE))
	$(info REPO_DIR: $(WORKTREE_DIR))
	$(info REPO_BRANCH: $(REPO_BRANCH))
	$(info OS_VER: $(OS_VER))
	$(info OS_TYPE: $(OS_TYPE))
	$(info ------------------------------------)
	$(info )

.default_repo_dir:
	$(shell mkdir -p $(TMP_DIR))
	$(shell mkdir -p $(WORKTREE_DIR))
	$(shell git clone --branch $(REPO_BRANCH) $(REPO_URL) $(WORKTREE_DIR))
	$(shell git --work-tree=$(WORKTREE_DIR) --git-dir=$(WORKTREE_DIR)/.git checkout v$(OS_VER))
	touch .default_repo_dir

.build_os_repo:
	$(MAKE) -C $(WORKTREE_DIR) ARCH=$(ARCH) oldconfig
	$(MAKE) -C $(WORKTREE_DIR) ARCH=$(ARCH) prepare
	$(MAKE) -C $(WORKTREE_DIR) ARCH=$(ARCH)
	touch .build_os_repo



.PHONY: distclean
.build: .build_os_repo
	mkdir -p target/$(OS_TYPE)
	$(MAKE) -C $(OS_TYPE) KDIR=$(WORKTREE_DIR) SRC=$(PWD)/$(OS_TYPE)
	$(MAKE) -C $(OS_TYPE) DESTDIR=$(PWD)/target/$(OS_TYPE) install
	touch .module.$(OS_TYPE)
distclean: define-vars
	$(MAKE) -C $(OS_TYPE) distclean
	@rm -rf .default_repo_dir .build_os_repo .module.$(OS_TYPE)
