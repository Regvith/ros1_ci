FROM osrf/ros:noetic-desktop-full-focal

# Locale
ENV LANG C.UTF-8
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

# Install dependencies
RUN set -x \
    && apt-get update \
    && apt-get --with-new-pkgs upgrade -y \
    && apt-get install -y git \
    && apt-get install -y \
        ros-noetic-turtlebot3 \
        ros-noetic-turtlebot3-bringup \
        ros-noetic-turtlebot3-description \
        ros-noetic-turtlebot3-example \
        ros-noetic-turtlebot3-gazebo \
        ros-noetic-turtlebot3-msgs \
        ros-noetic-turtlebot3-navigation \
        ros-noetic-turtlebot3-simulations \
        ros-noetic-turtlebot3-slam \
        ros-noetic-turtlebot3-teleop \
        ros-noetic-gmapping \
        ros-noetic-slam-gmapping \
        ros-noetic-openslam-gmapping \
    && rm -rf /var/lib/apt/lists/*

# Fix python symlink
RUN ln -s /usr/bin/python3 /usr/bin/python

# Setup workspace
RUN mkdir -p /root/simulation_ws/src
WORKDIR /root/simulation_ws

# Copy local TortoiseBot simulation package into src/
COPY tortoisebot ./src/tortoisebot

# Clone your waypoints package (replace with your repo URL if needed)
RUN git clone https://github.com/Regvith/tortoisebot_waypoints.git src/tortoisebot_waypoints

# Install dependencies and build
RUN rosdep update \
    && rosdep install --from-paths src --ignore-src -r -y \
    && /bin/bash -c "source /opt/ros/noetic/setup.bash && catkin_make"

# Source workspace on container start
RUN echo "source /opt/ros/noetic/setup.bash" >> /root/.bashrc \
    && echo "source /root/simulation_ws/devel/setup.bash" >> /root/.bashrc

CMD ["bash"]
