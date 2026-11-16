extends CanvasLayer

func _ready():
	$Control2/VBoxContainer/PlayButton.pressed.connect(resume)
	$Control2/VBoxContainer/Quit.pressed.connect(get_tree().quit)
	pause()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			resume()
		else:
			pause()

func pause():
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume():
	visible = false
	get_tree().paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
