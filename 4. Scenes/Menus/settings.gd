extends Popup

func _ready():
	
	$NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/musicSlider.value = GameData.getKey("musicVolume")
	$NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/sfxSlider.value = GameData.getKey("sfxVolume")
	
	get_tree().call_group("music", "setVolume", $NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/musicSlider.value)
	get_tree().call_group("sfx", "setVolume", $NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/sfxSlider.value)
	


func _on_musicSlider_value_changed(value):
	get_tree().call_group("music", "setVolume", value)
	setMusicLabel(value)
	


func _on_sfxSlider_value_changed(value):
	get_tree().call_group("sounds", "setVolume", value)
	setSfxLabel(value)


func getMusicVolume():
	return $NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/musicSlider.value

func getSfxVolume():
	return $NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/sfxSlider.value


func setMusicLabel(value):
	$NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/musicPrcntLabel.text = str(value) + "%"

func setSfxLabel(value):
	$NinePatchRect/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/sfxPrcntLabel.text = str(value) + "%"


func _on_confirmButton_pressed():
	visible = !visible
	GameData.setKey("sfxVolume", getSfxVolume())
	GameData.setKey("musicVolume", getMusicVolume())
	
