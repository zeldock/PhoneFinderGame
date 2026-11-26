extends CanvasLayer

var ended: bool = false
@onready var label = $Control2/Label

func _ready(): #when the game starts
	for b in $Control2/VBoxContainer.get_children(): b.pressed.connect($ClickSound.play)
	$Control2/VBoxContainer/Quit.pressed.connect(get_tree().quit)
	$Control2/VBoxContainer/Restart.pressed.connect(restart)
	visible = false
	
func endgame(text, won := true):
	get_tree().paused = true #pauses game
	label.text = text #sets label text
	ended = true
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE #makes mouse visible
	if won:
		$WinSound.play()
	else:
		$LoseSound.play()

func restart():
	get_tree().paused = false
	get_tree().reload_current_scene()
