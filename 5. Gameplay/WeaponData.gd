extends RefCounted
class_name WeaponData
# Player shot patterns. Each level returns a list of shots:
#   [angle in degrees (0 = straight up), x offset from the ship's nose, damage multiplier]
# When focusing, angles are squeezed together so more bullets land on one target.

enum Type { SPREAD, LANCE }

const MAX_LEVEL = 8

const NAMES = {Type.SPREAD: "Spread", Type.LANCE: "Lance"}

# Spread: wide coverage, bullets fan out
const SPREAD = [
	[[0, -11, 1.0], [0, 11, 1.0]],
	[[0, 0, 1.0], [-6, -8, 1.0], [6, 8, 1.0]],
	[[0, -10, 1.0], [0, 10, 1.0], [-9, -14, 0.9], [9, 14, 0.9]],
	[[0, 0, 1.0], [-7, -8, 1.0], [7, 8, 1.0], [-15, -14, 1.0], [15, 14, 1.0]],
	[[0, -10, 1.0], [0, 10, 1.0], [-8, -14, 1.0], [8, 14, 1.0], [-17, -18, 1.0], [17, 18, 1.0]],
	[[0, -10, 1.0], [0, 10, 1.0], [-8, -14, 1.0], [8, 14, 1.0], [-17, -18, 1.0], [17, 18, 1.0], [-75, -24, 0.8], [75, 24, 0.8]],
	[[0, 0, 1.0], [-6, -8, 1.0], [6, 8, 1.0], [-13, -14, 1.0], [13, 14, 1.0], [-21, -18, 1.0], [21, 18, 1.0]],
	[[0, -10, 1.0], [0, 10, 1.0], [-7, -14, 1.0], [7, 14, 1.0], [-15, -18, 1.0], [15, 18, 1.0], [-24, -22, 1.0], [24, 22, 1.0], [180, -14, 0.8], [180, 14, 0.8]],
]

# Lance: narrow parallel beams that pierce through enemies, higher damage per bullet
const LANCE = [
	[[0, -9, 1.2], [0, 9, 1.2]],
	[[0, 0, 1.2], [0, -18, 1.1], [0, 18, 1.1]],
	[[0, -9, 1.25], [0, 9, 1.25], [0, -27, 1.1], [0, 27, 1.1]],
	[[0, 0, 1.25], [0, -18, 1.2], [0, 18, 1.2], [-3, -36, 1.0], [3, 36, 1.0]],
	[[0, 0, 1.3], [0, -18, 1.2], [0, 18, 1.2], [0, -36, 1.1], [0, 36, 1.1]],
	[[0, -9, 1.3], [0, 9, 1.3], [0, -27, 1.2], [0, 27, 1.2], [-4, -45, 1.0], [4, 45, 1.0]],
	[[0, 0, 1.35], [0, -18, 1.3], [0, 18, 1.3], [0, -36, 1.2], [0, 36, 1.2], [-5, -52, 1.0], [5, 52, 1.0]],
	[[0, -9, 1.4], [0, 9, 1.4], [0, -27, 1.3], [0, 27, 1.3], [0, -45, 1.2], [0, 45, 1.2], [-6, -60, 1.0], [6, 60, 1.0]],
]

static func shots(type, level, focused):
	var table = SPREAD if type == Type.SPREAD else LANCE
	var list = table[clamp(level, 1, MAX_LEVEL) - 1]
	if not focused:
		return list
	var squeezed = []
	for s in list:
		var angle = s[0] if abs(s[0]) > 90 else s[0] * 0.3
		squeezed.append([angle, s[1] * 0.6, s[2]])
	return squeezed

static func pierces(type):
	return type == Type.LANCE

# Lance bullets are a little faster and longer
static func speed(type):
	return 1700.0 if type == Type.LANCE else 1500.0
