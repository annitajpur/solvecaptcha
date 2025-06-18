#!/data/data/com.termux/files/usr/bin/bash

# Ngrok auth token
NGROK_AUTH_TOKEN="1sKv56NfduxWmGA3RKNiJjCm8Y5_6X9tmT26u6WfKQX2jVsqG"

# Function to install ngrok if missing
install_ngrok() {
  echo "📦 Installing ngrok..."
  rm -f $PREFIX/bin/ngrok
  rm -rf $PREFIX/share/ngrok
  mkdir -p $PREFIX/share/ngrok
  cp get-ngrok.sh $PREFIX/share/ngrok/
  cp ngrok $PREFIX/bin/
  chmod +x $PREFIX/bin/ngrok
  apt update && apt upgrade -y
  apt install -y proot wget resolv-conf
  apt clean && apt autoremove -y
  cd $PREFIX/share/ngrok
  bash get-ngrok.sh
  echo -e "\e[1;32m✅ Ngrok installed successfully!"
  echo "ℹ️ Run: ngrok to use manually if needed"
}

# Install ngrok if not found
if ! command -v ngrok &> /dev/null; then
  install_ngrok
fi

# Add Ngrok auth token if not already configured
if [ ! -f "$HOME/.config/ngrok/ngrok.yml" ]; then
  ngrok config add-authtoken $NGROK_AUTH_TOKEN
fi

# Install Python and dependencies
echo "🐍 Installing Python & packages..."
pkg install -y python python3 wget curl git
pip install --upgrade pip setuptools

echo "📦 Installing Python packages..."
pip install flask &
sleep 5

pip install flask-cors &
sleep 5
pip install pytesseract &
sleep 5
echo "📸 Installing Tesseract..."
pkg install -y tesseract

# Fix pillow compile flags (optional redundancy for Termux)
LDFLAGS="-L/data/data/com.termux/files/usr/lib" \
CFLAGS="-I/data/data/com.termux/files/usr/include" \
pip install --no-cache-dir pillow

# Start Flask server
echo "🚀 Starting Flask server..."
python3 app.py &

# Wait for Flask server to boot
sleep 5

# Start ngrok tunnel
echo "🌐 Starting ngrok..."
ngrok http 5000 > ngrok.log &
sleep 5

# Extract and print ngrok URL
NGROK_URL=$(grep -o 'https://[0-9a-z]*\.ngrok-free\.app' ngrok.log | head -n 1)

if [ -n "$NGROK_URL" ]; then
  echo "✅ Public URL: $NGROK_URL"
else
  echo "❌ Failed to get ngrok URL"
fi

# Keep script running
tail -f /dev/null
