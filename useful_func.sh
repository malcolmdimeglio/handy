#! /usr/bin/bash

#2D-array Associative:Classic (Must be Bash v4+)

AGE=1
ADDRESS=2
OTHER=3

declare -A JOHN=(
    [$AGE]=25
    [$ADDRESS]='P. Sherman, 42 Wallaby Way, Sydney'
    [$OTHER]='Some information'
)
declare -A MIKE=(
    [$AGE]=32
    [$ADDRESS]='21 Jump Street'
    [$OTHER]='Some other information'
)

declare -A Person=(
    [John]=JOHN[@]
)
Person+=([Mike]=MIKE[@])

# Be careful when slicing the index starts at 1 and not 0
echo ${!Person[John]:$ADDRESS:1}
echo ${!Person[Mike]:$AGE:1}
