#!/bin/bash
# Update and install Docker
sudo apt update -y
sudo apt install docker.io -y

# Enable Docker on startup
sudo systemctl start docker
sudo systemctl enable docker

# Give permission to ubuntu user
sudo usermod -aG docker ubuntu

# Pull your Docker image
docker pull yogismash/strapi-app

# Run the container
docker run -d -p 1337:1337 yogismash/strapi-app
