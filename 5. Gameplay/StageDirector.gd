extends Node
# Plays a stage from Stages.gd: banners, timed spawns, waits for each wave to be cleared,
# offers upgrades between waves, then loops the stage with tougher enemies.

var stageName = "stage1"
var waves = []
var currentWaveName = ""
var level
var gui
var streamsRunning = 0


func _ready():
	add_to_group("director")


func start(stage):
	stageName = stage
	waves = Stages.get_stage(stage)
	level = get_parent()
	gui = level.get_node("GUI")
	_run()


func _wait(seconds):
	# timers made with process_always = false stop while the game is paused (upgrade picker, pause menu)
	await get_tree().create_timer(seconds, false).timeout

func _playing():
	return is_inside_tree() and level.player.alive


func _run():
	await _wait(1.0)
	while _playing():
		for wave in waves:
			await _runWave(wave)
			if not _playing():
				return

		if stageName == "tutorial":
			gui.banner("TUTORIAL COMPLETE", "now try the real thing!", 3.5)
			await _wait(4.0)
			if is_inside_tree():
				get_tree().change_scene_to_file("res://4. Scenes/Menus/welcomeMenu.tscn")
			return

		gui.banner("STAGE CLEAR", "", 3.0)
		level.onStageCleared()
		await _wait(4.5)
		level.startNextLoop()
		gui.banner("LOOP %d" % level.loop, "enemies are tougher - and worth more", 3.0)
		await _wait(3.0)


func _runWave(wave):
	currentWaveName = wave.get("name", "")
	if wave.has("banner"):
		if wave.get("warning", false):
			Sfx.play("bossWarning", 0.0)
			gui.banner(wave.banner, wave.get("sub", ""), 2.6, Color(1, 0.3, 0.3))
		else:
			Sfx.play("banner", 0.0)
			gui.banner(wave.banner, wave.get("sub", ""), 2.0)
		await _wait(2.2)

	var events = wave.events.duplicate()
	events.sort_custom(func(a, b): return a.at < b.at)
	var elapsed = 0.0
	for e in events:
		if e.at > elapsed:
			await _wait(e.at - elapsed)
			elapsed = e.at
		if not _playing():
			return
		if e.type == "banner":
			gui.banner(e.text, e.get("sub", ""), 2.2)
		else:
			_spawnEvent(e)

	# wait until everything that matters is dead or gone (asteroids and mines don't count)
	var waited = 0.0
	while _playing() and waited < wave.get("timeout", 25.0) and (streamsRunning > 0 or _threatsLeft() > 0):
		await _wait(0.25)
		waited += 0.25

	if wave.get("pickAfter", false) and _playing():
		await _wait(0.8)
		level.requestUpgrade("WAVE CLEAR!")
		while is_inside_tree() and level.picker.isOpen:
			await get_tree().process_frame


func _threatsLeft():
	var n = 0
	for e in get_tree().get_nodes_in_group("enemies"):
		if not e.blocksBullets and e.typeName != "mine":
			n += 1
	return n


func _spawnEvent(e):
	var count = e.get("count", 1)
	if count > 1 and e.get("every", 0.0) > 0.0:
		_spawnStream(e)
	else:
		for i in range(count):
			_spawnOne(e, i)

func _spawnStream(e):
	streamsRunning += 1
	for i in range(e.count):
		if not _playing():
			break
		_spawnOne(e, i)
		await _wait(e.every)
	streamsRunning -= 1

func _spawnOne(e, i):
	var move = e.get("move", {}).duplicate()
	if move.has("target") and e.has("targetStep"):
		move.target += e.targetStep * i
	var pos = e.pos + e.get("step", Vector2.ZERO) * i
	var enemy = Enemy.new().setup(e.type, pos, move)
	level.add_child(enemy)
	if enemy.isBoss:
		gui.showBossBar(_bossName(e.type), enemy)
	return enemy


func _bossName(type):
	match type:
		"carrierPrime": return "CARRIER PRIME"
		"mothership": return "SKULL MOTHERSHIP"
	return type.to_upper()


# ---------------------------------------------------------------- called by Enemy / level

func onBossPhase(phase):
	gui.banner("PHASE %d" % phase, "", 1.4, Color(1, 0.4, 0.4))

func onBossKilled(_enemy):
	gui.hideBossBar()
	gui.flashScreen(Color(1, 1, 1, 0.7))
	gui.banner("DESTROYED", "", 2.0, Color(1, 0.9, 0.5))
