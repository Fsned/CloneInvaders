extends Node2D
class_name BulletField
# Moves, draws and collides every bullet and pickup in the level.
# Bullets are plain dictionaries instead of nodes: hundreds of them stay cheap,
# and clearing the screen (bombs, boss deaths) is a one-liner.
#
# Talks to:
#   player  (group "player"):  hitRadius, grazeRadius, magnetRadius, is_vulnerable(), on_hit(), on_graze(), collect(kind)
#   enemies (group "enemies"): hitRadius, alive, blocksBullets, take_damage(amount)

const CULL_MARGIN = 90.0

var enemyBullets = []
var playerBullets = []
var pickups = []

var orbTexture: Texture2D
var playerShotTexture = preload("res://1. GFX/Kenney/PNG/Retina/effect_yellow.png")
var lanceShotTexture = preload("res://1. GFX/Kenney/PNG/Retina/effect_purple.png")
var missileTexture = preload("res://1. GFX/Misc/WhiteDot.png")
var repairTexture = preload("res://1. GFX/Misc/HealthInBox.png")
var bombTexture = preload("res://1. GFX/Misc/ExplosionBox.png")
var scrapTextures = []

# Score hook: level connects to this to award points for cancelled bullets / pickups
signal scored(points, where)


func _ready():
	add_to_group("bulletField")
	z_index = 5
	orbTexture = _makeOrbTexture()
	for f in FileGrabber.fileGrab("res://1. GFX/Kenney/Scrap/", 1, ".png"):
		scrapTextures.append(load(f))


# White core fading to transparent; tinted per bullet when drawn
func _makeOrbTexture():
	var g = Gradient.new()
	g.offsets = PackedFloat32Array([0.0, 0.32, 0.5, 1.0])
	g.colors = PackedColorArray([Color(1, 1, 1, 1), Color(1, 1, 1, 1), Color(1, 1, 1, 0.55), Color(1, 1, 1, 0)])
	var t = GradientTexture2D.new()
	t.gradient = g
	t.fill = GradientTexture2D.FILL_RADIAL
	t.fill_from = Vector2(0.5, 0.5)
	t.fill_to = Vector2(1.0, 0.5)
	t.width = 64
	t.height = 64
	return t


# ---------------------------------------------------------------- spawning

# opts: radius, color, accel (px/s^2 along travel), maxSpeed, minSpeed, turn (rad/s, curving shots),
#       wait (s) + waitSpeed: bullet stops after `wait`... then re-aims at the player at waitSpeed
func spawnEnemyBullet(pos: Vector2, vel: Vector2, opts = {}):
	enemyBullets.append({
		"pos": pos, "vel": vel,
		"radius": opts.get("radius", 11.0),
		"color": opts.get("color", Color(1.0, 0.25, 0.3)),
		"accel": opts.get("accel", 0.0),
		"maxSpeed": opts.get("maxSpeed", 2000.0),
		"minSpeed": opts.get("minSpeed", 0.0),
		"turn": opts.get("turn", 0.0),
		"wait": opts.get("wait", -1.0),
		"waitSpeed": opts.get("waitSpeed", 0.0),
		"age": 0.0,
		"grazed": false,
	})

func spawnPlayerBullet(pos: Vector2, vel: Vector2, damage: float, pierce = false, kind = "spread"):
	playerBullets.append({"pos": pos, "vel": vel, "damage": damage, "pierce": pierce, "kind": kind, "hits": [], "age": 0.0})

func spawnPickup(pos: Vector2, kind = "scrap"):
	var tex = repairTexture if kind == "repair" else bombTexture if kind == "bomb" else scrapTextures[randi() % scrapTextures.size()]
	pickups.append({
		"pos": pos, "vel": Vector2(randf_range(-90, 90), randf_range(-260, -120)),
		"kind": kind, "tex": tex, "rot": randf() * TAU, "spin": randf_range(-4, 4), "age": 0.0,
	})

# Remove enemy bullets (bomb, boss death, player hit). Returns how many were cancelled.
func clearEnemyBullets(center = Vector2.ZERO, radius = INF, givePoints = true):
	var kept = []
	var cleared = 0
	for b in enemyBullets:
		if b.pos.distance_to(center) <= radius:
			cleared += 1
			Effects.spark(self, b.pos, b.color)
		else:
			kept.append(b)
	enemyBullets = kept
	if givePoints and cleared > 0:
		emit_signal("scored", cleared * 10, center)
	return cleared


# ---------------------------------------------------------------- update

func _physics_process(delta):
	var rect = get_viewport_rect().grow(CULL_MARGIN)
	var player = get_tree().get_first_node_in_group("player")
	var enemies = get_tree().get_nodes_in_group("enemies")

	_updateEnemyBullets(delta, rect, player, enemies)
	_updatePlayerBullets(delta, rect, enemies)
	_updatePickups(delta, rect, player)
	queue_redraw()


