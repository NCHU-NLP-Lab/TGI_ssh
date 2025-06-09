if [[ -n "$PASSWORD" ]]; then
    echo "Setting root password..."
    echo "root:$PASSWORD" | chpasswd
else
    echo "Warning: PASSWORD not set"
fi

service ssh start
exec /bin/bash