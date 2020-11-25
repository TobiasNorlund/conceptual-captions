#!/usr/bin/env bash

if ! test -f "$1"; then
    echo "ERROR: Input file '$1' does not exist (first argument)"
    exit 1
fi

if test -z "$2" ; then 
    echo "ERROR: No output dir set (second argument)"
    exit 1
fi

# Make sure output dir exists
OUTPUT_DIR="$2"
[[ "${OUTPUT_DIR}" != */ ]] && OUTPUT_DIR="${OUTPUT_DIR}/"
mkdir -p $2

# Download
NUM_PROCESSES=$(expr $(grep -c ^processor /proc/cpuinfo) \* 4)
cat $1 | cut -d'	' -f2 | parallel -j $NUM_PROCESSES --joblog joblog --bar --resume --resume-failed wget2 --tries 2 -T 5 -O $OUTPUT_DIR{#} -o /dev/null -A jpeg,jpg,bmp,gif,png {}

# Remove non-image files
FAILED_DOWNLOADS_COUNT=$(find $OUTPUT_DIR -type f | xargs file | grep -v image | cut -d: -f1 | wc -l)
find $OUTPUT_DIR -type f | xargs file | grep -v image | cut -d: -f1 | xargs rm

echo "Download finished with $FAILED_DOWNLOADS_COUNT failed URLs"
