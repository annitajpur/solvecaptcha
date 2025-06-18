#!/data/data/com.termux/files/usr/bin/bash

echo "🔧 Setting up..."

# Ensure required tools
pkg update -y
pkg install -y python git wget tesseract termux-api

# Install Python requirements
pip install -r requirements.txt

# Download ngrok if not exists
if [ ! -f "ngrok" ]; then
    wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip
    unzip ngrok-stable-linux-arm.zip
    chmod +x ngrok
fi

# Set NGROK token if not already set
if [ ! -f ".ngrok_authtoken_set" ]; then
    read -p "Enter your Ngrok Authtoken: " TOKEN
    ./ngrok config add-authtoken "$TOKEN"
    touch .ngrok_authtoken_set
fi

# Start ngrok and Flask
echo "🚀 Starting Flask server and exposing via Ngrok..."
nohup python app.py > flask.log 2>&1 &
sleep 3
nohup ./ngrok http 5000 > ngrok.log 2>&1 &
sleep 3

# Display Ngrok public URL
curl --silent http://localhost:4040/api/tunnels | grep -o 'https://[0-9a-z]*\.ngrok\.io'
