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

MODE=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}}")" && pwd)"

source_env() {
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"
}

# Enable proper runtime parameter validation for ROS2 interfaces 
export ROS_PYTHON_CHECK_FIELDS='1'
source_env

if [ -z "$MODE" ]; then
  echo -e "${GREEN}gROS-mishell [ install-dependencies | source | build --debug (optional) | launch-gazebo | launch-gazebo-office | launch-office-nav | launch-perceptron ]${RESET}"
elif [ "$MODE" == "install-dependencies" ]; then
  echo -e "${GREEN}Installing dependencies... (rclpy, geometry-msgs, launch, launch-ros, tf-transformations, gaezbo, nav2, apriltag)!${RESET}"
  sudo apt install ros-jazzy-rclpy ros-jazzy-geometry-msgs ros-jazzy-launch-ros ros-jazzy-tf-transformations ros-jazzy-ros-gz ros-jazzy-nav2-bringup ros-jazzy-apriltag -y
elif [ "$MODE" == "source" ]; then
  echo -e "${GREEN}To source in the current terminal, run 'source ./gROS-mishell'!${RESET}"
elif [ "$MODE" == "build" ]; then
  DEBUG=$2

  if [ -z "$DEBUG" ]; then
    echo -e "${GREEN}Building packages using colcon!${RESET}"
    cd "$SCRIPT_DIR"
    cd ../..
    colcon build --symlink-install --cmake-args -DPython3_EXECUTABLE=/usr/bin/python3
    cd -
    echo -e "${GREEN}Remember to source install/setup.bash!${RESET}"
  else
    echo -e "${GREEN}Building packages using colon (debug enabled)!${RESET}"
    cd "$SCRIPT_DIR"
    cd ../..
    colcon build --symlink-install --cmake-args -DPython3_EXECUTABLE=/usr/bin/python3 -DCMAKE_BUILD_TYPE=DEBUG
    cd -
    echo -e "${GREEN}Remember to source install/setup.bash!${RESET}"
  fi
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