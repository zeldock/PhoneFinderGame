extends Area3D

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	for ray in body.find_children("*", "RayCast3D", true, false):
		if "endingActivated" in ray:
			ray.endingActivated = true
