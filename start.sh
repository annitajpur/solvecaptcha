#!/bin/bash

# Your ngrok auth token
NGROK_AUTH_TOKEN="1sKv56NfduxWmGA3RKNiJjCm8Y5_6X9tmT26u6WfKQX2jVsqG"

# Add ngrok token (only the first time)
ngrok config add-authtoken $NGROK_AUTH_TOKEN

# Start Flask app in background
echo "🚀 Starting Flask server..."
python3 server.py &

# Wait a few seconds
sleep 3

# Start ngrok in background
echo "🌐 Starting ngrok tunnel..."
ngrok http 5000 > ngrok.log &

# Wait for ngrok to connect
sleep 5

# Extract ngrok public URL
NGROK_URL=$(grep -o 'https://[0-9a-z]*\.ngrok-free\.app' ngrok.log | head -n 1)

if [ -n "$NGROK_URL" ]; then
  echo "✅ Server is live at: $NGROK_URL"
else
  echo "❌ Failed to get ngrok URL"
fi

# Keep the script running
echo "🔁 Running... press Ctrl+C to exit"
tail -f /dev/null
