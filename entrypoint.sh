FLAG_FILE="/first_run_flag"

if [ ! -f "$FLAG_FILE" ]; then
    echo root:$PASSWORD | chpasswd;
    echo 'export $(cat /proc/1/environ | tr "\\0" "\\n" | xargs)' >> /etc/profile
    touch "$FLAG_FILE";
else
    echo "already run";
fi

service ssh start
