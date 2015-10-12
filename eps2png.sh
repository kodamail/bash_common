#!/bin/sh
#
# usage:
#   ./eps2png.sh [-r] [--delete-eps]
#                [--dry-run]
#                [-p match-pattern]
#                [--max-cycle n]
#
ARGS_ORG="$*"
MATCH=""
RECURSIVE=0
DEL_EPS=0
DRY_RUN=0
MAX_CYCLE=0

while [ "$1" != "" ] ; do
    if [ "$1" = "-r" ] ; then
	RECURSIVE=1
    elif [ "$1" = "--delete-eps" ] ; then
	DEL_EPS=1
    elif [ "$1" = "--dry-run" ] ; then
	DRY_RUN=1
    elif [ "$1" = "--max-cycle" ] ; then
	shift
	MAX_CYCLE=$1
    elif [ "$1" = "-p" ] ; then
	shift
	MATCH=$1
    else
	echo "syntax error in eps2png.sh: $1" >&2
	exit 1
    fi
    shift
done

[ "${MATCH}" = "" ] && MATCH="*.eps"

if [ ${RECURSIVE} -eq 0 ] ; then
    EPS_LIST=( $( find ./ -maxdepth 1 -type f -name "${MATCH}" ) )
else
    EPS_LIST=( $( find ./ -type f -name "${MATCH}" ) )
fi

TEMP1=temp1.$$.png
TEMP2=temp2.$$.png
for EPS in ${EPS_LIST[@]} ; do
    PNG=$( echo ${EPS} | sed -e "s/eps$/png/" )
    echo ${EPS} ${PNG}
    [ ${DRY_RUN} -eq 1 ] && continue
    if [ -f ${PNG} ] ; then
	echo "${PNG} exists. skip!"
	continue
    fi

    convert -rotate 90 +antialias -depth 8 -define png:bit-depth=8 -density 600 -resize 854x660 ${EPS} ${TEMP1} || exit 1

    convert -fill white -draw 'rectangle 0,0,10000,10000' ${TEMP1} ${TEMP2} || exit 1
    composite ${TEMP1} ${TEMP2} ${PNG} || exit 1
#    GEOMETRY=$( identify -verbose temp.png | grep geometry | cut -d : -f 2 )
#    convert -density 600 -size ${GEOMETRY} xc:white -fx "(floor(i/10)+floor(j/10))%2==0?#C0C0FF:#FFFFFF" white.png
#    composite temp.png white.png ${PNG}
    rm ${TEMP1} ${TEMP2}

    [ ${DEL_EPS} -eq 1 ] && rm ${EPS}
done

let MAX_CYCLE--
if [ ${MAX_CYCLE} -gt 0 -a ${#EPS_LIST[@]} -gt 0 ] ; then
    ARGS=$( echo ${ARGS_ORG} | sed -e "s/--max-cycle \+[0-9]\+/--max-cycle ${MAX_CYCLE}/" )
    echo "eps2png.sh is recursively executed with args = ${ARGS}"
    ./eps2png.sh ${ARGS} || exit 1
fi





echo "eps2png.sh normally finished."
[ ${DRY_RUN} -eq 1 ] && echo "(dry-run)"
exit
