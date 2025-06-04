FROM ghcr.io/huggingface/text-generation-inference:3.3.2

# Copy entrypoint script and set permissions
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Install openssh
RUN apt update &&  apt install openssh-server -y
RUN echo "Port 22" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Expose SSH port
EXPOSE 22
EXPOSE 80

# Set default password environment variable
ENV PASSWORD="PASSWORD"

WORKDIR /root

# Set the entrypoint to the script
ENTRYPOINT ["/entrypoint.sh"]
CMD ["/bin/bash"]
