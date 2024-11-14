#!/bin/bash

FLAG_FILE="/first_run_flag"

# Set the root password if it's the first run
if [ ! -f "$FLAG_FILE" ]; then
    echo root:$PASSWORD | chpasswd
    echo 'export $(cat /proc/1/environ | tr "\\0" "\\n" | xargs)' >> /etc/profile
    touch "$FLAG_FILE"
else
    echo "already run"
fi

# Ensure SSH host keys are generated
ssh-keygen -A

# Start SSH service using the full path and in the foreground
exec /opt/conda/bin/sshd -D
