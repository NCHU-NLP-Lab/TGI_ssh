#!/bin/bash

FLAG_FILE="/first_run_flag"

# Set the root password if it's the first run
if [ ! -f "$FLAG_FILE" ]; then
    echo root:$PASSWORD | chpasswd
    touch "$FLAG_FILE"
else
    echo "already run"
fi

# Ensure SSH host keys are generated
ssh-keygen -A

# Start SSH service using the correct configuration file
exec /opt/conda/bin/sshd -f /opt/conda/etc/sshd_config -D
