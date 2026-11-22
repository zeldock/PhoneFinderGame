extends StaticBody3D
@export var unlocks_key_id := "alarm"
var alarm_code := ""

func _ready():
	alarm_code = str(randi_range(1000, 9999))
