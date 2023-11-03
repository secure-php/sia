#!/bin/bash

# Copyright (c) 2017 Dependable Systems Laboratory, EPFL
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

# Check a Decree proof of vulnerability (POV)

# Check command-line arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <CB> <POV>"
    echo ""
    echo "Where:"
    echo "    CB    - Path to a challenge binary"
    echo "    POV   - Path to an XML POV"
    exit 1
fi

CB=$1
POV=$2
CLANG="/usr/i386-linux-cgc/bin/clang"
LD="/usr/i386-linux-cgc/bin/ld"

# Convert XML to C
pov-xml2c -x ${POV} > "${POV}.c"

# Compile the POV
${CLANG} -c -nostdlib -fno-builtin -nostdinc -I/usr/include -O0 -g -Werror -Wno-overlength-strings -Wno-packed  \
    -o "${POV}.o" "${POV}.c"
${LD} -nostdlib -static -o "${POV}.pov" "${POV}.o" -L/usr/lib -lcgc -lpov

# Test!
chmod +x ${CB}
cb-test --directory "$(pwd)" --xml "${POV}.pov" --should_core --cb ${CB}
