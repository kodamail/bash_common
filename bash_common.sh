#
# common utilities using bash
#
#
# [usage]
#   . common.sh
#
# [global variable]
#   BASH_COMMON_TEMP_DIR
#     temporary directory
#
export LANG=C
export LC_ALL=C
export F_UFMTENDIAN="big"

BASH_COMMON_TEMP_DIR="none"
BASH_COMMON_ORG_DIR=$( pwd )
function create_temp()
{
    for(( i=1; $i<=10; i=$i+1 )) ; do
	BASH_COMMON_TEMP_DIR=temp.$( hostname -s ).$( date +%s ).$$
        [[ ! -d ${BASH_COMMON_TEMP_DIR} ]] && break
        sleep 1s
    done
    mkdir -p ${BASH_COMMON_TEMP_DIR}
}

#
# [usage]
#   trap 'finish' 0
#   trap 'finish "message"' 0
#
function finish()
{
    local MESSAGE=$1

    cd ${BASH_COMMON_ORG_DIR}
    [[ "${BASH_COMMON_TEMP_DIR}" != "" ]] && rm -rf ${BASH_COMMON_TEMP_DIR}

    if [[ "${MESSAGE}" != "" ]] ; then
	echo "${MESSAGE}"
	echo ""
    fi
}


#
# error handling (do not use from common.sh)
#
function error_exit()
{
    local msg=${1:-}
    local ret=${2:-1}
    echo "Error in $0 (line: ${BASH_LINENO[0]}): ${msg}" >&2
    exit ${ret}
}

# legacy
function exit_error()
{
    local MESSAGE=$1
    if [ "${MESSAGE}" = "" ] ; then
	echo "error in $0" >&2
    else
	echo "${MESSAGE}" >&2
    fi
    exit 1
}

#
# check existence of files
#
# [usage]
#   exist_file_or_error filename1 filename2 ...
#
function file_exist_or_error()
{
    if [[ "$1" = "" ]] ; then
	exit_error "error in $0: filename is not specified for exist_file_or_error()."
    fi

    while [[ "$1" != "" ]] ; do
	if [[ ! -f "$1" ]] ; then
	    exit_error "error in $0: $1 does not exist."
	fi
	shift
    done
}

function get_filesize()
{
    if [[ "$1" = "" ]] ; then
	exit_error "error in $0: filename is not specified for get_filesize()."
    fi
    SIZE=$( ls -lL $1 | awk '{ print $5 }' ) || exit_error
    echo ${SIZE}
}
