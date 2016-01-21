#!/bin/bash

set -e

cd "$( dirname "${BASH_SOURCE[0]}" )"
pwd

find ../test/fixtures/export -name "*.bib" | while read bib
do
  ./compile.sh "$bib"
done
