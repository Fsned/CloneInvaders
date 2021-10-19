extends Control


signal hullUpgradeDone
signal shotSpeedUpgradeDone
signal weaponUpgradeDone

var hullUpgradeInProgress = false
var shotSpeedUpgradeInProgress = false
var weaponUpgradeInProgress = false



func _process(_delta):
	if shotSpeedUpgradeInProgress:
		$HBoxContainer/VBoxContainer/TextureProgress1.value = ($upgradeTimer.time_left / 3) * 100
		
	if hullUpgradeInProgress:
		$HBoxContainer/VBoxContainer2/TextureProgress2.value = ($upgradeTimer.time_left / 3) * 100
		
	if weaponUpgradeInProgress:
		$HBoxContainer/VBoxContainer3/TextureProgress3.value = ($upgradeTimer.time_left / 3) * 100

#
#	if Input.is_action_just_pressed("UpgradeShot"):
#		startUpgrade(0)
#
#	if Input.is_action_just_pressed("UpgradeHull"):
#		startUpgrade(1)
#
#	if Input.is_action_just_pressed("UpgradeWeapon"):
#		startUpgrade(2)


func startUpgrade(upgradeType):
	if $upgradeTimer.is_stopped():
		$upgradeTimer.start()
		match(upgradeType):
			0: # HullUpgrade
				shotSpeedUpgradeInProgress = true
			1: # shotSpeedUpgrade
				hullUpgradeInProgress = true
			2: # weaponUpgrade 
				weaponUpgradeInProgress = true
				
	
	

func _on_upgradeTimer_timeout():
	if hullUpgradeInProgress:
		hullUpgradeInProgress = false
		emit_signal("hullUpgradeDone")
	elif shotSpeedUpgradeInProgress:
		shotSpeedUpgradeInProgress = false
		emit_signal("shotSpeedUpgradeDone")
	elif weaponUpgradeInProgress:
		weaponUpgradeInProgress = false
		emit_signal("weaponUpgradeDone")

