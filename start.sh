#!/usr/bin/env bash
set -e

# 1. Create host persistent folders & Zsh history file with host user ownership
mkdir -p ./ros2-ws/src ./.zsh_data
touch ./.zsh_data/.zsh_history

# 2. Save host UID/GID to .env
cat << EOF > .env
UID=$(id -u)
GID=$(id -g)
EOF

# 3. Allow Docker X11 display access for Gazebo, RViz2 & Terminator
xhost +local:docker >/dev/null 2>&1 || true

# 4. Pull & start the container (skipping local build)
docker compose up -d --no-build

# 5. Match container /home/ibra ownership if host UID/GID differs from 1000
if [ "$(id -u)" != "1000" ] || [ "$(id -g)" != "1000" ]; then
  docker exec -u root ros2_jazzy_kg chown -R "$(id -u):$(id -g)" /home/ibra
fi

echo "Container 'ros2_jazzy_kg' is running. Enter with: docker exec -it ros2_jazzy_kg zsh"