#!/bin/bash
middle() { local s=$1 c=$2; shift 2; sed -n "$s,$(($s + $c -1))p; $(($s + $c))q" "$@"; }

middle $1 $2 $3
