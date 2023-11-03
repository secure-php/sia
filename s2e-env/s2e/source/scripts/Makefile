# Copyright (C) 2017-2020, Cyberhaven
# All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

BUILD_SCRIPTS_DIR?=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
REPO_DIR=$(BUILD_SCRIPTS_DIR)/../

# This is for S2E
BUILD_SCRIPTS_SRC=$(REPO_DIR)/s2e/scripts

include $(REPO_DIR)/s2e/Makefile
include $(REPO_DIR)/scripts/Makefile.qemu

# From https://stackoverflow.com/questions/4219255/how-do-you-get-the-list-of-targets-in-a-makefile
# Note that we have to list the targets from this makefile. Calling the list target inside
# $(REPO_DIR)/s2e/Makefile will return a partial list only for some reason.
list-s2e-targets:
	@$(MAKE) -pRrq -f $(REPO_DIR)/s2e/Makefile : 2>/dev/null |                                  \
		awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs

list-qemu-targets:
	@$(MAKE) -pRrq -f $(REPO_DIR)/scripts/Makefile.qemu : 2>/dev/null |                                  \
		awk -v RS= -F: '/^# File/,/^# Finished Make data base/ {if ($$1 !~ "^[#.]") {print $$1}}' | \
		sort | egrep -v -e '^[^[:alnum:]]' -e '^$@$$' | xargs
