#!/usr/bin/env bash

GREEN='\033[0;32m'
RESET='\033[0m'

MODE=$1
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}}")" && pwd)"

# Add to ~/.bashrc for autocompletion
#_gROS_mishell_completion() {
#  local cur="${COMP_WORDS[COMP_CWORD]}"
#  COMPREPLY=( $(compgen -W "install-dependencies source build gazebo go-to-point basic-avoidance footprint-avoidance send-goal integrated-system" -- "$cur") )
#}
#complete -F _gROS_mishell_completion ./gROS-mishell.sh

if [ -z "$MODE" ]; then
  echo -e "${GREEN}gROS-mishell [ install-dependencies | source | build --debug (optional) | gazebo | go-to-point | basic-avoidance | footprint-avoidance | send-goal | integrated-system ]${RESET}"
elif [ "$MODE" == "install-dependencies" ]; then
  echo -e "${GREEN}Installing dependencies... (rclpy, geometry-msgs, launch, launch-ros, rse-msgs, tf-transformations, gazebo)!${RESET}"
  sudo apt install ros-jazzy-rclpy -y
  sudo apt install ros-jazzy-geometry-msgs -y
  sudo apt install ros-jazzy-launch-ros -y
  sudo apt install ros-jazzy-tf-transformations -y
  sudo apt install ros-jazzy-ros-gz -y
elif [ "$MODE" == "source" ]; then
  echo -e "${GREEN}To source in the current terminal, run '. ./gROS-mishell source' or 'source ./gROS-mishell source'!${RESET}"
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"
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
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"
  echo -e "${GREEN}Launching gazebo...${RESET}"
  ros2 launch a2_gazebo warehouse.launch.py
elif [ "$MODE" == "go-to-point" ]; then
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"
  echo -e "${GREEN}Launching go to point...${RESET}"
  ros2 launch a2_bringup part2_go_to_point.launch.py
elif [ "$MODE" == "basic-avoidance" ]; then
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"
  echo -e "${GREEN}Launching basic avoidance...${RESET}"
  ros2 launch a2_bringup part3_basic_avoidance.launch.py
elif [ "$MODE" == "footprint-avoidance" ]; then
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"
  echo -e "${GREEN}Launching footprint avoidance...${RESET}"
  ros2 launch a2_bringup part4_footprint_avoidance.launch.py
elif [ "$MODE" == "integrated-system" ]; then
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"
  echo -e "${GREEN}Launching integrated system...${RESET}"
  ros2 launch a2_bringup assignment.launch.py
elif [ "$MODE" == "send-goal" ]; then
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"

  PARAMS=$2

  if [ -z "$PARAMS" ]; then
    PARAMS="x: 0, y: 0, z: 0"
  fi

  echo -e "${GREEN}Sending /navigate_to_point new target: '${PARAMS}'${RESET}"

  ros2 action send_goal /navigate_to_point custom_action_interfaces/action/NavigateToPoint "{target: {${PARAMS}}}" --feedback
elif [ "$MODE" == "nav2" ]; then
  cd "$SCRIPT_DIR"
  source ../../install/setup.bash
  cd -
  echo -e "${GREEN}Sourced install/setup.bash!${RESET}"
  ros2 launch rse_nav2 office_nav.launch.py
fi
