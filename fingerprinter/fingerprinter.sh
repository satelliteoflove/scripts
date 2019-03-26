#!/usr/bin/env bash
# Reads in a single file one line at a time.  Each line should contain a single
# hostname or IP address.  CSV file is returned with RSA public key
# fingerprints for each host.

file="$1"
while IFS= read hostname
do
    ssh-keygen -E md5 -l -f <(ssh-keyscan -t rsa $hostname 2>/dev/null) |\
    paste -sd ' ' | sed -e "s/ /,/g" >> fingerprints.csv
done <"$file"
