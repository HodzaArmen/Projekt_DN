#!/usr/bin/env bash
set -e

echo "Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "Installing Python3, pip, Docker, unzip, and required tools..."
sudo apt-get install -y python3 python3-pip docker.io unzip curl

echo "Enabling and starting Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo "Pulling and running Redis container..."
if [ ! "$(sudo docker ps -q -f name=redis)" ]; then
    if [ "$(sudo docker ps -aq -f status=exited -f name=redis)" ]; then
        sudo docker start redis
    else
        sudo docker run -d --name redis -p 6379:6379 redis
    fi
else
    echo "Redis container already running."
fi

echo "Setting up ToDo Flask app..."
APP_DIR="/home/vagrant/todo_web_app"
sudo mkdir -p $APP_DIR
sudo cp /vagrant/ToDo.zip $APP_DIR/
cd $APP_DIR
sudo unzip -o ToDo.zip >/dev/null
sudo chown -R vagrant:vagrant $APP_DIR

echo "Installing Python dependencies (Flask + Redis client)..."
cd $APP_DIR/ToDo
pip3 install --no-cache-dir -r requirements.txt

echo "Starting Flask app in background..."
nohup python3 app.py >/dev/null 2>&1 &

echo "successs"
echo "Access your app at: http://localhost:5000"
