FROM ghcr.io/huggingface/text-generation-inference:2.4.0


RUN conda install -y cuda-toolkit=12.4


RUN echo 'export LD_LIBRARY_PATH=/opt/conda/lib:$LD_LIBRARY_PATH' >> /etc/profile.d/tgi_env.sh && \
    echo 'export PATH=$PATH:/usr/local/bin' >> /etc/profile.d/tgi_env.sh && \
    echo 'export CUDA_HOME=/opt/conda' >> /etc/profile.d/tgi_env.sh && \
    chmod +x /etc/profile.d/tgi_env.sh


RUN /opt/conda/bin/pip install flash_attn --no-build-isolation --extra-index-url https://download.pytorch.org/whl/cu121


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
EXPOSE 3000

# Set default password environment variable
ENV PASSWORD="PASSWORD"

# Use JSON syntax for ENTRYPOINT to prevent OS signal issues
ENTRYPOINT ["/entrypoint.sh"]
