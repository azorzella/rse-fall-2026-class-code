#!/usr/bin/env bash

# gROS-mishell should live in the repo root, i.e. parent_folder/rse_ws/src/repo_root/gROS-mishell
# It's written in a way that allows its commands to be run from any folder as it navigates to this directory that holds this script and
# runs code relative to that, navigating back to the directory that the command was run from. 
#
# Add the following code to ~/.bashrc for autocompletio (remember to source ~/.bashrc from the same terminal you edit it from)
#
#_gROS_mishell_completion() {
#  local cur="${COMP_WORDS[COMP_CWORD]}"
#  COMPREPLY=( $(compgen -W "install-dependencies source build launch-gazebo launch-gazebo-office launch-office-nav launch-perceptron" -- "$cur") )
#}
#complete -F _gROS_mishell_completion ./gROS-mishell.sh

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

export GROS_AUTOBUILD='0'
# Enable proper runtime parameter validation for ROS2 interfaces 
export ROS_PYTHON_CHECK_FIELDS='1'

MODE=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}}")" && pwd)"

source_env() {
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"
}

if [ -n "$MODE" ] && [ "$MODE" != "build" ] && [ "$MODE" != "install-dependencies" ]; then
  if [ -d "${SCRIPT_DIR}/../../install/setup.bash" ]; then
    source_env
  else
    if [ $GROS_AUTOBUILD ]; then
      echo -e "${YELLOW}This project hasn't been built yet. Autobuilding...${RESET}"
      echo -e "${YELLOW}(GROS_AUTOBUILD is enabled. To disable autobuild, set GROS_AUTOBUILD='0')${RESET}"
    else
      echo -e "${YELLOW}This project hasn't been built yet. Run ./gROS-mishell build or set the GROS_AUTOBUILD environment variable and run the command again${RESET}"
    fi
  fi
fi

if [ -z "$MODE" ]; then
  echo -e "${GREEN}gROS-mishell [ install-dependencies | source | build | build-debug | build-clean | launch-gazebo | launch-gazebo-office | launch-office-nav | launch-perceptron ]${RESET}"
elif [ "$MODE" == "install-dependencies" ]; then
  echo -e "${GREEN}Installing dependencies... (rclpy, geometry-msgs, launch, launch-ros, tf-transformations, gaezbo, nav2, apriltag)!${RESET}"
  sudo apt install ros-jazzy-rclpy ros-jazzy-geometry-msgs ros-jazzy-launch-ros ros-jazzy-tf-transformations ros-jazzy-ros-gz ros-jazzy-nav2-bringup ros-jazzy-apriltag -y
elif [ "$MODE" == "source" ]; then
  echo -e "${GREEN}To source in the current terminal, run 'source ./gROS-mishell'!${RESET}"
elif [ "$MODE" == "build" ]; then
    echo -e "${GREEN}Building packages using colcon!${RESET}"
    cd "$SCRIPT_DIR"
    cd ../..
    colcon build --symlink-install --cmake-args -DPython3_EXECUTABLE=/usr/bin/python3
    cd -
    echo -e "${GREEN}Remember to source install/setup.bash!${RESET}"
elif [ "$MODE" == "build-debug" ]; then
    echo -e "${GREEN}Building packages using colon (-DCMAKE_BUILD_TYPE enabled)!${RESET}"
    cd "$SCRIPT_DIR"
    cd ../..
    colcon build --symlink-install --cmake-args -DPython3_EXECUTABLE=/usr/bin/python3 -DCMAKE_BUILD_TYPE=DEBUG
    cd -
    echo -e "${GREEN}Remember to source install/setup.bash!${RESET}"
elif [ "$MODE" == "build-clean" ]; then
    echo -e "${GREEN}Deleting /build/, /install/, and /log/...${RESET}"
    cd "$SCRIPT_DIR"
    cd ../..
    rm -r build install log
    cd -
elif [ "$MODE" == "gazebo" ]; then
  echo -e "${GREEN}Launching gazebo...${RESET}"
  ros2 launch rse_gazebo warehouse.launch.py
elif [ "$MODE" == "gazebo-office" ]; then
  echo -e "${GREEN}Launching gazebo...${RESET}"
  ros2 launch rse_gazebo office.launch.py
elif [ "$MODE" == "launch-office-nav" ]; then
  ros2 launch rse_nav2 office_nav.launch.py
elif [ "$MODE" == "launch-perceptron" ]; then
  ros2 launch rse_perceptron perceptron.launch.py
fi