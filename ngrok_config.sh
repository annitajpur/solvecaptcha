#!/data/data/com.termux/files/usr/bin/bash
read -p "Enter Ngrok Authtoken: " TOKEN
./ngrok config add-authtoken "$TOKEN"
