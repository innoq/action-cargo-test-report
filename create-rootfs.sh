#!/bin/bash

#
# Copyright 2021 Daniel Bornkessel
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

help() {
    cat<<EOF

This script copies all given binaries and all it's dynamic dependencies into

/tmp/rootfs

creating a minimal, usable linux image. Pass the binaries you want to copy as arguments, i.e.:

    $0 /bin/busybox /usr/bin/jq

the paths of the passed in binaries will be preserved, i.e. /usr/bin/jq would be placed in
/tmp/rootfs/usr/bin/jq
EOF
}

: ${1:?"$(help)"}

rm -rf /tmp/{deps,new_deps,new_deps_tmp,rootfs}
while [ -n "$1" ]
do
    echo "$1" >> /tmp/deps
    shift
done

while ! diff /tmp/deps /tmp/new_deps &>/dev/null
do
  mv -f /tmp/new_deps /tmp/deps 2>/dev/null
  while read file
  do
    echo $file >> /tmp/new_deps_tmp

    # get '/lib/x86_64-linux-gnu/libresolv.so.2' from lines like:
    #         libresolv.so.2 => /lib/x86_64-linux-gnu/libresolv.so.2 (0x00007f325483c000)
    ldd $file |grep '=>'   |grep '/'|sed 's/^.*> //g;s/ (.*$//g' >> /tmp/new_deps_tmp

    # get '/lib64/ld-linux-x86-64.so.2' from lines like:
    #         /lib64/ld-linux-x86-64.so.2 (0x00007fa7cf80f000)
    ldd $file |grep -v '=>'|grep '/'|sed 's/^[ \t]*//g; s/(.*//g' >> /tmp/new_deps_tmp
  done < /tmp/deps
  cat /tmp/new_deps_tmp|sort|uniq|grep -v '^$' > /tmp/new_deps
done

mkdir -p /tmp/rootfs
while read file
do
  (set -x; install -Ds $file /tmp/rootfs${file})
done < <(cat /tmp/deps)
