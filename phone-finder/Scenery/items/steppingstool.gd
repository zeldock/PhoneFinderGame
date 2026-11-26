extends RigidBody3D

var held := false
var hold_point: Node3D
var player: Node
var body_shape: CollisionShape3D
var meshes = []

func _ready():
	lock_rotation = true
	freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	freeze = true
	for child in get_children():
		if child is CollisionShape3D:
			body_shape = child
	meshes = find_children("*", "MeshInstance3D", true, false)
	contact_monitor = true
	max_contacts_reported = 1
	body_entered.connect(_on_landed)

func pick_up(point, who) -> bool:
	for i in who.get_slide_collision_count():
		if who.get_slide_collision(i).get_collider() == self:
			return false
	held = true
	$PickupSound.play()
	hold_point = point
	player = who
	freeze = true
	add_collision_exception_with(player)
	return true

func can_drop() -> bool:
	var flat = Vector2(global_position.x - player.global_position.x, global_position.z - player.global_position.z)
	if flat.length() < 1.0:
		return false
	var query = PhysicsShapeQueryParameters3D.new()
	query.shape = body_shape.shape
	query.transform = body_shape.global_transform
	query.exclude = [get_rid()]
	for r in get_world_3d().direct_space_state.intersect_shape(query):
		if r.collider == player:
			return false
	return true

func set_fade(amount):
	for m in meshes:
		m.transparency = amount

func drop():
	held = false
	set_fade(0.0)
	freeze = false
	sleeping = false
	remove_collision_exception_with(player)

func _on_landed(_body):
	if not held and not freeze:
		$DropSound.play()

func _physics_process(delta):
	if held:
		var cam = get_viewport().get_camera_3d()
		var target = hold_point.global_position
		var query = PhysicsRayQueryParameters3D.create(cam.global_position, target)
		query.exclude = [get_rid(), player.get_rid()]
		var hit = get_world_3d().direct_space_state.intersect_ray(query)
		if hit:
			target = hit.position - (target - cam.global_position).normalized() * 0.5
		var dist = cam.global_position.distance_to(target)
		var fade = clamp(remap(dist, 1.5, 0.8, 0.0, 0.8), 0.0, 0.8)
		if not can_drop():
			fade = max(fade, 0.6)
		set_fade(fade)
		global_position = target
		global_rotation = Vector3(0, hold_point.global_rotation.y, 0)
	elif not freeze and sleeping:
		freeze = true
