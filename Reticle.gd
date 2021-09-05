extends CanvasLayer




func _process(_delta):
	$Reticle.position = get_global_mouse_position()
