#!/usr/bin/env bash

set -o nounset                              # Treat unset variables as an error


### user: add a user
# Arguments:
#   name) for user
#   password) for user
#   id) for user
#   group) for user
# Return: user added to container
user() { local name="${1}" passwd="${2}" 
    useradd "$name" -M -g users
    echo -e "$passwd\n$passwd" | smbpasswd -s -a "$name"
}

### workgroup: set the workgroup
# Arguments:
#   workgroup) the name to set
# Return: configure the correct workgroup
workgroup() { local workgroup="${1}" file=/etc/samba/smb.conf
    sed -i 's|^\( *workgroup = \).*|\1'"$workgroup"'|' $file
}

### usage: Help
# Arguments:
#   none)
# Return: Help text
usage() { local RC=${1:-0}
    echo "Usage: ${0##*/} [-opt] [command]
Options (fields in '[]' are optional, '<>' are required):
    -h          This help
    -n          Start the 'nmbd' daemon to advertise the shares
    -u \"<username;password>\"       Add a user
                required arg: \"<username>;<passwd>\"
                <username> for user
                <password> for user
    -w \"<workgroup>\"       Configure the workgroup (domain) samba should use
                required arg: \"<workgroup>\"
                <workgroup> for samba

The 'command' (if provided and valid) will be run instead of samba
" >&2
    exit $RC
}

while getopts ":hnu:w:" opt; do
    case "$opt" in
        h) usage ;;
        n) NMBD="true" ;;
        u) eval user $(sed 's|;| |g' <<< $OPTARG) ;;
        w) workgroup "$OPTARG" ;;
        "?") echo "Unknown option: -$OPTARG"; usage 1 ;;
        ":") echo "No argument value for option: -$OPTARG"; usage 2 ;;
    esac
done
shift $(( OPTIND - 1 ))

[[ "${WORKGROUP:-""}" ]] && workgroup "$WORKGROUP"

if [[ $# -ge 1 && -x $(which $1 2>&-) ]]; then
    exec "$@"
elif [[ $# -ge 1 ]]; then
    echo "ERROR: command not found: $1"
    exit 13
elif ps -ef | egrep -v grep | grep -q smbd; then
    echo "Service already running, please restart container to apply changes"
else
    [[ ${NMBD:-""} ]] && ionice -c 3 nmbd -D
    exec ionice -c 3 smbd -FS </dev/null
fi
