#!/bin/bash

# Script to set up and run MongoDB 7.0

# Function to check if MongoDB is already installed
check_mongodb_installed() {
    if command -v mongod >/dev/null 2>&1; then
        echo "MongoDB is already installed."
        return 0
    else
        return 1
    fi
}

# Update system and install MongoDB
install_mongodb() {
    echo "Updating system packages..."
    sudo apt update -y

    echo "Installing dependencies..."
    sudo apt install -y gnupg curl software-properties-common

    echo "Adding MongoDB 7.0 official repository..."
    curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
    echo "deb [signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

    echo "Updating package list..."
    sudo apt update -y

    echo "Installing MongoDB 7.0..."
    sudo apt install -y mongodb-org
}

# Start MongoDB service
start_mongodb() {
    echo "Starting MongoDB service..."
    sudo systemctl start mongod

    echo "Enabling MongoDB to start on boot..."
    sudo systemctl enable mongod
}

# Verify MongoDB status
verify_mongodb() {
    echo "Checking MongoDB status..."
    if sudo systemctl status mongod | grep "active (running)" >/dev/null; then
        echo "MongoDB 7.0 is running successfully!"
    else
        echo "MongoDB is not running. Please check logs for details."
        exit 1
    fi
}

# Main script logic
main() {
    echo "MongoDB 7.0 Setup Script"
    echo "-------------------------"

    # Check if MongoDB is installed
    if ! check_mongodb_installed; then
        echo "MongoDB is not installed. Proceeding with installation..."
        install_mongodb
    fi

    # Start MongoDB
    start_mongodb

    # Verify MongoDB status
    verify_mongodb

    echo "MongoDB 7.0 setup and running completed!"
}

# Execute the main function
main
