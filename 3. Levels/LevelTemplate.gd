extends Node2D
# Runs one play session: score, combo, scrap/upgrade meter, highscore, game over.
# The StageDirector (child, created here) runs the waves for the chosen stage.

@export_enum("stage1", "tutorial") var stage = "stage1"

const COMBO_WINDOW = 1.6      # seconds between kills to keep a chain going
const COMBO_MAX_MULT = 3.0
const FIRST_UPGRADE_SCRAP = 12
const UPGRADE_SCRAP_STEP = 10  # each meter-fill needs this much more scrap than the last

var score = 0
var currentHighscore = 0
var newHighscore = false

var combo = 0
var comboTimer = 0.0
var grazes = 0
var hitsTaken = 0
var loop = 1

var power = 0.0
var powerGoal = FIRST_UPGRADE_SCRAP
var pendingPicks = 0
var lastHull = 0

var field: BulletField
var effects: Effects
var director
var picker
@onready var player = $Player
@onready var gui = $GUI


func _ready():
	add_to_group("levelManager")
	currentHighscore = int(GameData.getKey("score"))  # JSON gives floats back
	newHighscore = false
	Enemy.hpMult = 1.0
	Enemy.bulletSpeedMult = 1.0
	Enemy.fireRateMult = 1.0

	var cam = Camera2D.new()
	cam.anchor_mode = Camera2D.ANCHOR_MODE_FIXED_TOP_LEFT
	add_child(cam)
	cam.make_current()

	field = BulletField.new()
	field.name = "BulletField"
	add_child(field)
	field.scored.connect(func(points, where): addScore(points, where, false))

	effects = Effects.new()
	effects.name = "Effects"
	effects.camera = cam
	add_child(effects)

	picker = preload("res://6. GUI/UpgradePicker.gd").new()
	picker.name = "UpgradePicker"
	add_child(picker)
	picker.picked.connect(_on_upgrade_picked)

	lastHull = player.hull
	player.died.connect(_on_Player_died)
	player.hullChanged.connect(_on_player_hull_changed)
	player.bombsChanged.connect(gui.setBombs)
	player.grazed.connect(_on_player_grazed)

	director = preload("res://5. Gameplay/StageDirector.gd").new()
	director.name = "StageDirector"
	add_child(director)
	director.start(stage)

	gui.setScore(0)
	gui.setHighscore(currentHighscore)
	gui.setPower(0, powerGoal)
	_refreshWeaponLabel()


func _process(delta):
	if comboTimer > 0.0:
		comboTimer -= delta
		if comboTimer <= 0.0:
			combo = 0
			gui.setCombo(0, 1.0)


func comboMult():
	return min(1.0 + combo * 0.1, COMBO_MAX_MULT)


# ---------------------------------------------------------------- events from the game

func enemyKilled(enemy):
	combo += 1
	comboTimer = COMBO_WINDOW
	var points = int(enemy.data.score * comboMult() * loop)
	addScore(points, enemy.global_position)
	gui.setCombo(combo, comboMult())
	if enemy.isBoss:
		director.onBossKilled(enemy)

func pickupCollected(kind):
	if kind == "scrap":
		addScore(25 * loop)
		addPower(1.0)

func _on_player_grazed(pos):
	grazes += 1
	addScore(20 * loop, pos, false)
	addPower(0.15)

func _on_player_hull_changed(current, maximum):
	if current < lastHull:
		hitsTaken += 1
		combo = 0
		gui.setCombo(0, 1.0)
	lastHull = current
	gui.setHull(current, maximum)

func addScore(points, where = null, showText = true):
	score += int(points)
	gui.setScore(score)
	if showText and where != null and points >= 100:
		Effects.floatText(self, where, str(points), Color(1, 0.95, 0.6), 28 if points < 1000 else 40)
	if score > currentHighscore and not newHighscore:
		newHighscore = true
		gui.newHighscore()
	if newHighscore:
		gui.setHighscore(score)


# ---------------------------------------------------------------- upgrades

func addPower(amount):
	power += amount
	if power >= powerGoal:
		power -= powerGoal
		powerGoal += UPGRADE_SCRAP_STEP
		requestUpgrade("SCRAP METER FULL!")
	gui.setPower(power, powerGoal)

# Opens the 1-of-3 picker (queued if one is already open)
func requestUpgrade(reason = ""):
	if not player.alive:
		return
	if picker.isOpen:
		pendingPicks += 1
		return
	picker.open(player, reason)

func _on_upgrade_picked(_card):
	_refreshWeaponLabel()
	if pendingPicks > 0:
		pendingPicks -= 1
		picker.open.call_deferred(player, "BONUS PICK")

func _refreshWeaponLabel():
	gui.setWeapon(WeaponData.NAMES[player.weaponType], player.weaponLevel, player.missileLevel)


# ---------------------------------------------------------------- loops & game over

func onStageCleared():
	if hitsTaken == 0:
		var bonus = 10000 * loop
		addScore(bonus)
		gui.banner("NO-HIT BONUS", "+" + str(bonus), 3.0)
	hitsTaken = 0

func startNextLoop():
	loop += 1
	Enemy.hpMult *= 1.5
	Enemy.bulletSpeedMult *= 1.1
	Enemy.fireRateMult *= 1.25

func _on_Player_died(_unitType):
	await get_tree().create_timer(2.0).timeout
	if not is_inside_tree():
		return
	get_tree().paused = true
	if score > GameData.getKey("score"):
		GameData.setKey("score", score)
	get_tree().call_group("loseMenu", "setScore", score)
	$Menus/loseMenu.show()

func getScore():
	return score

func getSaveData():
	return {"score": score}

# Old spawner/character code calls this; the new Enemy class reports through enemyKilled()
func unitDied(_unitType):
	pass

func getDebugInfo():
	return "loop=%d wave=%s combo=%d grazes=%d power=%.1f/%d bullets=%d enemies=%d" % [
		loop, director.currentWaveName, combo, grazes, power, powerGoal,
		field.enemyBullets.size(), get_tree().get_nodes_in_group("enemies").size()]
