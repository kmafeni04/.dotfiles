#!/usr/bin/env bash

set -ex

tmpfile=$(mktemp)
terminator -x lf -selection-path $tmpfile
cat $tmpfile
rm -rf $tmpfile
