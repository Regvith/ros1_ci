FROM osrf/ros:noetic-desktop-full-focal

# Locale
ENV LANG C.UTF-8
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install dependencies
# Core tools, test utilities, headless GUI bits, and clean python alternative
# (Note: we don't need the TurtleBot3 stacks for TortoiseBot)
RUN set -x \
    && apt-get update \
    && apt-get --with-new-pkgs upgrade -y \
    && apt-get install -y \
        git \
        python3-rosdep python3-pip python-is-python3 \
        ros-noetic-rostest \
        ros-noetic-gazebo-ros-pkgs ros-noetic-gazebo-ros-control \
        xvfb x11-apps \
    && rm -rf /var/lib/apt/lists/*

# Helpful for headless rendering in CI/containers without GPU
ENV LIBGL_ALWAYS_SOFTWARE=1
# Fix python symlink

# Setup workspace
RUN mkdir -p /root/simulation_ws/src
WORKDIR /root/simulation_ws/src

# Copy local TortoiseBot simulation package into src/
WORKDIR /root/simulation_ws/src
RUN mkdir -p tortoisebot
RUN git clone https://github.com/Regvith/tortoisebot.git tortoisebot
RUN mkdir -p tortoisebot_waypoints

# Clone your waypoints package (replace with your repo URL if needed)
RUN git clone https://github.com/Regvith/tortoisebot_waypoints.git tortoisebot_waypoints
WORKDIR /root/simulation_ws/
# Install dependencies and build
RUN  /bin/bash -c " cd /root/simulation_ws/ && source /opt/ros/noetic/setup.bash && catkin_make"


# Source workspace on container start
RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc \
    && echo "source /root/simulation_ws/devel/setup.bash" >> /root/.bashrc

CMD ["bash"]
