extends CanvasLayer
# In-game HUD. Built in code so the layout is easy to read and tweak in one place.
#   top:     score, high score, combo, boss health bar
#   middle:  wave banners, screen flash
#   bottom:  hull pips, bombs, upgrade (scrap) meter, weapon

const FONT = preload("res://1. GFX/Fonts/Kenney Future.ttf")
const BOMB_ICON = preload("res://1. GFX/Misc/bomba.png")

@export var level = ""

var scoreLabel: Label
var hiLabel: Label
var comboLabel: Label
var weaponLabel: Label
var hullBox: HBoxContainer
var bombBox: HBoxContainer
var powerBar: ProgressBar
var powerLabel: Label
var bossBox: VBoxContainer
var bossName: Label
var bossBar: ProgressBar
var bannerLabel: Label
var bannerSub: Label
var flash: ColorRect
var bannerTween: Tween
var trackedBoss


func _ready():
	add_to_group("GUI")
	layer = 10

	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	flash = ColorRect.new()
	flash.set_anchors_preset(Control.PRESET_FULL_RECT)
	flash.color = Color(1, 1, 1, 0)
	flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(flash)

	# --- top
	scoreLabel = _label("0", 52, Color.WHITE)
	_place(scoreLabel, root, Vector2(0, 18), Vector2(1080, 60))
	hiLabel = _label("HI 0", 26, Color(0.7, 0.75, 0.85), HORIZONTAL_ALIGNMENT_RIGHT)
	_place(hiLabel, root, Vector2(700, 28), Vector2(350, 40))
	comboLabel = _label("", 30, Color(1, 0.8, 0.3))
	_place(comboLabel, root, Vector2(0, 80), Vector2(1080, 40))

	bossBox = VBoxContainer.new()
	bossBox.visible = false
	_place(bossBox, root, Vector2(90, 130), Vector2(900, 70))
	bossName = _label("", 26, Color(1, 0.5, 0.5))
	bossBox.add_child(bossName)
	bossBar = _bar(Color(0.95, 0.2, 0.3), Vector2(900, 22))
	bossBox.add_child(bossBar)

	# --- middle
	bannerLabel = _label("", 76, Color(1, 0.95, 0.6))
	_place(bannerLabel, root, Vector2(0, 760), Vector2(1080, 100))
	bannerSub = _label("", 34, Color(0.8, 0.85, 1.0))
	bannerSub.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(bannerSub, root, Vector2(60, 860), Vector2(960, 100))
	bannerLabel.modulate.a = 0
	bannerSub.modulate.a = 0

	# --- bottom
	var bottom = Control.new()
	_place(bottom, root, Vector2(0, 1800), Vector2(1080, 120))
	bottom.mouse_filter = Control.MOUSE_FILTER_IGNORE

	hullBox = HBoxContainer.new()
	hullBox.add_theme_constant_override("separation", 8)
	_place(hullBox, bottom, Vector2(30, 14), Vector2(320, 34))
	bombBox = HBoxContainer.new()
	bombBox.add_theme_constant_override("separation", 6)
	_place(bombBox, bottom, Vector2(30, 60), Vector2(320, 44))

	powerLabel = _label("UPGRADE", 22, Color(0.6, 0.9, 1.0))
	_place(powerLabel, bottom, Vector2(360, 10), Vector2(360, 30))
	powerBar = _bar(Color(0.3, 0.85, 1.0), Vector2(360, 26))
	_place(powerBar, bottom, Vector2(360, 44), Vector2(360, 26))

	weaponLabel = _label("", 24, Color(1, 0.9, 0.5), HORIZONTAL_ALIGNMENT_RIGHT)
	weaponLabel.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_place(weaponLabel, bottom, Vector2(730, 10), Vector2(320, 90))


func _label(text, size, color, align = HORIZONTAL_ALIGNMENT_CENTER):
	var l = Label.new()
	l.text = text
	l.horizontal_alignment = align
	l.add_theme_font_override("font", FONT)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", color)
	l.add_theme_color_override("font_outline_color", Color(0, 0, 0, 0.9))
	l.add_theme_constant_override("outline_size", 8)
	l.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return l

