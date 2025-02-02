#!/bin/bash

echo 'Removing old packages...'

for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do
    if dpkg -l | grep -qw $pkg; then
        sudo apt-get remove -y $pkg
    fi
done
sudo rm -f /etc/apt/sources.list.d/docker.list

echo 'Installing docker...'

sudo mkdir -p /etc/apt/keyrings
sudo chmod 755 /etc/apt/keyrings

curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bullseye stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

if ! command -v docker &> /dev/null; then
    echo "Docker installation failed."
    exit 1
fi

docker volume create portainer_data
docker run -d -p 8000:8000 -p 9443:9443 -p 9000:9000 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:2.21.5

echo 'Docker installed.'
