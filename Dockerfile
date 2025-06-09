FROM ghcr.io/huggingface/text-generation-inference:3.3.2

RUN apt update && \
    apt install openssh-server -y && \
    echo "Port 22" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

RUN VENV_ACTIVATE_PATH="/usr/src/.venv/bin/activate" && \
    if [ -f "$VENV_ACTIVATE_PATH" ]; then \
        echo "source $VENV_ACTIVATE_PATH" >> /root/.bashrc; \
    else \
        echo "Warning: Virtual environment activation script not found at $VENV_ACTIVATE_PATH"; \
    fi

ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/root/.local/share/uv/python/cpython-3.11.11-linux-x86_64-gnu/lib/

WORKDIR /root

EXPOSE 22
EXPOSE 80

ENTRYPOINT ["/entrypoint.sh"]
