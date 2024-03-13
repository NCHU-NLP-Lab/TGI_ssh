FROM ghcr.io/huggingface/text-generation-inference:1.4

COPY entrypoint.sh /entrypoint.sh
RUN chmod 777 /entrypoint.sh

RUN apt update &&  apt install openssh-server -y
RUN echo "Port 22" >> /etc/ssh/sshd_config
RUN echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

EXPOSE 22

ENV PASSWORD="PASSWORD"

ENTRYPOINT /entrypoint.sh && /bin/bash
