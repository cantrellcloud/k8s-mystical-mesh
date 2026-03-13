#!/bin/bash

# Script to configure NTP on a target machine
# Supports systemd-timesyncd, chronyd, and ntpd
# Usage: ./configure_ntp.sh --target <computerName> [--ssh-user <user>] [--ssh-pass <pass>] [--sudo-pass <pass>]

TARGET=""
SSH_USER="adminlocal"
NTP_SERVERS="10.231.1.34"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --target)
            TARGET="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 --target <computerName> [--ssh-user <user>] [--ssh-pass <pass>] [--sudo-pass <pass>]"
            exit 1
            ;;
    esac
done

if [[ -z "$TARGET" ]]; then
    echo "Error: --target is required"
    echo "Usage: $0 --target <computerName> [--ssh-user <user>] [--ssh-pass <pass>] [--sudo-pass <pass>]"
    exit 1
fi

echo "Configuring NTP on $TARGET to use servers: $NTP_SERVERS"

scp config-ntp-script.sh "$SSH_USER@$TARGET":/tmp 
ssh -t "$SSH_USER@$TARGET" "sudo /tmp/config-ntp-script.sh && sudo rm /tmp/config-ntp-script.sh"

echo "NTP configuration completed on $TARGET"

