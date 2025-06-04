#!/bin/bash

FLAG_FILE="/first_run_flag"

# Set the root password if it's the first run
if [ ! -f "$FLAG_FILE" ]; then
    echo root:$PASSWORD | chpasswd

    VENV_ACTIVATE_PATH="/usr/src/.venv/bin/activate"
    if [ -f "$VENV_ACTIVATE_PATH" ]; then
        echo "Adding venv activation to /root/.bashrc..."
        
        # Ensure it's not added multiple times if script somehow runs setup again without flag
        grep -qxF "source $VENV_ACTIVATE_PATH" /root/.bashrc || echo "source $VENV_ACTIVATE_PATH" >> /root/.bashrc
    else
        echo "Warning: Virtual environment activation script not found at $VENV_ACTIVATE_PATH"
    fi

    touch "$FLAG_FILE"
else
    echo "already run"
fi

source /usr/src/.venv/bin/activate
service ssh start
