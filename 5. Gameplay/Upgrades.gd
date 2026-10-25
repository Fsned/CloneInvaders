extends RefCounted
class_name Upgrades
# The upgrade cards offered by the 1-of-3 picker. Add a card: put its id in IDS,
# then handle it in available(), title(), describe() and apply().

const IDS = ["weapon", "switch", "rate", "power", "hull", "repair", "engine", "magnet", "missile", "bomb"]

const MAX_FIRE_RATE = 2.2
const MAX_ENGINE_SPEED = 760.0
const MAX_MAGNET = 520.0

# weight 0 = not offered right now
static func weight(id, p):
	match id:
		"weapon": return 5.0 if p.weaponLevel < WeaponData.MAX_LEVEL else 0.0
		"switch": return 1.2 if p.weaponLevel >= 2 else 0.0
		"rate": return 2.5 if p.fireRateMult < MAX_FIRE_RATE else 0.0
		"power": return 2.0
		"hull": return 2.0 if p.maxHull < 8 else 0.0
		"repair": return 3.0 if p.hull < p.maxHull else 0.0
		"engine": return 1.0 if p.moveSpeed < MAX_ENGINE_SPEED else 0.0
		"magnet": return 1.0 if p.magnetRadius < MAX_MAGNET else 0.0
		"missile": return 1.8 if p.missileLevel < 3 else 0.0
		"bomb": return 1.0 if p.bombs < p.maxBombs else 0.0
	return 0.0

static func title(id, p):
	match id:
		"weapon": return "%s Lv %d" % [WeaponData.NAMES[p.weaponType], p.weaponLevel + 1]
		"switch": return "Switch to " + ("Lance" if p.weaponType == WeaponData.Type.SPREAD else "Spread")
		"rate": return "Rapid Fire"
		"power": return "Heavy Rounds"
		"hull": return "Reinforced Hull"
		"repair": return "Field Repair"
		"engine": return "Thrusters"
		"magnet": return "Scrap Magnet"
		"missile": return "Homing Missiles Lv %d" % (p.missileLevel + 1)
		"bomb": return "+1 Bomb"
	return id

static func describe(id, p):
	match id:
		"weapon": return "More bullets in your shot pattern."
		"switch":
			if p.weaponType == WeaponData.Type.SPREAD:
				return "Narrow beams that pierce through enemies. Keeps level %d." % p.weaponLevel
			return "Wide fan of bullets that covers the screen. Keeps level %d." % p.weaponLevel
		"rate": return "Fire 15% faster."
		"power": return "All your bullets deal 20% more damage."
		"hull": return "+1 max hull and repair 1. (%d -> %d)" % [p.maxHull, p.maxHull + 1]
		"repair": return "Repair your hull to full. (%d/%d)" % [p.hull, p.maxHull]
		"engine": return "Move 12% faster."
		"magnet": return "Pull in scrap from further away."
		"missile": return "Fire homing missiles that seek out enemies." if p.missileLevel == 0 else "Fire homing missiles more often."
		"bomb": return "Bombs clear every enemy bullet on screen. (%d/%d)" % [p.bombs, p.maxBombs]
	return ""

static func apply(id, p):
	match id:
		"weapon": p.weaponLevel = min(p.weaponLevel + 1, WeaponData.MAX_LEVEL)
		"switch": p.weaponType = WeaponData.Type.LANCE if p.weaponType == WeaponData.Type.SPREAD else WeaponData.Type.SPREAD
		"rate": p.fireRateMult = min(p.fireRateMult * 1.15, MAX_FIRE_RATE)
		"power": p.damageMult *= 1.2
		"hull":
			p.maxHull += 1
			p.hull = min(p.hull + 1, p.maxHull)
			p.emit_signal("hullChanged", p.hull, p.maxHull)
		"repair":
			p.hull = p.maxHull
			p.emit_signal("hullChanged", p.hull, p.maxHull)
		"engine": p.moveSpeed = min(p.moveSpeed * 1.12, MAX_ENGINE_SPEED)
		"magnet": p.magnetRadius = min(p.magnetRadius + 90.0, MAX_MAGNET)
		"missile": p.missileLevel = min(p.missileLevel + 1, 3)
		"bomb":
			p.bombs = min(p.bombs + 1, p.maxBombs)
			p.emit_signal("bombsChanged", p.bombs)

# Pick `count` different cards, weighted
static func roll(p, count = 3):
	var pool = {}
	for id in IDS:
		var w = weight(id, p)
		if w > 0.0:
			pool[id] = w
	var picks = []
	while picks.size() < count and not pool.is_empty():
		var total = 0.0
		for id in pool: total += pool[id]
		var r = randf() * total
		for id in pool:
			r -= pool[id]
			if r <= 0.0:
				picks.append(id)
				pool.erase(id)
				break
	return picks
