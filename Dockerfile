FROM ghcr.io/huggingface/text-generation-inference:2.4.0

# Copy entrypoint script and set permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Use Conda to install openssh
RUN conda install -y openssh

# Create the /etc/ssh directory and configure SSH server settings
RUN mkdir -p /etc/ssh && \
    echo "Port 22" >> /opt/conda/etc/sshd_config && \
    echo "PasswordAuthentication yes" >> /opt/conda/etc/sshd_config && \
    echo "PermitRootLogin yes" >> /opt/conda/etc/sshd_config

# Add the sshd privilege separation user
RUN useradd -r -s /usr/sbin/nologin sshd

# Create /var/empty directory for privilege separation
RUN mkdir -p /var/empty && \
    chown root:root /var/empty && \
    chmod 700 /var/empty

# Expose SSH port
EXPOSE 22

# Set default password environment variable
ENV PASSWORD="PASSWORD"

# Use JSON syntax for ENTRYPOINT to prevent OS signal issues
ENTRYPOINT ["/entrypoint.sh"]
