extends Node
# Autoload "Sfx": fire-and-forget sound effects with a small player pool.
# Usage: Sfx.play("explosion")

const SOUNDS = {
	"shoot": ["res://2. SFX/Audio/laser4.ogg"],
	"enemyShoot": ["res://2. SFX/Audio/laser9.ogg"],
	"explosion": ["res://2. SFX/Audio/spaceTrash1.ogg", "res://2. SFX/Audio/spaceTrash2.ogg", "res://2. SFX/Audio/spaceTrash3.ogg"],
	"bigExplosion": ["res://2. SFX/Audio/lowDown.ogg"],
	"hit": ["res://2. SFX/Audio/zapTwoTone2.ogg"],
	"playerHit": ["res://2. SFX/Audio/phaserDown3.ogg"],
	"pickup": ["res://2. SFX/Audio/pepSound1.ogg", "res://2. SFX/Audio/pepSound2.ogg"],
	"powerUp": ["res://2. SFX/Audio/powerUp7.ogg"],
	"upgrade": ["res://2. SFX/Audio/powerUp11.ogg"],
	"bomb": ["res://2. SFX/Audio/phaserDown1.ogg"],
	"graze": ["res://2. SFX/Audio/tone1.ogg"],
	"banner": ["res://2. SFX/Audio/threeTone1.ogg"],
	"bossWarning": ["res://2. SFX/Audio/zapThreeToneDown.ogg"],
}

# Per-sound base volume (dB) and minimum time between plays, to keep rapid fire from turning into noise
const VOLUME = {"shoot": -18.0, "enemyShoot": -20.0, "hit": -16.0, "graze": -22.0, "pickup": -12.0}
const MIN_INTERVAL = {"shoot": 0.09, "enemyShoot": 0.07, "hit": 0.05, "graze": 0.06, "explosion": 0.04, "pickup": 0.04}

var streams = {}
var players = []
var lastPlayed = {}
var volumeDb = 0.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_to_group("sounds")
	for key in SOUNDS:
		streams[key] = []
		for path in SOUNDS[key]:
			if ResourceLoader.exists(path):
				streams[key].append(load(path))
	for i in range(16):
		var p = AudioStreamPlayer.new()
		add_child(p)
		players.append(p)
	setVolume(GameData.getKey("sfxVolume"))

# Called by the settings menu (0-100)
func setVolume(value):
	volumeDb = linear_to_db(max(float(value), 0.01) / 100.0)

func play(soundName, pitchVariation = 0.08, volumeOffset = 0.0):
	if not streams.has(soundName) or streams[soundName].is_empty():
		return
	var now = Time.get_ticks_msec() / 1000.0
	if now - lastPlayed.get(soundName, -10.0) < MIN_INTERVAL.get(soundName, 0.0):
		return
	lastPlayed[soundName] = now

	for p in players:
		if not p.playing:
			var list = streams[soundName]
			p.stream = list[randi() % list.size()]
			p.volume_db = volumeDb + VOLUME.get(soundName, -8.0) + volumeOffset
			p.pitch_scale = 1.0 + randf_range(-pitchVariation, pitchVariation)
			p.play()
			return
