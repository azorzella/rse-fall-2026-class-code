"""Student exercise: validate, transform, and visualize a detection.

Complete TODO 1, TODO 2, and TODO 3. The unfinished node launches safely
and receives messages, but intentionally publishes no output.
"""

import rclpy
import tf2_geometry_msgs  # noqa: F401; registers PoseStamped with TF2
from geometry_msgs.msg import PoseStamped
from rclpy.duration import Duration
from rclpy.node import Node
from rclpy.qos import qos_profile_sensor_data
from rclpy.time import Time
from tf2_ros import Buffer, TransformException, TransformListener
from visualization_msgs.msg import Marker


class DetectionToMarker(Node):
    def __init__(self):
        super().__init__('detection_to_marker')
        defaults = {
            'input_topic': '/fiducial_pose/camera',
            'output_pose_topic': '/fiducial_pose/map',
            'marker_topic': '/fiducial_marker',
            'target_frame': 'map',
            'max_detection_age': 0.5,
            'marker_namespace': 'fiducial_detections',
            'marker_id': 0,
            'marker_size': 0.20,
            'marker_lifetime': 0.5,
        }
        for name, value in defaults.items():
            self.declare_parameter(name, value)

        self.target_frame = self.get_parameter('target_frame').value
        self.max_detection_age = self.get_parameter('max_detection_age').value
        self.marker_namespace = self.get_parameter('marker_namespace').value
        self.marker_id = self.get_parameter('marker_id').value
        self.marker_size = self.get_parameter('marker_size').value
        self.marker_lifetime = self.get_parameter('marker_lifetime').value

        self.tf_buffer = Buffer(node=self)
        self.tf_listener = TransformListener(self.tf_buffer, self)
        self.pose_publisher = self.create_publisher(
            PoseStamped, self.get_parameter('output_pose_topic').value, 10)
        self.marker_publisher = self.create_publisher(
            Marker, self.get_parameter('marker_topic').value, 10)
        self.subscription = self.create_subscription(
            PoseStamped, self.get_parameter('input_topic').value,
            self.detection_callback, qos_profile_sensor_data)

        # A timer retries the newest observation if the matching TF arrives
        # just after the pose message. TF calls must be nonblocking here so
        # this single-threaded executor can continue receiving /tf messages.
        self.pending_detection = None
        self.received_first_detection = False
        self.timer = self.create_timer(0.05, self.process_pending_detection)
        self.get_logger().info(
            'Starter running. Complete TODOs 1-3 to enable pose and Marker output.')

    def detection_callback(self, detection):
        if not self.received_first_detection:
            self.get_logger().info('Received first camera-frame detection.')
            self.received_first_detection = True
        self.pending_detection = detection

    def process_pending_detection(self):
        detection = self.pending_detection
        if detection is None:
            return
        if not self.detection_is_valid(detection):
            self.pending_detection = None
            return

        transformed_pose = self.transform_to_target(detection)
        if transformed_pose is None:
            return

        # Publish each observation once; do not keep refreshing a stale Marker.
        self.pending_detection = None
        self.pose_publisher.publish(transformed_pose)
        marker = self.make_marker(transformed_pose)
        if marker is not None:
            self.marker_publisher.publish(marker)

    def detection_is_valid(self, detection):
        """TODO 1: return True only for a recent, stamped, framed detection.

        - Reject an empty header.frame_id.
        - Reject a zero timestamp (our exercise requires a measurement time).
        - Compute age using Time.from_msg(detection.header.stamp) and
          self.get_clock().now(). Both use ROS time; use_sim_time must match.
        - Accept ages between 0.0 and self.max_detection_age seconds.
        - nanoseconds / 1e9 converts a duration to seconds.
        """
        return False  # Replace this placeholder.

    def transform_to_target(self, detection):
        """TODO 2: return a PoseStamped expressed in self.target_frame.

        Call self.tf_buffer.transform with the original stamped detection,
        self.target_frame, and timeout=Duration(seconds=0.0).
        Preserve the measurement timestamp. Do not use the latest transform
        or simply change frame_id. The timer retries unavailable transforms.
        """
        try:
            return None  # Replace with the TF2 transform call.
        except TransformException as error:
            self.get_logger().warning(
                f'Waiting for transform: {error}', throttle_duration_sec=2.0)
            return None

    def make_marker(self, transformed_pose):
        """TODO 3: construct and return a visualization_msgs/Marker.

        - Copy transformed_pose.header and transformed_pose.pose.
        - Set ns=self.marker_namespace and id=self.marker_id.
        - Use Marker.CUBE and Marker.ADD.
        - Set scale.x and scale.y to self.marker_size, scale.z to 0.02.
        - Choose RGB values in [0, 1] and set color.a=1.0.
        - Set lifetime=Duration(seconds=self.marker_lifetime).to_msg().

        The cube lies in the tag's local XY plane. Keep its orientation.
        A lifetime of zero means it persists until deleted or overwritten.
        """
        return None  # Replace with a populated Marker.


def main(args=None):
    rclpy.init(args=args)
    node = DetectionToMarker()
    try:
        rclpy.spin(node)
    except KeyboardInterrupt:
        pass
    finally:
        node.destroy_node()
        if rclpy.ok():
            rclpy.shutdown()
