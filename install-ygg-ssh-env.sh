#!/bin/bash -e
whoami
sudo apt-get install dirmngr
sudo mkdir -p /usr/local/apt-keys
gpg --fetch-keys https://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/key.txt
gpg --export BC1BF63BD10B8F1A | sudo tee /usr/local/apt-keys/yggdrasil-keyring.gpg > /dev/null
echo 'deb [signed-by=/usr/local/apt-keys/yggdrasil-keyring.gpg] http://neilalexander.s3.dualstack.eu-west-2.amazonaws.com/deb/ debian yggdrasil' | sudo tee /etc/apt/sources.list.d/yggdrasil.list
sudo apt-get update
sudo apt-get install yggdrasil
sudo systemctl enable yggdrasil
sudo systemctl start yggdrasil
echo "$YGGCONFDATA" | base64 -d | xz -d > yggdrasil.conf
sudo mv yggdrasil.conf /etc/yggdrasil/yggdrasil.conf
sudo systemctl restart yggdrasil

echo "installing ssh"
sudo apt install openssh-server
mkdir -p ~/.ssh
echo "$PUBKEY" >> ~/.ssh/authorized_keys
sudo systemctl enable ssh --now

echo "install completed."
