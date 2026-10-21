"""Provided plumbing: convert new AprilTag TF messages into PoseStamped input.

apriltag_ros publishes tag poses on /tf, rather than in its detection array.
Listen to each new measurement instead of polling a cached latest transform.
No student TODOs in this file.
"""

from copy import deepcopy

import rclpy
from geometry_msgs.msg import PoseStamped
from rclpy.node import Node
from rclpy.qos import qos_profile_sensor_data
from tf2_msgs.msg import TFMessage


class AprilTagPoseAdapter(Node):
    def __init__(self):
        super().__init__('apriltag_pose_adapter')
        self.declare_parameter('tag_frame', 'tag_0')
        self.declare_parameter('tf_topic', '/tf')
        self.declare_parameter('output_topic', '/fiducial_pose/camera')

        self.tag_frame = self.get_parameter('tag_frame').value
        self.publisher = self.create_publisher(
            PoseStamped, self.get_parameter('output_topic').value, 10)
        self.subscription = self.create_subscription(
            TFMessage, self.get_parameter('tf_topic').value,
            self.tf_callback, qos_profile_sensor_data)
        self.get_logger().info(f'Waiting for new TF measurements of {self.tag_frame}')

    def tf_callback(self, message):
        for transform in message.transforms:
            if transform.child_frame_id != self.tag_frame:
                continue

            pose = PoseStamped()
            pose.header = deepcopy(transform.header)
            translation = transform.transform.translation
            pose.pose.position.x = translation.x
            pose.pose.position.y = translation.y
            pose.pose.position.z = translation.z
            pose.pose.orientation = deepcopy(transform.transform.rotation)
            self.publisher.publish(pose)


def main(args=None):
    rclpy.init(args=args)
    node = AprilTagPoseAdapter()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        if rclpy.ok():
            rclpy.shutdown()
