extends RefCounted
class_name Patterns
# Bullet pattern library. Every function fires one "volley" into the BulletField.
# Enemies call these on a timer (see Enemy.gd attacks), bosses combine them into phases.
# Angles are in degrees, 90 = straight down the screen.

const RED = Color(1.0, 0.25, 0.3)
const PINK = Color(1.0, 0.35, 0.8)
const ORANGE = Color(1.0, 0.6, 0.15)
const CYAN = Color(0.3, 0.9, 1.0)
const PURPLE = Color(0.7, 0.4, 1.0)
const GREEN = Color(0.45, 1.0, 0.45)


static func _shoot(field, origin: Vector2, angleDeg: float, speed: float, opts):
	field.spawnEnemyBullet(origin, Vector2.from_angle(deg_to_rad(angleDeg)) * speed, opts)


# count bullets aimed at the target, fanned out over spreadDeg
static func aimed(field, origin: Vector2, target: Vector2, speed: float, count = 1, spreadDeg = 0.0, opts = {}):
	var center = rad_to_deg((target - origin).angle())
	fan(field, origin, center, count, spreadDeg, speed, opts)

# count bullets spread evenly over arcDeg around centerDeg
static func fan(field, origin: Vector2, centerDeg: float, count: int, arcDeg: float, speed: float, opts = {}):
	if count <= 1:
		_shoot(field, origin, centerDeg, speed, opts)
		return
	for i in range(count):
		var a = centerDeg - arcDeg / 2.0 + arcDeg * i / float(count - 1)
		_shoot(field, origin, a, speed, opts)

# full circle; offsetDeg rotates the ring (spirals = rings with a moving offset)
static func ring(field, origin: Vector2, count: int, speed: float, offsetDeg = 0.0, opts = {}):
	for i in range(count):
		_shoot(field, origin, offsetDeg + 360.0 * i / count, speed, opts)

# full circle with a gap facing the target - forces the player to move into the gap
static func ringWithGap(field, origin: Vector2, target: Vector2, count: int, speed: float, gapDeg = 50.0, opts = {}):
	var gapCenter = rad_to_deg((target - origin).angle())
	for i in range(count):
		var a = 360.0 * i / count
		if abs(wrapf(a - gapCenter, -180.0, 180.0)) > gapDeg / 2.0:
			_shoot(field, origin, a, speed, opts)

# horizontal line of bullets falling down, with one gap you have to find
static func wall(field, y: float, width: float, gapX: float, gapWidth: float, speed: float, spacing = 46.0, opts = {}):
	var x = spacing / 2.0
	while x < width:
		if abs(x - gapX) > gapWidth / 2.0:
			field.spawnEnemyBullet(Vector2(x, y), Vector2(0, speed), opts)
		x += spacing

# bullets that fly out slowly, stop, then snap towards the player
static func snapRing(field, origin: Vector2, count: int, speed: float, waitTime: float, snapSpeed: float, offsetDeg = 0.0, opts = {}):
	var o = opts.duplicate()
	o["accel"] = -speed / waitTime
	o["minSpeed"] = 0.0
	o["wait"] = waitTime
	o["waitSpeed"] = snapSpeed
	ring(field, origin, count, speed, offsetDeg, o)
