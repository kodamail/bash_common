#
# common utilities for analysis using bash
#
#
# [usage]
#   . common.sh
#
# [global variable]
#   BASH_COMMON_TEMP_DIR
#     temporary directory
#
export LANG=en
export F_UFMTENDIAN="big"

BASH_COMMON_TEMP_DIR=""
BASH_COMMON_ORG_DIR=$( pwd )
function create_temp()
{
#    local TEMP
#    for(( i=1; $i<=10; i=$i+1 )) ; do
#        TEMP=$( date +%s )
    BASH_COMMON_TEMP_DIR=temp.$( date +%s ).$$
#        [ ! -d ${BASH_COMMON_TEMP_DIR} ] && break
#        sleep 1s
#    done
    mkdir -p ${BASH_COMMON_TEMP_DIR}
}

#
# [usage]
#   trap 'finish'
#   trap 'finish "message"'
#
function finish()
{
    local MESSAGE=$1

    cd ${BASH_COMMON_ORG_DIR}
    [ "${BASH_COMMON_TEMP_DIR}" != "" ] && rm -rf ${BASH_COMMON_TEMP_DIR}

    echo ""
    if [ "${MESSAGE}" = "" ] ; then
	echo "########## $0 finished ##########"
    else
	echo "${MESSAGE}"
    fi
    echo ""
}
