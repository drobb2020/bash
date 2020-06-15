#!/bin/bash

# Script to automatically timestamp new patches in all repositories

for r in 937 121 468 238 564 708 719 243 16 195 129 130 60 804 867 552 548 362 134
  do
    smt staging createrepo $r -t
    smt staging createrepo $r -p
  done

exit 1

