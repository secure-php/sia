#!/bin/sh

# Copyright (c) 2018, Cyberhaven
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

# This script builds the CGC samples and places the non-patched binaries in the
# specified directory. You must run this script from the samples' root directory.
#
# This script requires GNU Parallel.
#
# You can also run this script in the linux-build-i386cgc docker image. You will have this image
# if you build the S2E VM images. Refer to https://github.com/S2E/guest-images for details.
#
# Assuming your S2E root dir is in $S2EDIR, the following commands will build the samples:
#
# cd $S2EDIR
# git clone https://github.com/CyberGrandChallenge/samples.git
# cd samples
# docker run -ti --rm -w $(pwd) -v $HOME:$HOME linux-build-i386cgc /run_as.sh $(id -u) $(id -g) \
#      $S2EDIR/s2e/decree/scripts/build-cgc-samples.sh $S2EDIR/decree/samples
#
# When docker run completes, the binaries will be in the $S2EDIR/decree/samples folder.

if [ $# -lt 1 ]; then
    echo "Usage: $0 target_folder [make arguments...]"
    exit 1
fi

TARGET_DIR="$1"
shift

MAKE_ARGS=build

if [ $# -gt 0 ]; then
    MAKE_ARGS="$*"
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "$TARGET_DIR does not exist"
    exit 1
fi

export NO_CB_EXTENDED_APP=1

parallel make -C {} $MAKE_ARGS ::: examples/* cqe-challenges/*

for d in examples cqe-challenges; do
    cp $d/*/bin/* $TARGET_DIR
    (cd "$TARGET_DIR" && rm -f *patched*)
done
