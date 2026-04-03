#!/bin/bash
# spawn_r1.sh — Convert Galaxea R1 URDF and spawn it in the hotel Gazebo world

set -e

# === Config ===
URDF_REPO="https://github.com/userguide-galaxea/URDF.git"
CLONE_DIR="/tmp/galaxea_urdf"
MODEL_NAME="GalaxeaR1"
# Gazebo model output directory (alongside Caddy, DeliveryRobot, etc.)
MODEL_DIR="$HOME/rmf_ws/src/demonstrations/rmf_demos/rmf_demos_assets/models/${MODEL_NAME}"
# Spawn pose in hotel world (adjust as needed)
SPAWN_X=0.0
SPAWN_Y=0.0
SPAWN_Z=0.0
SPAWN_YAW=0.0
WORLD_NAME="hotel"

# === Step 1: Clone the URDF repo ===
if [ ! -d "$CLONE_DIR" ]; then
  echo "Cloning Galaxea URDF repo..."
  git clone --depth 1 "$URDF_REPO" "$CLONE_DIR"
fi

# === Step 2: Create Gazebo model directory ===
echo "Creating Gazebo model directory at $MODEL_DIR..."
mkdir -p "$MODEL_DIR/meshes"

# Copy meshes
cp "$CLONE_DIR/R1/meshes/"*.STL "$MODEL_DIR/meshes/"

# === Step 3: Fix mesh paths in URDF (package:// -> relative model://) ===
sed 's|package://r1_v2_1_0/meshes/|model://GalaxeaR1/meshes/|g' \
  "$CLONE_DIR/R1/urdf/r1_v2_1_0.urdf" > "$MODEL_DIR/r1.urdf"

# === Step 3b: Lock all joints to fixed so the robot doesn't collapse ===
sed -i 's|type="revolute"|type="fixed"|g; s|type="continuous"|type="fixed"|g; s|type="prismatic"|type="fixed"|g' \
  "$MODEL_DIR/r1.urdf"

# === Step 4: Convert URDF to SDF ===
echo "Converting URDF to SDF..."
gz sdf -p "$MODEL_DIR/r1.urdf" > "$MODEL_DIR/model.sdf"

# === Step 5: Create model.config ===
cat > "$MODEL_DIR/model.config" <<EOF
<?xml version="1.0"?>
<model>
  <name>${MODEL_NAME}</name>
  <version>1.0</version>
  <sdf version="1.9">model.sdf</sdf>
  <description>Galaxea R1 humanoid robot</description>
</model>
EOF

echo "Model created at $MODEL_DIR"

# === Step 6: Spawn in Gazebo ===
export GZ_SIM_RESOURCE_PATH="${GZ_SIM_RESOURCE_PATH}:$(dirname "$MODEL_DIR")"

echo "Spawning ${MODEL_NAME} in ${WORLD_NAME} world..."

# Convert yaw to quaternion (w=cos(yaw/2), z=sin(yaw/2))
W=$(python3 -c "import math; print(math.cos(${SPAWN_YAW}/2))")
Z=$(python3 -c "import math; print(math.sin(${SPAWN_YAW}/2))")

gz service -s "/world/${WORLD_NAME}/create" \
  --reqtype gz.msgs.EntityFactory \
  --reptype gz.msgs.Boolean \
  --timeout 5000 \
  --req "sdf_filename: '${MODEL_NAME}/model.sdf', name: 'r1', pose: {position: {x: ${SPAWN_X}, y: ${SPAWN_Y}, z: ${SPAWN_Z}}, orientation: {x: 0, y: 0, z: ${Z}, w: ${W}}}"

echo "Done! Galaxea R1 spawned in ${WORLD_NAME} world."
