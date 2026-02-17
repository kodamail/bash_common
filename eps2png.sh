#!/bin/bash
#
#===============================================#
#
#===============================================#
#
#--- Help
#
help()
{
    echo "usage:"
    echo "    $(basename $0)"
    echo "      [-r] [--delete-eps]"
    echo "      [--dry-run]"
    echo "      [-p match-pattern]"
    echo "      [--max-cycle n]"
    echo "      [eps1.eps eps2.eps ...]"
}
echo "$(basename $0) started ($(date))."

#
#--- Arguments
#
ARGS_ORG="$*"

MATCH=""
RECURSIVE=0
DEL_EPS=0
DRY_RUN=0
MAX_CYCLE=0
EPS_LIST=()
DENSITY=600
SIZE="1920x1080"  # default: 2K

while (( $# > 0 )) ; do
    if [[ $1 = "-r" ]] ; then
	RECURSIVE=1
    elif [[ $1 = "--delete-eps" ]] ; then
	DEL_EPS=1
    elif [[ $1 = "--dry-run" ]] ; then
	DRY_RUN=1
    elif [[ $1 = "--max-cycle" ]] ; then
	shift
	MAX_CYCLE=$1
    elif [[ $1 = "-p" ]] ; then
	shift
	MATCH=$1
    elif [[ -f $1 ]] ; then
	EPS_LIST+=( $1 )
    else
	echo ; help ; echo
	exit 1
    fi
    shift
done

[[ "${MATCH}" = "" ]] && MATCH="*.eps"

if (( ${#EPS_LIST[@]} == 0 )) ; then
    if (( ${RECURSIVE} == 0 )) ; then
	EPS_LIST=( $( find ./ -maxdepth 1 -type f -name "${MATCH}" ) )
    else
	EPS_LIST=( $( find ./ -type f -name "${MATCH}" ) )
    fi
fi

if (( ${#EPS_LIST[@]} == 0 )) ; then
    echo ; help ; echo
    exit 1
fi

#TEMP1=temp1.$$.png
#TEMP2=temp2.$$.png
#for EPS in ${EPS_LIST[@]} ; do
for eps in ${EPS_LIST[@]} ; do
    png=${eps/%eps/png}
    [[ "${eps}" = "${png}" || -f "${png}" ]] && continue
    echo "${eps} -> ${png}"
    (( ${DRY_RUN} > 0 )) && continue

    magick -density ${DENSITY} ${eps} -rotate 90 -trim -resize "${SIZE}>" ${png}
    
#    magick convert -rotate 90 +antialias -depth 8 -define png:bit-depth=8 -density 600 -resize 854x660 ${EPS} ${TEMP1} || exit 1
#    magick convert -fill white -draw 'rectangle 0,0,10000,10000' ${TEMP1} ${TEMP2} || exit 1
#    magick composite ${TEMP1} ${TEMP2} ${PNG} || exit 1

#    GEOMETRY=$( identify -verbose temp.png | grep geometry | cut -d : -f 2 )
#    convert -density 600 -size ${GEOMETRY} xc:white -fx "(floor(i/10)+floor(j/10))%2==0?#C0C0FF:#FFFFFF" white.png
#    composite temp.png white.png ${PNG}
#    rm ${TEMP1} ${TEMP2}

    (( ${DEL_EPS} == 1 )) && rm ${eps}
done

let MAX_CYCLE--
if (( ${MAX_CYCLE} > 0 && ${#EPS_LIST[@]} >  0 )) ; then
    ARGS=$( echo ${ARGS_ORG} | sed -e "s/--max-cycle \+[0-9]\+/--max-cycle ${MAX_CYCLE}/" )
    echo "eps2png.sh is recursively executed with args = ${ARGS}"
    $0 ${ARGS} || exit 1
fi

echo "$(basename $0) normally finished ($(date))."
(( ${DRY_RUN} == 1 )) && echo "(dry-run)"
exit
