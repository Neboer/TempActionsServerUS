#!/bin/bash
set -euo pipefail

: "${PUBKEY:?Set PUBKEY to the SSH client public key}"
: "${SSH_HOST_KEY:?Set SSH_HOST_KEY to the dedicated SSH host private key}"
tail_ip=$(tailscale ip -4)

if [[ ! -x /usr/sbin/sshd ]]; then
    sudo apt-get update
    sudo systemctl mask ssh.service ssh.socket
    sudo apt-get install -y openssh-server
fi
for unit in ssh.socket ssh.service; do
    if systemctl is-active --quiet "$unit"; then
        sudo systemctl stop "$unit"
    fi
done

install -d -m 700 "$HOME/.ssh"
umask 077
printf '%s\n' "$PUBKEY" > "$HOME/.ssh/temp-actions-authorized-keys"
ssh-keygen -l -f "$HOME/.ssh/temp-actions-authorized-keys" >/dev/null

sudo install -d -m 0755 /run/sshd
sudo install -d -m 0700 /run/temp-actions-ssh
printf '%s\n' "$SSH_HOST_KEY" |
    sudo install -m 0600 /dev/stdin /run/temp-actions-ssh/host_key
unset SSH_HOST_KEY

sudo tee /run/temp-actions-ssh/sshd_config >/dev/null <<EOF
ListenAddress $tail_ip
HostKey /run/temp-actions-ssh/host_key
AuthorizedKeysFile .ssh/temp-actions-authorized-keys
AllowUsers $(id -un)
PermitRootLogin no
AuthenticationMethods publickey
PasswordAuthentication no
KbdInteractiveAuthentication no
DisableForwarding yes
UsePAM yes
Subsystem sftp internal-sftp
EOF

sudo /usr/sbin/sshd -t -f /run/temp-actions-ssh/sshd_config
sudo systemd-run --unit=temp-actions-ssh --property=Type=exec \
    /usr/sbin/sshd -D -e -f /run/temp-actions-ssh/sshd_config
for attempt in {1..10}; do
    if (exec 3<>"/dev/tcp/$tail_ip/22") 2>/dev/null; then
        echo "SSH listening on Tailscale IPv4 $tail_ip:22"
        exit 0
    fi
    sleep 1
done
sudo journalctl -u temp-actions-ssh -n 20 --no-pager
exit 1
