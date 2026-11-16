FROM osrf/ros:jazzy-desktop-full

ENV DEBIAN_FRONTEND=noninteractive

# Install Gazebo Harmonic bridge, build tools, Zsh, and utilities
RUN apt-get update && apt-get install -y --no-install-recommends \
    ros-jazzy-ros-gz \
    python3-colcon-common-extensions \
    python3-rosdep \
    python3-argcomplete \
    git \
    nano \
    curl \
    zsh \
    terminator \
    dbus-x11 \
    && rm -rf /var/lib/apt/lists/*
    
# Create non-root user 'ibra' with Zsh as default shell
ARG USERNAME=ibra
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN userdel -r ubuntu 2>/dev/null || true \
    && groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m -s /bin/zsh $USERNAME \
    && apt-get update && apt-get install -y sudo \
    && echo "$USERNAME ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/$USERNAME \
    && chmod 0440 /etc/sudoers.d/$USERNAME \
    && rm -rf /var/lib/apt/lists/*

USER $USERNAME
WORKDIR /home/$USERNAME/ros2-ws

# Install Oh My Zsh (unattended) + autosuggestions + syntax-highlighting plugins
RUN sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended \
    && git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc

# Configure ROS 2 Jazzy setup, argcomplete, and instant Zsh history saving
RUN echo 'source /opt/ros/jazzy/setup.zsh' >> ~/.zshrc \
    && echo 'if [ -f ~/ros2-ws/install/setup.zsh ]; then source ~/ros2-ws/install/setup.zsh; fi' >> ~/.zshrc \
    && echo 'eval "$(register-python-argcomplete ros2)"' >> ~/.zshrc \
    && echo 'eval "$(register-python-argcomplete colcon)"' >> ~/.zshrc \
    && echo 'export HISTFILE=~/.zsh_data/.zsh_history' >> ~/.zshrc \
    && echo 'setopt INC_APPEND_HISTORY' >> ~/.zshrc