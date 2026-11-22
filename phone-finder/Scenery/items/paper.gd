extends StaticBody3D
@export_multiline var note_text := ""
@export var alarm_panel: Node

func get_text():
	if alarm_panel:
		return note_text.replace("{code}", alarm_panel.alarm_code)
	return note_text
