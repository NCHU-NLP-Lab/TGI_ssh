FROM ghcr.io/huggingface/text-generation-inference:3.3.2

# Install openssh and configure it
RUN apt update && \
    apt install openssh-server -y && \
    echo "Port 22" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Set default password environment variable (build-time)
ENV PASSWORD="PASSWORD"

# Set LD_LIBRARY_PATH to include libpython path (for SSH sessions)
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/root/.local/share/uv/python/cpython-3.11.11-linux-x86_64-gnu/lib/

# Set root password during build
# This will set the password for the root user in the image
RUN echo "root:$PASSWORD" | chpasswd

# Add venv activation to root's .bashrc for future interactive sessions
RUN VENV_ACTIVATE_PATH="/usr/src/.venv/bin/activate" && \
    if [ -f "$VENV_ACTIVATE_PATH" ]; then \
        echo "source $VENV_ACTIVATE_PATH" >> /root/.bashrc; \
    else \
        echo "Warning: Virtual environment activation script not found at $VENV_ACTIVATE_PATH"; \
    fi

WORKDIR /root

# Expose SSH port and the TGI port
EXPOSE 22
EXPOSE 80

# Define the command that will run when the container starts
# This will start the SSH service and then run a bash shell
CMD service ssh start && /bin/bash