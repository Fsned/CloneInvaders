extends CanvasLayer
# Scrolling space background: three layers of stars moving down at different speeds
# (parallax), plus a planet drifting past every now and then.

const STAR_LAYERS = [
	{"count": 90, "speed": 40.0, "size": 1.5, "alpha": 0.35},
	{"count": 50, "speed": 90.0, "size": 2.2, "alpha": 0.6},
	{"count": 22, "speed": 190.0, "size": 3.0, "alpha": 0.9},
]

@export var scrollSpeed = 1.0

var planetTextures = []
var stars = []
var planet = null
var planetTimer = 4.0
var canvas: Node2D


func _ready():
	for f in FileGrabber.fileGrab("res://1. GFX/Planets/", 1, ".png"):
		planetTextures.append(load(f))
	canvas = Node2D.new()
	add_child(canvas)
	canvas.draw.connect(_draw_space)
	var size = _size()
	for layerIndex in range(STAR_LAYERS.size()):
		for i in range(STAR_LAYERS[layerIndex].count):
			stars.append({"pos": Vector2(randf() * size.x, randf() * size.y), "layer": layerIndex,
				"tint": Color(1, 1, 1).lerp(Color(0.6, 0.8, 1.0), randf())})


func _size():
	return get_viewport().get_visible_rect().size


func _process(delta):
	var size = _size()
	for s in stars:
		s.pos.y += STAR_LAYERS[s.layer].speed * scrollSpeed * delta
		if s.pos.y > size.y + 4:
			s.pos = Vector2(randf() * size.x, -4)

	if planet:
		planet.pos.y += planet.speed * scrollSpeed * delta
		planet.rot += planet.spin * delta
		if planet.pos.y > size.y + 300:
			planet = null
	elif planetTextures.size() > 0:
		planetTimer -= delta
		if planetTimer <= 0.0:
			planetTimer = randf_range(12.0, 22.0)
			planet = {"tex": planetTextures[randi() % planetTextures.size()], "pos": Vector2(randf_range(100, size.x - 100), -300),
				"scale": randf_range(3.0, 6.5), "speed": randf_range(22.0, 38.0), "rot": randf() * TAU, "spin": randf_range(-0.05, 0.05)}
	canvas.queue_redraw()


func _draw_space():
	if planet:
		var sz = planet.tex.get_size() * planet.scale
		canvas.draw_set_transform(planet.pos, planet.rot)
		canvas.draw_texture_rect(planet.tex, Rect2(-sz / 2, sz), false, Color(0.55, 0.55, 0.65))
		canvas.draw_set_transform(Vector2.ZERO)
	for s in stars:
		var l = STAR_LAYERS[s.layer]
		var c = Color(s.tint, l.alpha)
		if s.layer == 2:
			# fast stars get a short streak
			canvas.draw_line(s.pos, s.pos - Vector2(0, 10), c, l.size)
		else:
			canvas.draw_circle(s.pos, l.size, c)
