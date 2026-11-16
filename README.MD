<div align="center">

# 🤖 ROS 2 Jazzy + Gazebo Harmonic Docker Environment

**GPU-Accelerated Robotics Simulation & Development Container**

[![ROS 2 Jazzy](https://img.shields.io/badge/ROS_2-Jazzy_Jalisco-22314E?style=for-the-badge&logo=ros&logoColor=white)](https://docs.ros.org/en/jazzy/)
[![Gazebo Harmonic](https://img.shields.io/badge/Gazebo-Harmonic-FF6F00?style=for-the-badge&logo=gazebo&logoColor=white)](https://gazebosim.org/)
[![Ubuntu 24.04](https://img.shields.io/badge/Ubuntu-24.04_LTS-E95420?style=for-the-badge&logo=ubuntu&logoColor=white)](https://ubuntu.com/)
[![Docker Hub](https://img.shields.io/badge/Docker-ibraa96%2Fros2--jazzykg-2496ED?style=for-the-badge&logo=docker&logoColor=white)](https://hub.docker.com/r/ibraa96/ros2-jazzykg)

*Pre-configured for zero-copy Fast DDS shared memory, NVIDIA & Intel/AMD OpenGL hardware acceleration, split-pane Terminator GUI, and persistent Oh My Zsh workflows.*

</div>

---

##  Key Features

| Component | Details |
| :--- | :--- |
| **ROS 2 & Simulator** | `osrf/ros:jazzy-desktop-full` + Gazebo Harmonic + `ros-jazzy-ros-gz` bridge[cite: 4] |
| **Zero-Copy IPC** | `network_mode: host` + `ipc: host` eliminates Fast DDS discovery issues and maximizes shared-memory bandwidth[cite: 3] |
| **GPU Acceleration** | Full NVIDIA Container Toolkit (`GLX` + `EGL`) and `/dev/dri` Mesa support for RViz2 & Gazebo[cite: 3] |
| **Developer Shell** | Zsh + Oh My Zsh (`autosuggestions`, `syntax-highlighting`) + `colcon` / `ros2` tab-completion[cite: 4] |
| **Multi-Pane Terminal** | **Terminator** pre-installed and ready to launch directly over X11[cite: 4] |

---

## 📁 Repository Structure

```text
ros2-jazzy-docker/
├── Dockerfile          # Recipe used to build the image from osrf/ros:jazzy-desktop-full
├── docker-compose.yml  # Container, GPU, X11, and shared-memory configuration
├── start.sh            # One-command setup, permissions sync, X11 access & container launch
├── .gitignore          # Excludes local .env, .zsh_data/, and build/install/log folders
└── README.md           # Documentation
```

---

## 📋 Prerequisites

1. **Linux Host** (Ubuntu 22.04 / 24.04 recommended) running an **X11 desktop session** (`echo $DISPLAY` should output `:0` or `:1`).
2. **Docker Engine** & **Docker Compose v2** (`docker compose version`).
3. **NVIDIA GPU Users (Recommended):**
   - Proprietary NVIDIA drivers installed (`nvidia-smi` works on host).
   - [NVIDIA Container Toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html) installed and configured:
```bash
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
```

---

## 🚀 Quick Start

### 1. Clone the Repository & Pull the Image
```bash
git clone https://github.com/Ibrahim-Elsayed1/ros2-jazzy-docker.git
```
```bash
cd ros2-jazzy-docker
```
```bash
docker pull ibraa96/ros2-jazzykg:latest
```

### 2. Verify Hardware Groups (Optional Check)
Check your host's `video` and `render` group IDs:
```bash
getent group video render
```
- Default `docker-compose.yml` uses `"44"` (`video`) and `"110"` (`render`)[cite: 3]. If your `render` number differs (e.g., `109` or `992`), update `"110"` under `group_add:` in `docker-compose.yml`[cite: 3].
- **Using Intel/AMD Graphics (No NVIDIA GPU)?** Comment out `runtime: nvidia` and the `NVIDIA_*` / `__NV_*` / `__GLX_*` / `__EGL_*` lines in `docker-compose.yml`[cite: 3]. The `/dev/dri:/dev/dri` mount handles Mesa OpenGL acceleration automatically[cite: 3].

### 3. Run `start.sh`
```bash
chmod +x start.sh
./start.sh
```
> **What `start.sh` does under the hood:**
> 1. Creates `./ros2-ws/src` and `./.zsh_data/.zsh_history` owned by your host user (preventing `root` permission locks).
> 2. Writes your host `UID`/`GID` to `.env` and aligns `/home/ibra` ownership inside the container if your UID differs from `1000`[cite: 3, 4].
> 3. Grants X11 display access (`xhost +local:docker`).
> 4. Runs `docker compose up -d --no-build` to start `ros2_jazzy_kg` in the background using the pulled image (without rebuilding from `Dockerfile`)[cite: 3].
---

## 🛠️ Daily Usage

### Enter the Container Shell
```bash
docker exec -it ros2_jazzy_kg zsh
```
You will land directly in `/home/ibra/ros2-ws` (synced live with `./ros2-ws` on your host)[cite: 3, 4].

### Launch Terminator (Split-Pane GUI Terminal)
```bash
docker exec -d ros2_jazzy_kg terminator
```
| Shortcut | Action |
| :--- | :--- |
| `Ctrl` + `Shift` + `E` | Split terminal vertically (side-by-side) |
| `Ctrl` + `Shift` + `O` | Split terminal horizontally (top/bottom) |
| `Alt` + `Arrow Keys` | Switch focus between panes |

---

## Test: Gazebo + `/clock` Bridge + RViz2

Open **3 Terminator panes** inside `ros2_jazzy_kg`[cite: 3] to verify GPU rendering and ROS–Gazebo clock synchronization:

1. **Pane 1 — Launch Gazebo Harmonic (auto-play mode):**
   ```bash
   gz sim -r shapes.sdf
   ```
2. **Pane 2 — Bridge `/clock` from Gazebo to ROS 2:**
   ```bash
   ros2 run ros_gz_bridge parameter_bridge '/clock@rosgraph_msgs/msg/Clock[gz.msgs.Clock'
   ```
3. **Pane 3 — Verify `/clock` & Launch RViz2:**
   ```bash
   ros2 topic echo /clock --once && rviz2 --ros-args -p use_sim_time:=true
   ```
   > **Expected Result:** RViz2 opens with hardware-accelerated OpenGL (`4.6`), and **ROS Time** in the bottom-left status bar ticks upward in sync with Gazebo.

---

## 📂 Volume & Environment Reference

| Host Path | Container Path | Description |
| :--- | :--- | :--- |
| `./ros2-ws`[cite: 3] | `/home/ibra/ros2-ws`[cite: 3] | Persistent ROS 2 workspace (`src/`, `build/`, `install/`) |
| `./.zsh_data`[cite: 3] | `/home/ibra/.zsh_data`[cite: 3] | Persistent Zsh command history across container restarts[cite: 4] |
| `/tmp/.X11-unix`[cite: 3] | `/tmp/.X11-unix`[cite: 3] | Host X11 display socket for Gazebo, RViz2, and Terminator |

- **Default `ROS_DOMAIN_ID`:** `42` (editable in `docker-compose.yml`)