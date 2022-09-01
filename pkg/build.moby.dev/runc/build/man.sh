#!/bin/sh

set -e

make man
cd man
for i in **/*; do
    if [ -f "${i}" ]; then
        gzip -9 "${i}"
    fi
done
for i in *; do
    if [ ! -d $i ]; then
        rm -f ${i}
    fi
done
