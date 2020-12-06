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
cat $1 | cut -d'	' -f2 | parallel -j $NUM_PROCESSES --progress --joblog joblog --resume --resume-failed curl --max-time 10 --silent --output $OUTPUT_DIR{#} {}

# Remove non-image files
FAILED_DOWNLOADS_COUNT=$(find $OUTPUT_DIR -type f | xargs file | grep -v image | cut -d: -f1 | wc -l)
find $OUTPUT_DIR -type f | xargs file | grep -v image | cut -d: -f1 | xargs rm

echo "Download finished with $FAILED_DOWNLOADS_COUNT failed URLs"
