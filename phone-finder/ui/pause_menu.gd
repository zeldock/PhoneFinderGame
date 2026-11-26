extends CanvasLayer

@onready var end_menu = get_parent().get_node("EndMenu")

func _ready():
	for b in $Control2/VBoxContainer.get_children(): b.pressed.connect($ClickSound.play)
	$Control2/VBoxContainer/PlayButton.pressed.connect(resume)
	$Control2/VBoxContainer/Quit.pressed.connect(get_tree().quit)
	$Control2/VBoxContainer/Restart.pressed.connect(restart)
	pause()

func _input(event):
	if event.is_action_pressed("ui_cancel"): #if esc is pressed
		if visible:
			if !end_menu.ended:
				resume()
		else:
			if !end_menu.ended:
				pause()

func pause():
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume():
	visible = false
	var note = get_parent().get_node("NoteContents")
	var alarm = get_parent().get_node("AlarmUI")
	if alarm.visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if not note.visible and not alarm.visible:
		get_tree().paused = false

func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
