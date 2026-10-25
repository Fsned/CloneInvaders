extends RefCounted
class_name Stages
# Stage scripts. A stage is a list of waves; a wave is a list of timed spawn events.
# The screen is 1080 x 1920, (0,0) top-left. Enemies usually enter from above (y < 0).
#
# Wave keys:
#   name, banner, sub          title shown when the wave starts ("warning": true for the red boss alert)
#   events                     list of spawns (below)
#   timeout                    max seconds to wait for the wave to be cleared
#   pickAfter                  open the 1-of-3 upgrade picker when the wave is done
#
# Event keys:
#   at                         seconds after the wave starts
#   type                       enemy type from EnemyTypes, or "banner" (text, sub)
#   pos, count, every, step    spawn `count` enemies, `every` seconds apart, each offset by `step`
#   move                       movement for Enemy.setup(): mode, vel, target, hold, exitVel, sineAmp, sineFreq, enterTime, diveSpeed
#   targetStep                 offset added to move.target per enemy (rows / formations)

const W = 1080.0
const H = 1920.0

static func get_stage(stageName):
	match stageName:
		"tutorial": return tutorial()
		_: return stage1()


static func _stream(at, type, pos, count, every, vel, sineAmp = 0.0, sineFreq = 0.4, step = Vector2.ZERO):
	return {"at": at, "type": type, "pos": pos, "count": count, "every": every, "step": step,
		"move": {"mode": "path", "vel": vel, "sineAmp": sineAmp, "sineFreq": sineFreq}}

static func _row(at, type, firstX, count, spacing, targetY, hold, exitVel = Vector2(0, 320), enterTime = 1.4):
	return {"at": at, "type": type, "pos": Vector2(firstX, -70), "count": count, "every": 0.0, "step": Vector2(spacing, 0),
		"targetStep": Vector2(spacing, 0),
		"move": {"mode": "enterStop", "target": Vector2(firstX, targetY), "hold": hold, "exitVel": exitVel, "enterTime": enterTime}}

static func _divers(at, firstX, count, spacing, targetY, hold = 1.2):
	return {"at": at, "type": "diver", "pos": Vector2(firstX, -70), "count": count, "every": 0.15, "step": Vector2(spacing, 0),
		"targetStep": Vector2(spacing, 0),
		"move": {"mode": "dive", "target": Vector2(firstX, targetY), "hold": hold, "enterTime": 1.0, "diveSpeed": 780.0}}

static func _single(at, type, pos, move):
	return {"at": at, "type": type, "pos": pos, "count": 1, "every": 0.0, "move": move}


