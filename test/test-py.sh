#!/bin/bash

# set -e

BASEPATH=$(dirname $0)

for f in $(ls $BASEPATH/*.in)
do
    echo "Test running: $f"
    OUTFILE="$(echo $f | sed -e 's/in/out/')"
    TESTFILE="$(echo $f | sed -e 's/in/my/')"
    python3 $BASEPATH/../src/hash.py < $f > $TESTFILE
    diff -u $OUTFILE $TESTFILE
done

rm $BASEPATH/*.my