#!/bin/bash

# START
set -e

# VARIABLES
NAME_OSX="Darwin"
THIS_OS=$(uname -mrs)
PROGNAME=$(basename $0)
CONFIG=($HOME/.maza/)
HOST_FILE=(/etc/hosts)
COLOR_RED=`tput setaf 1`
COLOR_GREEN=`tput setaf 2`
COLOR_RESET=`tput sgr0`
LIST="list"
LIST_DNSMASQ="dnsmasq.conf"
START_TAG="## MAZA - List ad blocking"
PROJECT="### https://github.com/tanrax/maza-ad-blocking"
AUTHOR="### Created by Andros Fenollosa (https://programadorwebvalencia.com/)"
END_TAG="## END MAZA"


# Create sed cross system
custom-sed() {
    if [[ $THIS_OS = *$NAME_OSX* ]]; then
        # Check if OSX and install GSED
        if [ -x "$(command -v gsed)" ]; then
            gsed "$@"
        else
            echo "${COLOR_RED}ERROR. You must install gsed if you are using OSX${COLOR_RESET}"
            exit 1
        fi
    else
        # Linux
        sed "$@"
    fi
}
export -f custom-sed


# FUNCTIONS

## HELP
usage() {
    if [ "$*" != "" ] ; then
        echo "Error: $*"
    fi

    cat << EOF
Usage: $PROGNAME [OPTION]
Simple and efficient local ad blocking throughout the network.

Options:
status       Check if it's active or not
update       Update the list of DNS to be blocked
start        Activate blocking DNS.
stop         Stop blocking DNS.
--help       Display this usage message and exit
EOF

    exit 1
}

status() {
    if grep -qF "$START_TAG" "$HOST_FILE";then
        echo "${COLOR_GREEN}ENABLED${COLOR_RESET}"
    else
        echo "${COLOR_RED}DISABLED${COLOR_RESET}"
    fi
}

update() {
    # Make conf folder
    rm -f $CONFIG$LIST
    rm -f $CONFIG$LIST_DNSMASQ
    mkdir -p $CONFIG
    # Download DNS list
    curl -L -s "https://pgl.yoyo.org/adservers/serverlist.php?showintro=0&mimetype=plaintext" -o "$CONFIG$LIST"
    # Clear list
    ## Remove comments
    custom-sed -i.bak '/^#/ d' "$CONFIG$LIST"
    # Make dnsmasq format
    ## 127.0.0.1 doubleclick.net to address=/doubleclick.net/127.0.0.1
    cp "$CONFIG$LIST" "$CONFIG$LIST_DNSMASQ"
    custom-sed -i.bak 's/127.0.0.1 /address=\//g' "$CONFIG$LIST_DNSMASQ"
    custom-sed -i.bak 's/$/\/127.0.0.1/g' "$CONFIG$LIST_DNSMASQ"
    ## Add start tag DNS list in first line
    custom-sed -i.bak "1i\\$AUTHOR" "$CONFIG$LIST"
    custom-sed -i.bak "1i\\$PROJECT" "$CONFIG$LIST"
    custom-sed -i.bak "1i\\$START_TAG" "$CONFIG$LIST"
    ## Add end tag DNS list in first line
    echo $END_TAG >> "$CONFIG/$LIST"
    ## Add start tag DNS dnsmasq in first line
    custom-sed -i.bak "1i\\$AUTHOR" "$CONFIG$LIST_DNSMASQ"
    custom-sed -i.bak "1i\\$PROJECT" "$CONFIG$LIST_DNSMASQ"
    custom-sed -i.bak "1i\\$START_TAG" "$CONFIG$LIST_DNSMASQ"
    ## Add end tag DNS DNSMASQ in first line
    echo $END_TAG >> "$CONFIG$LIST_DNSMASQ"
    # Remove temp file
    rm "$CONFIG$LIST.bak"
    rm "$CONFIG$LIST_DNSMASQ.bak"
    # Notify user
    echo "${COLOR_GREEN}List updated!${COLOR_RESET}"
}

start() {
    update
    # Add List to host file
    cat "$CONFIG/$LIST" >> "$HOST_FILE"
    # Notify user
    echo "${COLOR_GREEN}ENABLED!${COLOR_RESET}"
}

stop() {
    # Remove list to host file
    custom-sed -i "/$START_TAG/,/$END_TAG/d" "$HOST_FILE"

    # Remove DNSMASQ
    cat /dev/null > $CONFIG$LIST_DNSMASQ

    # Notify user
    echo "${COLOR_GREEN}DISABLED!${COLOR_RESET}"
}

# CONTROLE ARGUMENTS
isArg=""

while [ $# -gt 0 ] ; do
    case "$1" in
    --help)
        usage
        ;;
    status)
        isArg="1"
        status
        ;;
    update)
        isArg="1"
        update
        ;;
    start)
        isArg="1"
        start
        ;;
    stop)
        isArg="1"
        stop
        ;;
    *)
    esac
    shift
done

if [ -z $isArg ] ; then
    usage "Not enough arguments"
fi
