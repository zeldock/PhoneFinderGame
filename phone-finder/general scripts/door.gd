extends Node3D
@export var locked_message := "It's locked."
@export var required_key_id := ""
var unlocked := false
var opened = false

func toggle_door():
	if $AnimationPlayer.current_animation != "open":
		opened = !opened
		if !opened:
			$AnimationPlayer.play_backwards("open")
		if opened:
			$AnimationPlayer.play("open")
