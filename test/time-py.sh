#!/bin/bash

# set -e

BASEPATH=$(dirname $0)

for input in $(ls $BASEPATH/time/*.txt); 
do
    echo "# Current file: $input"
    for ((i=1;i<=10;i++));
    do
        cat $input | /usr/bin/time -f "%e" python3 $BASEPATH/../src/hash.py > lixo
    done
done

rm $BASEPATH/../lixo