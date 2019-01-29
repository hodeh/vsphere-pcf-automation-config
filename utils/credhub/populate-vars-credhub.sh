#!/usr/bin/env bash

# Script Used to populate paramters listed under ((foundation))/config/*.yml credhub instance.
# Script expects to be run in an enviroment that is populated with credhub credentials , like (bucc env)
# Script expects a properties file to be populated

set -eu
set -o pipefail
[[ -z "${DEBUG:-""}" ]] || set -x



if [ $#  -lt 2 ] || [ ! -f $2 ]; then
    echo " #1-foundation name, #2-input properties must present as arguments in the sequence mentioned"
    exit 1

fi

if [ -z "$(which credhub)" ]; then
    echo "ERROR: Credhub CLI is missing"
    echo "Please download credhub from:"
    echo "https://github.com/cloudfoundry-incubator/credhub-cli/releases"
    exit 1
fi

while IFS='=' read -r key val; do
    [[ $key = '#'* ]] && continue
        if [ ! -z "$key" ] && [ ! -z "$val" ]; then
            echo "/$1/$key"="$val"
        fi            
        
done < $2


read -p "Generating/Overwriting Automation Keys, Are you sure?" -n 1 -r
if [[ $REPLY =~ ^[Yy]$ ]]
echo
then
    while IFS='=' read -r key val; do
        [[ $key = '#'* ]] && continue
            if [ ! -z "$key" ] && [ ! -z "$val" ]; then
                credhub set -n "/$1/$key" -t value -v "$val"
            fi            
           
    done < $2
fi
