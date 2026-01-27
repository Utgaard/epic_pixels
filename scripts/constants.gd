class_name Constants
extends RefCounted

## Global constants for Epic Pixels 2D

# Viewport dimensions
const VIEWPORT_WIDTH: int = 640
const VIEWPORT_HEIGHT: int = 360

# Ground level (Y coordinate where infantry walk)
# Sprite offset (-16) + half height (24) = +8, so unit.Y + 8 = feet position
# Ground rect top = 300, so GROUND_Y = 300 - 8 = 292
const GROUND_Y: float = 292.0

# Spawn positions
const SPAWN_LEFT_X: float = 50.0
const SPAWN_RIGHT_X: float = 590.0

# Infantry lane boundaries
const INFANTRY_LANE_TOP: float = 260.0
const INFANTRY_LANE_BOTTOM: float = 300.0