func _bar(color, size):
	var b = ProgressBar.new()
	b.show_percentage = false
	b.custom_minimum_size = size
	var bg = StyleBoxFlat.new()
	bg.bg_color = Color(0.05, 0.06, 0.12, 0.85)
	bg.border_color = Color(0.4, 0.45, 0.6)
	bg.set_border_width_all(2)
	bg.set_corner_radius_all(6)
	var fill = StyleBoxFlat.new()
	fill.bg_color = color
	fill.set_corner_radius_all(6)
	b.add_theme_stylebox_override("background", bg)
	b.add_theme_stylebox_override("fill", fill)
	b.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return b

func _place(node, parent, pos, size):
	parent.add_child(node)
	node.position = pos
	node.size = size


# ---------------------------------------------------------------- called by the level / player

func setScore(value):
	scoreLabel.text = str(value)

func setHighscore(value):
	hiLabel.text = "HI " + str(value)

func newHighscore():
	hiLabel.add_theme_color_override("font_color", Color(0.4, 1, 0.5))

func setCombo(count, mult):
	comboLabel.text = "" if count < 3 else "%d CHAIN  x%.1f" % [count, mult]

func setHull(current, maximum):
	for c in hullBox.get_children():
		c.queue_free()
	for i in range(maximum):
		var pip = Panel.new()
		pip.custom_minimum_size = Vector2(30, 30)
		var s = StyleBoxFlat.new()
		s.bg_color = Color(1, 0.3, 0.35) if i < current else Color(0.15, 0.15, 0.2)
		s.border_color = Color(1, 0.8, 0.8) if i < current else Color(0.4, 0.4, 0.5)
		s.set_border_width_all(3)
		s.set_corner_radius_all(15)
		pip.add_theme_stylebox_override("panel", s)
		hullBox.add_child(pip)

func setBombs(count):
	for c in bombBox.get_children():
		c.queue_free()
	for i in range(count):
		var icon = TextureRect.new()
		icon.texture = BOMB_ICON
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(42, 42)
		bombBox.add_child(icon)

func setPower(value, goal):
	powerBar.max_value = goal
	powerBar.value = value

func setWeapon(weaponName, weaponLevel, missileLevel):
	weaponLabel.text = "%s %d" % [weaponName.to_upper(), weaponLevel]
	if missileLevel > 0:
		weaponLabel.text += "\nMISSILES %d" % missileLevel

func banner(text, sub = "", duration = 2.0, color = Color(1, 0.95, 0.6)):
	bannerLabel.text = text
	bannerSub.text = sub
	bannerLabel.add_theme_color_override("font_color", color)
	if bannerTween:
		bannerTween.kill()
	bannerTween = create_tween()
	bannerTween.tween_property(bannerLabel, "modulate:a", 1.0, 0.2)
	bannerTween.parallel().tween_property(bannerSub, "modulate:a", 1.0, 0.2)
	bannerTween.tween_interval(duration)
	bannerTween.tween_property(bannerLabel, "modulate:a", 0.0, 0.4)
	bannerTween.parallel().tween_property(bannerSub, "modulate:a", 0.0, 0.4)

func flashScreen(color = Color(1, 1, 1, 0.6)):
	flash.color = color
	create_tween().tween_property(flash, "color:a", 0.0, 0.5)

func showBossBar(bossTitle, boss):
	trackedBoss = boss
	bossName.text = bossTitle
	bossBar.max_value = boss.maxHp
	bossBar.value = boss.maxHp
	bossBox.visible = true
	boss.hpChanged.connect(func(cur, mx):
		bossBar.max_value = mx
		bossBar.value = cur)

func hideBossBar():
	bossBox.visible = false
	trackedBoss = null


# Old API kept so older scenes (tutorial dialogs etc.) don't break
func setHealth(_value): pass
func setMeteorites(_value): pass
func updatePlayerValues(_a): pass
func toggleEnemiesRemaining(): pass
