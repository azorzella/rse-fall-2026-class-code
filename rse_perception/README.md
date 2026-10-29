# rse_perception: transformed detections and RViz Markers

Student starter for lecture [8][1]. Complete the three TODOs in
`rse_perception/detection_to_marker.py`. No navigation or search behavior is
required. The unmodified starter launches and receives input, but deliberately
publishes no result.

## Data path

1. `apriltag_ros` publishes a new camera-to-tag transform on `/tf`.
2. The provided `apriltag_pose_adapter` republishes each matching observation
   as a camera-frame `geometry_msgs/PoseStamped` on `/fiducial_pose/camera`.
3. Your `detection_to_marker` validates that observation, transforms it into
   `map`, and publishes `/fiducial_pose/map` and `/fiducial_marker`.

The adapter listens for new measurements instead of polling the TF cache, so
an old transform does not become a new detection. It assumes the detector is
the only publisher of the configured tag frame. Do not publish a static TF
for the same tag. The input pose preserves the detector's frame and timestamp.
The detector's `/detections` metadata array does not contain the pose expected
by this exercise.

## Build

Copy this package directory alongside the other packages in the class-code
repository under your ROS workspace's `src` directory.

From the workspace root:

```bash
source /opt/ros/jazzy/setup.bash
rosdep install --from-paths src --ignore-src -r -y
colcon build --symlink-install --packages-select rse_perception
source install/setup.bash
```

## Start the simulator and detector

Start the course simulator, camera bridge, and localization separately. The
transform chain must connect the camera optical frame to `map`. If the sim
only supplies `odom`, use `odom` as the target frame and rename the output
topic in the config; do not invent a map-to-odom transform just to hide an error.

Example detector command (adjust topics, family, ID, and measured tag size):

```bash
ros2 run apriltag_ros apriltag_node --ros-args \
  -r image_rect:=/camera/image_rect \
  -r camera_info:=/camera/camera_info \
  -p family:=36h11 \
  -p size:=0.20 \
  -p 'tag.ids:=[0]' \
  -p 'tag.frames:=[tag_0]' \
  -p use_sim_time:=true
```

Use a rectified image with matching CameraInfo timestamps. A raw simulated
image can substitute only when the camera model is distortion-free and its
calibration matches. Tag size must follow the detector's size convention.
Install `ros-jazzy-apriltag-ros` separately if needed; the starter itself does
not launch the detector or require its message package.

## Run the exercise

```bash
ros2 launch rse_perception perception.launch.py
```

Defaults appear in `config/perception.yaml`. For a customized copy:

```bash
ros2 launch rse_perception perception.launch.py \
  params_file:=/absolute/path/to/perception.yaml
```

If another node already publishes the camera-frame PoseStamped, disable the
adapter and set `input_topic` in your config:

```bash
ros2 launch rse_perception perception.launch.py start_adapter:=false
```

For a real camera, set `use_sim_time:=false` consistently for every node.

## TODOs

1. **Validate the observation:** reject empty frames, zero timestamps,
   future timestamps, and observations older than `max_detection_age`.
2. **Transform:** use the original measurement time and `target_frame`.
   Use a zero timeout; the provided timer retries if TF arrives slightly later.
3. **Create the Marker:** copy the transformed header and pose, choose visible
   dimensions and color, use stable namespace/ID, and set the configured lifetime.

The callback stores the newest observation. A timer processes it without
blocking reception of TF. Each successfully transformed observation publishes
once. The PoseStamped can work before the Marker TODO is complete.

Imports needed for all three TODOs are supplied, including
`tf2_geometry_msgs`, which registers PoseStamped transformation support.

## Inspect and verify

```bash
ros2 topic echo /fiducial_pose/camera --once
ros2 topic echo /fiducial_pose/map --once
ros2 topic info /fiducial_marker
ros2 run tf2_ros tf2_echo map tag_0
```

In RViz, set Fixed Frame to `map`, add a Pose display for
`/fiducial_pose/map`, and add a Marker display for `/fiducial_marker`.

- Keep robot and tag still: both outputs should remain approximately stable.
- Keep the tag fixed and move the robot: camera coordinates should change,
  while the map pose should remain approximately fixed.
- Hide the tag: input/output updates should stop and the Marker should expire.
- Reopen RViz or re-enable its display while the tag is visible to receive a
  new observation. Publishers use volatile durability; they do not latch history.

After the core exercise works, try one fault at a time: alpha zero, an
incorrect frame label, a new ID per observation, or zero Marker lifetime.
Predict the symptom, inspect it, and restore the correct implementation.

Changing `header.frame_id` alone never transforms the coordinates. A Marker
that RViz can display is not a substitute for the transformed PoseStamped.

## References

- Detector interface: https://github.com/christianrauch/apriltag_ros
- TF2 Python tutorials: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/Tf2/Tf2-Main.html
- Marker display: https://docs.ros.org/en/jazzy/Tutorials/Intermediate/RViz/Marker-Display-types/Marker-Display-types.html
