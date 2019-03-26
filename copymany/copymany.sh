#!/usr/bin/env bash
# Copies a single file to multiple hosts based on supplied hostname file. User
# is prompted for password and the file is copied to the local /usr/bin/
# directory on the destination host.


### Helper functions

get_password()
{
    printf "User name: "
    read USERNAME
    printf "\n"
    stty -echo
    printf "Password: "
    read PASSWORD
    stty echo
    printf "\n"
}

copy_file()
{
    while IFS= read SERVER
    do
        echo "Current server: $SERVER"
        echo "Copying file..."
        sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null "$FILETOCOPY" \
            "$USERNAME"@"$SERVER":/usr/bin/
        echo "Resetting permissions..."
        sshpass -p "$PASSWORD" ssh -n -o StrictHostKeyChecking=no \
            -o UserKnownHostsFile=/dev/null -l "$USERNAME" \
            "$SERVER" chmod 755 "/usr/bin/$FILETOCOPY"
        echo "Done."
    done <"$HOSTSFILE"
}

usage()
{
    echo "usage: copymany [-s hostsfile] [-f filetocopy] [-h]"
}

### Main

# Call usage if no arguments are supplied
[[ $# -eq 0 ]] && usage && exit 1

PASSWORD=
HOSTSFILE=./hosts.txt
FILETOCOPY=
USERNAME=

while [ "$1" != "" ]; do
    case "$1" in
        -s | --servers )        shift
                                HOSTSFILE="$1"
                                ;;
        -f | --file )           shift
                                FILETOCOPY="$1"
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

echo "hostsfile = $HOSTSFILE"
echo "file copied = $FILETOCOPY"

echo "Cleaning hostsfile of nasty Windows-only characters..."
sed -i -e "s/\r//g" $HOSTSFILE

get_password
copy_file

# Reset variables to clear sensitive data.
USERNAME=
PASSWORD=
