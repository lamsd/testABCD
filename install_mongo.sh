#!/bin/bash

# Set MongoDB version
MONGO_VERSION=7.0

# Update the package list
echo "Updating package list..."
sudo apt-get update -y

# Install gnupg to handle the MongoDB PGP key
echo "Installing gnupg..."
sudo apt-get install gnupg -y

# Add MongoDB's official public GPG key
echo "Adding MongoDB GPG key..."
wget -qO - https://www.mongodb.org/static/pgp/server-${MONGO_VERSION}.asc | sudo apt-key add -

# Create MongoDB repository list file for Ubuntu 22.04 (Jammy)
echo "Creating MongoDB repository list..."
cd /etc/apt/sources.list.d/
sudo touch mongodb-org-${MONGO_VERSION}.list
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/${MONGO_VERSION} multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-${MONGO_VERSION}.list

# Update the package list again after adding the MongoDB repository
echo "Updating package list after adding MongoDB repository..."
sudo apt-get update -y

# Install MongoDB
echo "Installing MongoDB ${MONGO_VERSION}..."
sudo apt-get install -y mongodb-org

# Start MongoDB service
echo "Starting MongoDB service..."
sudo systemctl start mongod

# Enable MongoDB to start on boot
echo "Enabling MongoDB to start on boot..."
sudo systemctl enable mongod

# Verify if MongoDB is running
echo "Verifying MongoDB installation..."
sudo systemctl status mongod

