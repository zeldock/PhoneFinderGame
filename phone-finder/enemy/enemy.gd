extends CharacterBody3D

@export var catch_range := 1.2
@export var wander_speed := 1.5
@export var chase_speed := 3.5
@export var detect_range := 6.0
@export var lose_range := 10.0
@export var stuck_time := 1.5

@onready var agent: NavigationAgent3D = $NavigationAgent3D
var player: Node3D
var chasing := false
var stuck_timer := 0.0
var last_pos := Vector3.ZERO
var give_up_time := 0.0

func _ready():
	player = get_tree().get_first_node_in_group("player")
	await get_tree().physics_frame
	pick_wander_point()

func pick_wander_point():
	var map = get_world_3d().navigation_map
	agent.target_position = NavigationServer3D.map_get_random_point(map, 1, false)

func _physics_process(delta):
	var straight = global_position.distance_to(player.global_position)
	var dist = path_distance_to(player.global_position)

	if straight < catch_range:
		player.get_node("player_ui/EndMenu").endgame("It caught you.", false)
		return

	if chasing and dist > lose_range:
		chasing = false
		pick_wander_point()
	elif not chasing and dist < detect_range and give_up_time <= 0:
		chasing = true
		$SpottedSound.play(0.5)

	if chasing:
		agent.target_position = player.global_position
	elif agent.is_navigation_finished():
		pick_wander_point()

	var dir = agent.get_next_path_position() - global_position
	dir.y = 0
	dir = dir.normalized()
	var speed = chase_speed if chasing else wander_speed
	velocity.x = dir.x * speed
	velocity.z = dir.z * speed
	if not is_on_floor():
		velocity.y -= 9.8 * delta
	if dir.length() > 0.01:
		look_at(global_position + dir, Vector3.UP)
	move_and_slide()

	for i in get_slide_collision_count():
		var hit = get_slide_collision(i).get_collider()
		if hit and hit.name == "door":
			var door = hit.get_parent().get_parent().get_parent()
			if not door.opened and (door.required_key_id == "" or door.unlocked):
				door.toggle_door()

	give_up_time -= delta
	stuck_timer += delta
	if stuck_timer >= stuck_time:
		if global_position.distance_to(last_pos) < 0.3:
			if chasing:
				chasing = false
				give_up_time = 2.0
			pick_wander_point()
		last_pos = global_position
		stuck_timer = 0.0

func path_distance_to(target: Vector3) -> float:
	var map = get_world_3d().navigation_map
	var path = NavigationServer3D.map_get_path(map, global_position, target, true)
	if path.size() < 2:
		return INF
	var total := 0.0
	for i in range(1, path.size()):
		total += path[i - 1].distance_to(path[i])
	return total
