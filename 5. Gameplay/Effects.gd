extends Node2D
class_name Effects
# Lightweight visual effects drawn by a single node: sparks, explosions, floating score text,
# plus screen shake. Use the static helpers from anywhere: Effects.explosion(self, pos)

const EXPLOSION_FRAMES = [
	preload("res://1. GFX/Kenney/PNG/Retina/explosion1.png"),
	preload("res://1. GFX/Kenney/PNG/Retina/explosion2.png"),
	preload("res://1. GFX/Kenney/PNG/Retina/explosion3.png"),
	preload("res://1. GFX/Kenney/PNG/Retina/explosion4.png"),
	preload("res://1. GFX/Kenney/PNG/Retina/explosion5.png"),
]
const FONT = preload("res://1. GFX/Fonts/Kenney Future.ttf")

var sparks = []
var explosions = []
var texts = []
var shakeStrength = 0.0
var camera: Camera2D


func _ready():
	add_to_group("effects")
	z_index = 8
	process_mode = Node.PROCESS_MODE_PAUSABLE


static func _fx(from: Node) -> Effects:
	if from == null or not from.is_inside_tree():
		return null
	return from.get_tree().get_first_node_in_group("effects")

static func spark(from: Node, pos: Vector2, color = Color.WHITE, count = 3):
	var fx = _fx(from)
	if fx == null: return
	for i in range(count):
		if fx.sparks.size() > 600: return
		fx.sparks.append({"pos": pos, "vel": Vector2.from_angle(randf() * TAU) * randf_range(80, 320), "life": randf_range(0.15, 0.35), "color": color})

static func explosion(from: Node, pos: Vector2, size = 1.0):
	var fx = _fx(from)
	if fx == null: return
	fx.explosions.append({"pos": pos, "age": 0.0, "size": size, "rot": randf() * TAU})
	spark(from, pos, Color(1.0, 0.7, 0.3), int(8 * size))

static func floatText(from: Node, pos: Vector2, text: String, color = Color.WHITE, fontSize = 30):
	var fx = _fx(from)
	if fx == null: return
	if fx.texts.size() > 40: fx.texts.pop_front()
	fx.texts.append({"pos": pos, "text": text, "color": color, "age": 0.0, "size": fontSize})

static func shake(from: Node, strength = 12.0):
	var fx = _fx(from)
	if fx == null: return
	fx.shakeStrength = max(fx.shakeStrength, strength)


func _process(delta):
	for s in sparks:
		s.pos += s.vel * delta
		s.vel *= 0.9
		s.life -= delta
	sparks = sparks.filter(func(s): return s.life > 0.0)

	for e in explosions:
		e.age += delta
	explosions = explosions.filter(func(e): return e.age < 0.5)

	for t in texts:
		t.age += delta
		t.pos.y -= 70.0 * delta
	texts = texts.filter(func(t): return t.age < 0.9)

	if camera:
		if shakeStrength > 0.1:
			camera.offset = Vector2(randf_range(-1, 1), randf_range(-1, 1)) * shakeStrength
			shakeStrength = move_toward(shakeStrength, 0.0, 60.0 * delta)
		else:
			camera.offset = Vector2.ZERO
	queue_redraw()


func _draw():
	for s in sparks:
		draw_circle(s.pos, 3.0, Color(s.color, clamp(s.life * 4.0, 0.0, 1.0)))

	for e in explosions:
		var frame = int(e.age / 0.1)
		if frame < EXPLOSION_FRAMES.size():
			var tex = EXPLOSION_FRAMES[frame]
			var sz = Vector2(110, 110) * e.size
			draw_set_transform(e.pos, e.rot)
			draw_texture_rect(tex, Rect2(-sz / 2, sz), false)
	draw_set_transform(Vector2.ZERO)

	for t in texts:
		var alpha = clamp(1.6 - t.age * 1.8, 0.0, 1.0)
		var w = FONT.get_string_size(t.text, HORIZONTAL_ALIGNMENT_LEFT, -1, t.size).x
		draw_string_outline(FONT, t.pos - Vector2(w / 2, 0), t.text, HORIZONTAL_ALIGNMENT_LEFT, -1, t.size, 6, Color(0, 0, 0, alpha))
		draw_string(FONT, t.pos - Vector2(w / 2, 0), t.text, HORIZONTAL_ALIGNMENT_LEFT, -1, t.size, Color(t.color, alpha))
