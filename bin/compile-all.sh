#!/bin/bash

SCRIPTPATH=`pwd -P`
cd $SCRIPTPATH

find ../test/fixtures/export -name "*.bib" | while read bib
do
  ./compile.sh "$bib"
done
