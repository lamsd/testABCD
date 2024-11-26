#!/bin/bash

# MongoDB Configuration Variables
DOMAIN="tuanhoangdinh.ddns.net"  # Replace with your DDNS domain
PORT="27017"                     # MongoDB default port
MONGO_USER="admin"               # MongoDB username
MONGO_PASSWORD="adminsuper123"   # MongoDB password
MONGO_DATABASE="example_db"      # MongoDB database name

# Function to resolve the domain to an IP address
resolve_domain() {
    echo "Resolving domain: $DOMAIN"
    IP=$(dig +short "$DOMAIN")
    if [ -z "$IP" ]; then
        echo "Failed to resolve domain $DOMAIN. Please check the domain name."
        exit 1
    fi
    echo "Resolved IP: $IP"
}

# Function to install MongoDB
install_mongodb() {
    echo "Installing MongoDB..."
    sudo apt update -y
    sudo apt install -y gnupg curl software-properties-common
    curl -fsSL https://www.mongodb.org/static/pgp/server-8.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-8.0.gpg  --dearmor
    echo "deb [ arch=amd64,arm64 signed-by=/usr/share/keyrings/mongodb-server-8.0.gpg ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/8.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-8.0.list
    sudo apt update -y
    sudo apt install -y mongodb-org
}

# Function to configure MongoDB
configure_mongodb() {
    echo "Configuring MongoDB to bind to all IPs..."
    sudo sed -i "s/^  bindIp:.*/  bindIp: 0.0.0.0/" /etc/mongod.conf
    echo "Enabling authentication..."
    if ! grep -q "authorization: enabled" /etc/mongod.conf; then
        sudo sed -i "/#security:/a\security:\n  authorization: enabled" /etc/mongod.conf
    fi
    echo "Restarting MongoDB service..."
    sudo systemctl restart mongod
}

# Function to create a MongoDB user
create_mongodb_user() {
    echo "Creating MongoDB user..."
    mongosh --host $DOMAIN --port $PORT -u $MONGO_USER -p $MONGO_PASSWORD --authenticationDatabase "admin" <<EOF
use $MONGO_DATABASE
db.createUser({
  user: "$MONGO_USER",
  pwd: "$MONGO_PASSWORD",
  roles: [ { role: "readWrite", db: "$MONGO_DATABASE" } ]
})
EOF
}

# Function to update firewall rules for the resolved IP
update_firewall() {
    echo "Updating firewall rules for IP: $IP..."
    sudo ufw allow from "$IP" to any port "$PORT"
    sudo ufw reload
}

# Function to verify MongoDB status
verify_mongodb() {
    echo "Verifying MongoDB service status..."
    if sudo systemctl status mongod | grep "active (running)" >/dev/null; then
        echo "MongoDB is running successfully!"
    else
        echo "MongoDB is not running. Check the logs for more details."
        exit 1
    fi
}

# Main Script
main() {
    echo "Publishing MongoDB with DDNS domain: $DOMAIN"
    echo "--------------------------------------------"

    # Step 1: Resolve the domain to an IP
    resolve_domain

    # Step 2: Install MongoDB if not installed
    if ! command -v mongod >/dev/null; then
        install_mongodb
    else
        echo "MongoDB is already installed."
    fi

    # Step 3: Configure MongoDB
    configure_mongodb

    # Step 4: Update the firewall for the resolved IP
    update_firewall

    # Step 5: Verify MongoDB service
    verify_mongodb

    # Step 6: Create a MongoDB user
    create_mongodb_user

    echo "--------------------------------------------"
    echo "MongoDB is successfully published!"
    echo "Connection URI: mongosh mongodb://$MONGO_USER:$MONGO_PASSWORD@$DOMAIN:$PORT/$MONGO_DATABASE"
}

# Execute the main function
main
