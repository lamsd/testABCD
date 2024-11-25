#!/bin/bash

# Script to install, configure, and publish MongoDB for external access

# Variables
MONGO_USER="admin"
MONGO_PASSWORD="admin123@"
MONGO_DATABASE="km24_db"
BIND_IP="0.0.0.0"  # Change to a specific IP for security, e.g., "192.168.1.100"
PORT="27017"

# Function to install MongoDB
install_mongodb() {
    echo "Updating system and installing MongoDB..."
    sudo apt update -y
    sudo apt install -y gnupg curl software-properties-common

    echo "Adding MongoDB repository..."
    curl -fsSL https://pgp.mongodb.com/server-7.0.asc | sudo gpg --dearmor -o /usr/share/keyrings/mongodb-server-7.0.gpg
    echo "deb [signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg] https://repo.mongodb.org/apt/ubuntu $(lsb_release -cs)/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

    echo "Installing MongoDB..."
    sudo apt update -y
    sudo apt install -y mongodb-org
}

# Function to configure MongoDB
configure_mongodb() {
    echo "Configuring MongoDB to bind to IP: $BIND_IP..."
    sudo sed -i "s/^  bindIp:.*/  bindIp: $BIND_IP/" /etc/mongod.conf

    echo "Enabling authentication in MongoDB..."
    if ! grep -q "authorization: enabled" /etc/mongod.conf; then
        sudo sed -i "/#security:/a\security:\n  authorization: enabled" /etc/mongod.conf
    fi

    echo "Restarting MongoDB service..."
    sudo systemctl restart mongod
}

# Function to create MongoDB user
create_mongodb_user() {
    echo "Creating MongoDB user with username: $MONGO_USER"
    mongo <<EOF
use $MONGO_DATABASE
db.createUser({
  user: "$MONGO_USER",
  pwd: "$MONGO_PASSWORD",
  roles: [ { role: "readWrite", db: "$MONGO_DATABASE" } ]
})
EOF
}

# Function to allow port in the firewall
allow_firewall_access() {
    echo "Allowing port $PORT through the firewall..."
    sudo ufw allow $PORT
    sudo ufw reload
}

# Function to verify MongoDB service
verify_mongodb() {
    echo "Checking MongoDB service status..."
    if sudo systemctl status mongod | grep "active (running)" > /dev/null; then
        echo "MongoDB is running successfully!"
    else
        echo "MongoDB is not running. Please check logs for details."
        exit 1
    fi
}

# Main script logic
main() {
    echo "Publishing MongoDB for external access..."
    echo "---------------------------------------"

    # Step 1: Install MongoDB
    install_mongodb

    # Step 2: Configure MongoDB
    configure_mongodb

    # Step 3: Allow connections through the firewall
    allow_firewall_access

    # Step 4: Verify MongoDB is running
    verify_mongodb

    # Step 5: Create MongoDB user
    create_mongodb_user

    echo "---------------------------------------"
    echo "MongoDB setup and publishing completed successfully!"
    echo "Connection URI: mongodb://$MONGO_USER:$MONGO_PASSWORD@<YOUR_SERVER_IP>:$PORT/$MONGO_DATABASE"
    echo "Replace <YOUR_SERVER_IP> with your server's public IP address."
}

# Execute the main function
main
