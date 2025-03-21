#!/bin/bash

SCRIPT_DIR="$(dirname $(realpath ${BASH_SOURCE[0]}))"
source "${SCRIPT_DIR}/../common.sh"

build

for lbs in 4 8 12; do
    srvs=$lbs
    for algo in rr sh dh; do    # round-robin, source-hashing, destination-hashing
        if [ "$algo" == "sh" ]; then
            repeat=$((srvs * 4))
        else
            repeat=$srvs
        fi
        ${CONFGEN[*]} -l $lbs -s $srvs -a $algo -r $repeat > "$CONF"
        for procs in 1 4 8 16; do
            name="$lbs-lbs.$srvs-servers.$algo.repeat-$repeat.DOP-$procs"
            msg "Verifying $name"
            sudo "$NEO" -fj $procs -i "$CONF" -o "$RESULTS_DIR/$name"
            sudo chown -R $(id -u):$(id -g) "$RESULTS_DIR/$name"
            cp "$CONF" "$RESULTS_DIR/$name"
        done
    done
done

msg "Done"
