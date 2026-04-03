# Multi Floor Reasoning Agent Idea Demo

## Init
```
source /opt/ros/kilted/setup.bash
source ~/rmf_ws/install/setup.bash
```

## Launch
```
ros2 launch rmf_demos common.launch.xml \
  use_sim_time:=true \
  viz_config_file:=$(ros2 pkg prefix rmf_demos)/share/rmf_demos/include/hotel/hotel.rviz \
  config_file:=$(ros2 pkg prefix rmf_demos_maps)/share/rmf_demos_maps/hotel/hotel.building.yaml
ros2 launch rmf_demos_gz simulation.launch.xml map_name:=hotel headless:=false
```

## Spawn Robot
```
export GZ_SIM_RESOURCE_PATH=$GZ_SIM_RESOURCE_PATH:$(ros2 pkg prefix rmf_demos_assets)/share/rmf_demos_assets/models
gz service -s /world/sim_world/create \
    --reqtype gz.msgs.EntityFactory \
    --reptype gz.msgs.Boolean \
    --timeout 5000 \
    --req "sdf_filename: 'GalaxeaR1/model_static.sdf', name: 'r1', pose: {position: {x: 20, y: -32, z: 0}, orientation: {x: 0, y: 0, z: 0, w: 1}}"
```

## CLI Control
```
ros2 run ros_gz_bridge parameter_bridge /model/r1/cmd_vel@geometry_msgs/msg/Twist]gz.msgs.Twist
ros2 run teleop_twist_keyboard teleop_twist_keyboard --ros-args -r /cmd_vel:=/model/r1/cmd_vel

ros2 topic pub /adapter_door_requests rmf_door_msgs/msg/DoorRequest "{door_name: 'L1_door1', requested_mode: {value: 0}, requester_id: 'manual', request_time: {sec: 0}}" --once 
```

## Camera
```
ros2 run ros_gz_bridge parameter_bridge /model/r1/chest_camera@sensor_msgs/msg/Image[gz.msgs.Image
```