static func stage1():
	return [
		{"name": "first contact", "banner": "STAGE 1", "sub": "first contact", "timeout": 28, "events": [
			# diagonal sweeps across the top half, then a row that stops to shoot
			_stream(0.5, "grunt", Vector2(-60, 160), 6, 0.55, Vector2(260, 110), 40, 0.5),
			_stream(4.0, "grunt", Vector2(W + 60, 220), 6, 0.55, Vector2(-260, 110), 40, 0.5),
			_row(8.0, "grunt", 180, 5, 180, 330, 3.5, Vector2(0, -260)),
			_stream(11.0, "grunt", Vector2(-60, 520), 5, 0.5, Vector2(300, -40), 60, 0.4),
		]},
		{"name": "weavers", "banner": "WAVE 2", "sub": "weavers", "timeout": 30, "pickAfter": true, "events": [
			_stream(0.0, "weaver", Vector2(W + 70, 260), 5, 0.8, Vector2(-230, 70), 80, 0.5),
			_stream(3.5, "weaver", Vector2(-70, 420), 5, 0.8, Vector2(230, 70), 80, 0.5),
			_single(5.0, "mine", Vector2(320, -60), {"mode": "path", "vel": Vector2(0, 130)}),
			_stream(7.5, "grunt", Vector2(540, -60), 6, 0.4, Vector2(0, 260), 260, 0.25),
			_single(9.0, "mine", Vector2(760, -60), {"mode": "path", "vel": Vector2(0, 130)}),
			_row(11.0, "weaver", 240, 4, 200, 420, 4.0),
		]},
		{"name": "rock field", "banner": "WAVE 3", "sub": "rock field", "timeout": 30, "events": [
			_single(0.0, "asteroid", Vector2(260, -80), {"mode": "path", "vel": Vector2(35, 95)}),
			_single(1.5, "asteroid", Vector2(860, -80), {"mode": "path", "vel": Vector2(-30, 90)}),
			_divers(2.0, 300, 3, 240, 380),
			_single(5.0, "asteroid", Vector2(560, -80), {"mode": "path", "vel": Vector2(0, 110)}),
			_divers(6.5, 180, 4, 240, 300, 1.0),
			_single(8.0, "asteroid", Vector2(180, -80), {"mode": "path", "vel": Vector2(40, 100)}),
			_stream(9.0, "grunt", Vector2(100, -60), 5, 0.5, Vector2(0, 280)),
			_stream(9.0, "grunt", Vector2(980, -60), 5, 0.5, Vector2(0, 280)),
			_divers(12.0, 300, 3, 240, 420),
		]},
		{"name": "spinners", "banner": "WAVE 4", "sub": "spinners", "timeout": 32, "pickAfter": true, "events": [
			_single(0.5, "spinner", Vector2(300, -80), {"mode": "enterStop", "target": Vector2(300, 430), "hold": 8.0, "exitVel": Vector2(0, 140)}),
			_single(1.0, "asteroid", Vector2(700, -80), {"mode": "path", "vel": Vector2(-20, 80)}),
			_single(4.0, "spinner", Vector2(780, -80), {"mode": "enterStop", "target": Vector2(780, 560), "hold": 8.0, "exitVel": Vector2(0, 140)}),
			_stream(6.0, "grunt", Vector2(540, -60), 5, 0.5, Vector2(0, 250), 300, 0.2),
			_stream(10.0, "weaver", Vector2(W + 70, 300), 5, 0.7, Vector2(-220, 60), 70, 0.5),
			_single(12.0, "mine", Vector2(540, -60), {"mode": "path", "vel": Vector2(0, 110)}),
		]},
		{"name": "midboss", "banner": "WARNING", "sub": "carrier prime approaching", "warning": true, "timeout": 120, "pickAfter": true, "events": [
			_single(0.0, "carrierPrime", Vector2(540, -160), {"mode": "boss", "target": Vector2(540, 380), "enterTime": 3.0}),
			_stream(12.0, "grunt", Vector2(120, -60), 4, 0.5, Vector2(0, 260)),
			_stream(22.0, "grunt", Vector2(960, -60), 4, 0.5, Vector2(0, 260)),
			_single(30.0, "mine", Vector2(260, -60), {"mode": "path", "vel": Vector2(0, 120)}),
			_single(30.0, "mine", Vector2(820, -60), {"mode": "path", "vel": Vector2(0, 120)}),
		]},
		{"name": "onslaught", "banner": "WAVE 6", "sub": "onslaught", "timeout": 36, "pickAfter": true, "events": [
			_single(0.0, "carrier", Vector2(270, -100), {"mode": "enterStop", "target": Vector2(270, 400), "hold": 9.0, "exitVel": Vector2(0, 120)}),
			_stream(1.0, "weaver", Vector2(W + 70, 700), 6, 0.6, Vector2(-240, 30), 60, 0.6),
			_single(3.0, "carrier", Vector2(810, -100), {"mode": "enterStop", "target": Vector2(810, 520), "hold": 9.0, "exitVel": Vector2(0, 120)}),
			_divers(6.0, 180, 4, 240, 320, 1.0),
			_single(8.0, "mine", Vector2(300, -60), {"mode": "path", "vel": Vector2(0, 120)}),
			_single(8.0, "mine", Vector2(780, -60), {"mode": "path", "vel": Vector2(0, 120)}),
			_stream(13.0, "grunt", Vector2(-60, 200), 5, 0.45, Vector2(280, 60), 40, 0.5),
			_stream(13.0, "grunt", Vector2(W + 60, 300), 5, 0.45, Vector2(-280, 60), 40, 0.5),
		]},
		{"name": "boss", "banner": "WARNING", "sub": "skull mothership", "warning": true, "timeout": 300, "events": [
			_single(0.0, "mothership", Vector2(540, -260), {"mode": "boss", "target": Vector2(540, 420), "enterTime": 4.0}),
		]},
	]


static func tutorial():
	var b = func(at, text, sub = ""): return {"at": at, "type": "banner", "text": text, "sub": sub}
	return [
		{"name": "hello", "timeout": 1, "events": [
			b.call(0.0, "Hello!"), b.call(2.4, "This is Clone Invaders"), b.call(4.8, "My very first game :D"), b.call(7.2, "Hope you like it!"),
		]},
		{"name": "move", "timeout": 25, "events": [
			b.call(0.0, "MOVE", "WASD / arrow keys, or hold the mouse button"),
			b.call(3.0, "Your ship fires on its own"),
			_stream(3.0, "grunt", Vector2(300, -60), 5, 0.9, Vector2(0, 200), 120, 0.3),
			_stream(6.0, "grunt", Vector2(780, -60), 5, 0.9, Vector2(0, 200), 120, 0.3),
		]},
		{"name": "focus", "timeout": 25, "events": [
			b.call(0.0, "FOCUS", "hold SHIFT: move slower and see your hitbox"),
			b.call(3.0, "Only the glowing dot can be hit", "slip through the gaps!"),
			_row(3.0, "weaver", 240, 4, 200, 380, 6.0),
		]},
		{"name": "scrap", "timeout": 25, "pickAfter": true, "events": [
			b.call(0.0, "SCRAP", "collect scrap to fill the upgrade meter"),
			_stream(1.5, "grunt", Vector2(540, -60), 8, 0.5, Vector2(0, 230), 280, 0.25),
		]},
		{"name": "bomb", "timeout": 30, "events": [
			b.call(0.0, "BOMB", "X or right-click clears every bullet"),
			_single(1.0, "spinner", Vector2(540, -80), {"mode": "enterStop", "target": Vector2(540, 420), "hold": 10.0, "exitVel": Vector2(0, 150)}),
			_single(5.0, "mine", Vector2(300, -60), {"mode": "path", "vel": Vector2(0, 120)}),
			b.call(5.0, "MINES", "shoot them near enemies, not near you"),
		]},
	]
