#! /usr/local/bin/bash

# For Regex ecplanation please read the README.md

iniFile=$1

bashVersion=$(echo $BASH_VERSION | cut -d'.' -f1)

if [[ $bashVersion -lt 4 ]]; then
    echo "You need at least bash v4 to use this script. Current bash version: $BASH_VERSION"
    exit 1
fi

conf=$(sed -E -e 's/^[[:blank:]]*#.*//g' \
            -e 's/^[[:blank:]]*;.*//g' \
            -e '/^$/d' \
            -e '/^[[:blank:]]*$/d' \
            -e 's/[[:blank:]]*=[[:blank:]]*/=/g' \
            -e 's/^[[:blank:]]*//g' \
            -e 's/[[:blank:]]*$//g' \
            -e 's/\"/\\"/g' \
            -e 's/(^[^=]*)(=.*)/\[\1\]\2/g' \
            -e 's/([^=]=)(.*)/\1\"\2\"/' \
            -e 's/^\[(.*)\]$/); declare -A \1=(/g' \
            -e '/=/!d' \
            < $iniFile)

conf=$(echo $conf | sed 's/^); //')  # Remove the unecessary 1st ';)' character. Couldn't make it work within the main command for some reasons
conf=$conf' )'

eval $conf
