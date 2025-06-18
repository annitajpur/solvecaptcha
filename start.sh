#!/data/data/com.termux/files/usr/bin/bash

# Ngrok auth token (replace if needed)
NGROK_AUTH_TOKEN="1sKv56NfduxWmGA3RKNiJjCm8Y5_6X9tmT26u6WfKQX2jVsqG"

# Function to install ngrok if missing
install_ngrok() {
  echo "📦 Installing ngrok..."
  pkg install wget unzip -y
  wget https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip -O ngrok.zip
  unzip ngrok.zip
  chmod +x ngrok
  mv ngrok $PREFIX/bin/
  rm ngrok.zip
}

# Check ngrok
if ! command -v ngrok &> /dev/null; then
  install_ngrok
fi

# Add ngrok token only if not already added
if [ ! -f "$HOME/.config/ngrok/ngrok.yml" ]; then
  ngrok config add-authtoken $NGROK_AUTH_TOKEN
fi

# Start Flask server
echo "🚀 Starting Flask server..."
python3 server.py &

# Wait for Flask
sleep 3

# Start ngrok tunnel in background
echo "🌐 Starting ngrok..."
ngrok http 5000 > ngrok.log &
sleep 5

# Extract and show public URL
NGROK_URL=$(grep -o 'https://[0-9a-z]*\.ngrok-free\.app' ngrok.log | head -n 1)

if [ -n "$NGROK_URL" ]; then
  echo "✅ Public URL: $NGROK_URL"
else
  echo "❌ Failed to get ngrok URL"
fi

# Prevent exit
tail -f /dev/null
