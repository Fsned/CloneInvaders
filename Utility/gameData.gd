extends Node

# res:// is read-only in exported builds, so save data lives in user://
const saveFilePath = "user://saveData.save"
const legacySaveFilePath = "res://Utility/saveData.save"

var defaultData = {
	"score": 0,
	"musicVolume": 60,
	"sfxVolume": 60
}


var data = {}


func _ready():
	loadGame()


func saveGame():
	var file = FileAccess.open(saveFilePath, FileAccess.WRITE)
	if file == null:
		print("Could not write save file: " + str(FileAccess.get_open_error()))
		return
	file.store_line(JSON.stringify(data))


func loadGame(_scope = "all"):
	var path = saveFilePath
	if not FileAccess.file_exists(path):
		# Pick up old saves (highscore) from before the Godot 4 port
		if FileAccess.file_exists(legacySaveFilePath):
			path = legacySaveFilePath
		else:
			resetData()
			saveGame()
			return

	var text = FileAccess.get_file_as_string(path)
	var parsed = JSON.parse_string(text)
	if parsed is Dictionary:
		data = parsed
	else:
		resetData()


func getKey(key):
	loadGame()

	if key in data:
		return data[key]

	else:
		if not key in defaultData:
			print("Data missing in defaultData: " + str(key))
			return 0
		else:
			data[key] = defaultData[key]
			return defaultData[key]

func setKey(key, value):
#	loadGame()
	data[key] = value
	saveGame()

	print ("Setting " + key + " to: " + str(value))

func resetData():
	data = defaultData.duplicate()
