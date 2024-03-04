#!/bin/bash

# Determine the user who initiated sudo (or the current user if not using sudo)
SUDO_USER_NAME=${SUDO_USER:-$(whoami)}
SUDO_USER_HOME=$(getent passwd "$SUDO_USER_NAME" | cut -d: -f6)

# Define the Docker Compose file content with dynamic volume path
DOCKER_COMPOSE_CONTENT="version: \"3.9\"
services:
  minecraft:
    image: \"marctv/minecraft-papermc-server:latest\"
    restart: always
    container_name: \"mcserver\"
    environment:
      MEMORYSIZE: \"3G\"
      PAPERMC_FLAGS: \"\"
    volumes:
      - \"${SUDO_USER_HOME}/minecraft_server:/data:rw\"
    ports:
      - \"25565:25565\"
    stdin_open: true
    tty: true"

# Define the destination path for Docker Compose file in the user's home directory
DEST_PATH="${SUDO_USER_HOME}/docker-compose.yml"

# Create the Docker Compose file with the content
echo "$DOCKER_COMPOSE_CONTENT" > "$DEST_PATH"

# Change the file ownership to the sudo user
chown "$SUDO_USER_NAME" "$DEST_PATH"

# Create the minecraft_server directory if it doesn't exist
MINECRAFT_DIR="${SUDO_USER_HOME}/minecraft_server"
if [ ! -d "$MINECRAFT_DIR" ]; then
    mkdir "$MINECRAFT_DIR"
    chown "$SUDO_USER_NAME" "$MINECRAFT_DIR"
fi

echo "Docker Compose file created at $DEST_PATH"
echo "Minecraft server directory created at $MINECRAFT_DIR"

# Navigate to user's home directory and launch Docker Compose
cd "$SUDO_USER_HOME"
docker compose -f "$DEST_PATH" up -d

echo "Docker Compose launched for Minecraft server"

# Pause the script
read -p "Press any key to continue..." -n1 -s
echo


