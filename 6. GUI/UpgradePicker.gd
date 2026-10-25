extends CanvasLayer
# "Choose 1 of 3" upgrade screen. Pauses the game while open.
# Click a card or press 1 / 2 / 3.

signal picked(cardId)

const FONT = preload("res://1. GFX/Fonts/Kenney Future.ttf")
const INPUT_DELAY = 0.45  # ignore input briefly so a held key/click doesn't pick by accident

var isOpen = false
var cards = []
var player
var openedAt = 0.0
var root: Control
var titleLabel: Label
var reasonLabel: Label
var buttons = []


func _ready():
	layer = 25
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("upgradePicker")

	root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.visible = false
	add_child(root)

	var dim = ColorRect.new()
	dim.color = Color(0, 0, 0.05, 0.72)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.add_child(dim)

	# absolute placement on the 1080x1920 canvas (anchoring to the centre + a position offset
	# pushed the box off-screen once the root control got its real size)
	var box = VBoxContainer.new()
	box.custom_minimum_size = Vector2(880, 0)
	box.position = Vector2(100, 400)
	box.add_theme_constant_override("separation", 26)
	root.add_child(box)

	reasonLabel = _label("", 30, Color(0.6, 0.9, 1.0))
	box.add_child(reasonLabel)
	titleLabel = _label("CHOOSE AN UPGRADE", 54, Color(1, 0.95, 0.6))
	box.add_child(titleLabel)

	for i in range(3):
		var b = Button.new()
		b.custom_minimum_size = Vector2(880, 230)
		b.focus_mode = Control.FOCUS_NONE
		b.add_theme_font_override("font", FONT)
		b.add_theme_stylebox_override("normal", _cardStyle(Color(0.08, 0.1, 0.18), Color(0.35, 0.45, 0.7)))
		b.add_theme_stylebox_override("hover", _cardStyle(Color(0.12, 0.16, 0.3), Color(1.0, 0.85, 0.4)))
		b.add_theme_stylebox_override("pressed", _cardStyle(Color(0.2, 0.25, 0.4), Color(1.0, 1.0, 1.0)))
		b.pressed.connect(choose.bind(i))
		box.add_child(b)

		var v = VBoxContainer.new()
		v.set_anchors_preset(Control.PRESET_FULL_RECT)
		v.offset_left = 36
		v.offset_right = -36
		v.offset_top = 28
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_theme_constant_override("separation", 14)
		b.add_child(v)
		var nameLabel = _label("", 44, Color.WHITE, HORIZONTAL_ALIGNMENT_LEFT)
		var descLabel = _label("", 30, Color(0.75, 0.82, 0.95), HORIZONTAL_ALIGNMENT_LEFT)
		descLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		var keyLabel = _label("[%d]" % (i + 1), 26, Color(1, 0.85, 0.4), HORIZONTAL_ALIGNMENT_RIGHT)
		keyLabel.position = Vector2(760, 20)
		v.add_child(nameLabel)
		v.add_child(descLabel)
		b.add_child(keyLabel)
		buttons.append({"button": b, "name": nameLabel, "desc": descLabel})

	var hint = _label("click a card or press 1 / 2 / 3", 24, Color(0.6, 0.65, 0.75))
	box.add_child(hint)


func _label(text, size, color, align = HORIZONTAL_ALIGNMENT_CENTER):
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 8)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _cardStyle(bg, border):
	var s = StyleBoxFlat.new()
	s.bg_color = bg
	s.border_color = border
	s.set_border_width_all(5)
	s.set_corner_radius_all(18)
	return s


func open(p, reason = ""):
	player = p
	cards = Upgrades.roll(p, 3)
	if cards.is_empty():
		return
	for i in range(3):
		var b = buttons[i]
		b.button.visible = i < cards.size()
		if i < cards.size():
			b.name.text = Upgrades.title(cards[i], p)
			b.desc.text = Upgrades.describe(cards[i], p)
	reasonLabel.text = reason
	isOpen = true
	openedAt = Time.get_ticks_msec() / 1000.0
	root.visible = true
	get_tree().paused = true
	Sfx.play("upgrade", 0.0)


func _unhandled_input(event):
	if not isOpen:
		return
	for i in range(3):
		if event.is_action_pressed("Pick%d" % (i + 1)):
			choose(i)
			get_viewport().set_input_as_handled()


func choose(index):
	if not isOpen or index >= cards.size():
		return
	if Time.get_ticks_msec() / 1000.0 - openedAt < INPUT_DELAY:
		return
	var id = cards[index]
	var cardTitle = Upgrades.title(id, player)
	Upgrades.apply(id, player)
	isOpen = false
	root.visible = false
	get_tree().paused = false
	Sfx.play("powerUp", 0.0)
	Effects.floatText(player, player.global_position + Vector2(0, -70), cardTitle.to_upper(), Color(0.6, 1, 0.7), 34)
	emit_signal("picked", id)
