extends CanvasLayer

@onready var label = $ControlBlur/Paper/Label

func _ready():
	visible = false

func show_note(text):
	label.text = text
	visible = true
	get_tree().paused = true

func _input(event):
	if visible and event.is_action_pressed("interact"):
		visible = false
		await get_tree().create_timer(0.1).timeout
		get_tree().paused = false
