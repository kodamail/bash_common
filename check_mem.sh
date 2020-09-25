#!/bin/bash
#
# get memory usage
#
export LANG=C
PID=$1
SEC_START=$( date +%s )

MEM_MAX=0
while : ; do
    MEM=$( pmap ${PID} | tail -n 1 | awk '{ print $2 }' | sed -e "s/K$//")
    [[ "${MEM}" = "" ]] && break
    let MEM=MEM/1024
    (( MEM > MEM_MAX )) && { MEM_MAX=${MEM} ; } 
    SEC=$( date +%s )
    let SEC_OUT=SEC-SEC_START
    echo "${SEC_OUT} ${MEM} MB"
    sleep 5s
done

echo
echo "# max. ${MEM_MAX} MB"
