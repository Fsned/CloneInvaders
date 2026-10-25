extends RefCounted
class_name EnemyTypes
# Stats and attacks for every enemy. Tweak balance here.
#
#   tex / scale / tint / faceDown   look (Kenney sprites point up, so most are flipped to face down)
#   hp, radius                      health and hit circle (px)
#   score, scrap                    points and scrap pieces dropped on death
#   contact                         touching it hurts the player (always true, listed for clarity)
#   kamikaze                        dies when it rams the player
#   blocksBullets                   absorbs bullets from both sides (cover)
#   attacks                         list of timed patterns, see Enemy._fireAttack()
#       pattern: aimed | fan | ring | ringGap | spiral | snapRing
#       every: seconds between volleys, delay: before the first one
#       burst/burstGap: repeat the volley n times quickly

const RED = Color(1.0, 0.25, 0.3)
const PINK = Color(1.0, 0.35, 0.8)
const ORANGE = Color(1.0, 0.6, 0.15)
const CYAN = Color(0.3, 0.9, 1.0)
const PURPLE = Color(0.75, 0.45, 1.0)
const GREEN = Color(0.45, 1.0, 0.45)

const TYPES = {
	"grunt": {
		"tex": "res://1. GFX/Spaceships/Enemy1.png", "scale": 2.2, "tint": Color(1, 1, 1), "faceDown": false,
		"hp": 20, "radius": 30, "score": 100, "scrap": 1,
		"attacks": [{"pattern": "aimed", "every": 3.0, "delay": 1.4, "speed": 340, "count": 1, "color": RED}],
	},
	"weaver": {
		"tex": "res://1. GFX/Kenney/PNG/Retina/enemy_B.png", "scale": 0.55, "tint": CYAN, "faceDown": true,
		"hp": 45, "radius": 32, "score": 150, "scrap": 2,
		"attacks": [{"pattern": "fan", "every": 2.2, "delay": 0.9, "speed": 300, "count": 3, "arc": 36, "color": CYAN}],
	},
	"diver": {
		"tex": "res://1. GFX/Kenney/PNG/Retina/enemy_A.png", "scale": 0.5, "tint": ORANGE, "faceDown": true,
		"hp": 25, "radius": 28, "score": 120, "scrap": 1, "kamikaze": true,
		"attacks": [{"pattern": "aimed", "every": 99, "delay": 0.5, "speed": 420, "count": 3, "spread": 24, "color": ORANGE}],
	},
	"spinner": {
		"tex": "res://1. GFX/Kenney/PNG/Retina/station_A.png", "scale": 0.75, "tint": PURPLE, "faceDown": false, "spin": 2.5,
		"hp": 180, "radius": 44, "score": 400, "scrap": 4,
		"attacks": [{"pattern": "spiral", "every": 0.16, "delay": 0.6, "speed": 230, "arms": 3, "step": 14, "color": PURPLE}],
	},
	"carrier": {
		"tex": "res://1. GFX/Kenney/PNG/Retina/station_C.png", "scale": 1.15, "tint": GREEN, "faceDown": false, "spin": 0.4,
		"hp": 520, "radius": 64, "score": 800, "scrap": 8, "drop": "repair", "dropChance": 0.5,
		"attacks": [
			{"pattern": "ringGap", "every": 3.0, "delay": 1.0, "speed": 210, "count": 20, "gap": 64, "color": GREEN},
			{"pattern": "aimed", "every": 2.2, "delay": 2.0, "speed": 360, "count": 1, "burst": 3, "burstGap": 0.14, "color": RED},
		],
	},
	"mine": {
		"tex": "res://1. GFX/Misc/bomba.png", "scale": 0.3, "tint": Color(1, 1, 1), "faceDown": false, "spin": 1.2,
		"hp": 20, "radius": 32, "score": 50, "scrap": 0,
		# blows up into a ring and damages nearby enemies: shoot it when it's next to them, not next to you
		"onDeath": {"pattern": "ring", "count": 18, "speed": 250, "color": ORANGE, "blastRadius": 230, "blastDamage": 120},
		"attacks": [],
	},
	"asteroid": {
		"tex": "res://1. GFX/Kenney/PNG/Retina/meteor_detailedLarge.png", "scale": 0.85, "tint": Color(0.75, 0.7, 0.65), "faceDown": false, "spin": 0.8,
		"hp": 140, "radius": 50, "score": 60, "scrap": 2, "blocksBullets": true,
		"attacks": [],
	},
	# --- bosses (hp gets multiplied by the loop difficulty too)
	"carrierPrime": {
		"tex": "res://1. GFX/Kenney/PNG/Retina/station_C.png", "scale": 1.8, "tint": Color(0.5, 1.0, 0.6), "faceDown": false, "spin": 0.3,
		"hp": 3600, "radius": 95, "score": 5000, "scrap": 16, "drop": "bomb", "dropChance": 1.0, "boss": true,
		"attacks": [
			{"pattern": "ringGap", "every": 2.6, "delay": 1.0, "speed": 220, "count": 26, "gap": 60, "color": GREEN},
			{"pattern": "aimed", "every": 1.9, "delay": 1.6, "speed": 380, "count": 3, "spread": 22, "color": RED},
			{"pattern": "spiral", "every": 0.3, "delay": 4.0, "speed": 190, "arms": 2, "step": 19, "color": CYAN},
		],
	},
	"mothership": {
		"tex": "res://1. GFX/Kenney/PNG/Retina/station_B.png", "scale": 2.3, "tint": Color(1.0, 0.45, 0.45), "faceDown": false, "spin": 0.25,
		"hp": 12000, "radius": 120, "score": 20000, "scrap": 30, "boss": true,
		"attacks": [],  # the mothership uses phases instead, see Enemy._bossPhases
	},
}
