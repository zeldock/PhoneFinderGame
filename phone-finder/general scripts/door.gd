extends Node3D
@export var locked_message := "It's locked."
@export var required_key_id := ""
var unlocked := false
var opened = false

func toggle_door():
	if $AnimationPlayer.current_animation != "open":
		opened = !opened
		if !opened:
			if has_node("DoorSound"): $DoorSound.play()
			$AnimationPlayer.play_backwards("open")
		if opened:
			if has_node("DoorSound"): $DoorSound.play()
			$AnimationPlayer.play("open")