func _updateEnemyBullets(delta, rect, player, enemies):
	var covers = []
	for e in enemies:
		if e.blocksBullets and e.alive:
			covers.append(e)

	var vulnerable = player != null and player.is_vulnerable()
	var kept = []
	for b in enemyBullets:
		b.age += delta

		if b.wait > 0.0 and b.age >= b.wait:
			# "stop and re-aim" bullets
			b.wait = -1.0
			b.accel = 0.0
			if player:
				b.vel = (player.global_position - b.pos).normalized() * b.waitSpeed

		if b.accel != 0.0:
			var speed = clamp(b.vel.length() + b.accel * delta, b.minSpeed, b.maxSpeed)
			b.vel = b.vel.normalized() * speed if b.vel.length() > 0.01 else Vector2.DOWN * speed
		if b.turn != 0.0:
			b.vel = b.vel.rotated(b.turn * delta)
		b.pos += b.vel * delta

		if not rect.has_point(b.pos):
			continue

		var blocked = false
		for c in covers:
			if b.pos.distance_to(c.global_position) < c.hitRadius + b.radius * 0.5:
				blocked = true
				break
		if blocked:
			continue

		if player and player.alive:
			var dist = b.pos.distance_to(player.global_position)
			if vulnerable and dist < b.radius + player.hitRadius:
				player.on_hit()
				vulnerable = player.is_vulnerable()
				continue
			if not b.grazed and dist < b.radius + player.grazeRadius:
				b.grazed = true
				player.on_graze(b.pos)
		kept.append(b)
	enemyBullets = kept


func _updatePlayerBullets(delta, rect, enemies):
	var kept = []
	for b in playerBullets:
		b.age += delta
		if b.kind == "missile":
			_steerMissile(b, delta, enemies)
		b.pos += b.vel * delta
		if not rect.has_point(b.pos):
			continue

		var consumed = false
		for e in enemies:
			if not e.alive or b.hits.has(e.get_instance_id()):
				continue
			if b.pos.distance_to(e.global_position) < e.hitRadius + 10.0:
				e.take_damage(b.damage)
				if b.pierce and not e.blocksBullets:
					b.hits.append(e.get_instance_id())
				else:
					consumed = true
					Effects.spark(self, b.pos, Color(1, 0.9, 0.4))
					break
		if not consumed:
			kept.append(b)
	playerBullets = kept


func _steerMissile(b, delta, enemies):
	var best = null
	var bestDist = 900.0
	for e in enemies:
		if e.alive and not e.blocksBullets:
			var d = b.pos.distance_to(e.global_position)
			if d < bestDist:
				bestDist = d
				best = e
	if best:
		var desired = (best.global_position - b.pos).normalized() * b.vel.length()
		b.vel = b.vel.lerp(desired, clamp(6.0 * delta, 0.0, 1.0)).normalized() * b.vel.length()


func _updatePickups(delta, rect, player):
	var kept = []
	for p in pickups:
		p.age += delta
		p.rot += p.spin * delta
		var pulled = false
		if player and player.alive:
			var toPlayer = player.global_position - p.pos
			var dist = toPlayer.length()
			if dist < 40.0:
				player.collect(p.kind)
				continue
			if dist < player.magnetRadius:
				p.vel = p.vel.lerp(toPlayer.normalized() * 1100.0, clamp(8.0 * delta, 0.0, 1.0))
				pulled = true
		if not pulled:
			# pop up, then drift down towards the player's side of the screen
			p.vel.y = min(p.vel.y + 420.0 * delta, 170.0)
			p.vel.x = move_toward(p.vel.x, 0.0, 120.0 * delta)
		p.pos += p.vel * delta
		if p.pos.y > rect.end.y or p.age > 20.0:
			continue
		kept.append(p)
	pickups = kept


# ---------------------------------------------------------------- drawing

func _draw():
	for p in pickups:
		var size = Vector2(46, 46) if p.kind != "scrap" else Vector2(34, 25)
		draw_set_transform(p.pos, p.rot if p.kind == "scrap" else 0.0)
		draw_texture_rect(p.tex, Rect2(-size / 2, size), false, Color(0.75, 0.8, 0.85) if p.kind == "scrap" else Color.WHITE)

	for b in playerBullets:
		draw_set_transform(b.pos, b.vel.angle() + PI / 2)
		match b.kind:
			"lance":
				draw_texture_rect(lanceShotTexture, Rect2(-7, -30, 14, 60), false, Color(0.85, 0.6, 1.0))
			"missile":
				draw_texture_rect(missileTexture, Rect2(-9, -9, 18, 18), false, Color(0.4, 1.0, 0.6))
			_:
				draw_texture_rect(playerShotTexture, Rect2(-6, -20, 12, 40), false, Color(1.0, 0.95, 0.5))

	draw_set_transform(Vector2.ZERO)
	for b in enemyBullets:
		var r = b.radius * 2.3
		draw_texture_rect(orbTexture, Rect2(b.pos - Vector2(r, r), Vector2(r, r) * 2), false, b.color)
		# bright core so the actual hit area is easy to read
		draw_circle(b.pos, b.radius * 0.55, Color(1, 1, 1, 0.95))
