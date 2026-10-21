"""Start the exercise; simulator, localization, and detector run separately."""

import os

from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.conditions import IfCondition
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node
from launch_ros.parameter_descriptions import ParameterValue


def generate_launch_description():
    default_config = os.path.join(
        get_package_share_directory('rse_perception'), 'config', 'perception.yaml')
    parameters = [
        LaunchConfiguration('params_file'),
        {'use_sim_time': ParameterValue(
            LaunchConfiguration('use_sim_time'), value_type=bool)},
    ]
    return LaunchDescription([
        DeclareLaunchArgument('use_sim_time', default_value='true'),
        DeclareLaunchArgument('params_file', default_value=default_config),
        DeclareLaunchArgument(
            'start_adapter', default_value='true',
            description='Disable if a camera-frame PoseStamped is already supplied.'),
        Node(
            package='rse_perception', executable='apriltag_pose_adapter',
            name='apriltag_pose_adapter', parameters=parameters, output='screen',
            condition=IfCondition(LaunchConfiguration('start_adapter'))),
        Node(
            package='rse_perception', executable='detection_to_marker',
            name='detection_to_marker', parameters=parameters, output='screen'),
    ])
