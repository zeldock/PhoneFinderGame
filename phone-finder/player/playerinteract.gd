extends RayCast3D

@onready var ui = get_parent().get_parent().get_node("player_ui")
@onready var crosshair = ui.get_node("MainCrosshair/crosshair")
@onready var unlock_crosshair = ui.get_node("UnlockCrosshair/crosshairunlock")
@onready var text_box = ui.get_node("TextBox/container/hud")
@onready var hold_point = get_viewport().get_camera_3d().get_node("HoldPoint")
@onready var note_ui = ui.get_node("NoteContents")
@onready var end_ui = ui.get_node("EndMenu")
@onready var alarm_ui = ui.get_node("AlarmUI")

var keys = []
var flashing := false
var held_item = null
var endingActivated = false

func _ready():
	unlock_crosshair.visible = false
	text_box.visible = false

func _physics_process(delta: float) -> void:
	if flashing: return
	if held_item and Input.is_action_just_pressed("interact") and held_item.can_drop():
		held_item.drop()
		remove_exception(held_item)
		held_item = null
		return
	if is_colliding():
		var hit = get_collider()
		if hit.name == "door":
			if !crosshair.visible:
				crosshair.visible = true
			if Input.is_action_just_pressed("interact"):
				use_door(hit.get_parent().get_parent().get_parent())
		elif hit.name == "drawer":
			if !crosshair.visible:
				crosshair.visible = true
			if Input.is_action_just_pressed("interact"):
				#hit.get_parent().get_parent().toggle_door()
				use_door(hit.get_parent().get_parent())
		elif "key_id" in hit:
			if !crosshair.visible:
				crosshair.visible = true
			if Input.is_action_just_pressed("interact"):
				keys.append(hit.key_id)
				$PickupSound.play()
				show_text("Picked up: " + hit.display_name)
				hit.get_parent().get_parent().queue_free()
		elif "note_text" in hit:
			if !crosshair.visible:
				crosshair.visible = true
			if Input.is_action_just_pressed("interact"):
				note_ui.show_note(hit.get_text())
				$NoteSound.play()
		elif "end_text" in hit and endingActivated:
			if !crosshair.visible:
				crosshair.visible = true
			if Input.is_action_just_pressed("interact"):
				end_ui.endgame(hit.get_text())
		elif "alarm_code" in hit:
			if !crosshair.visible:
				crosshair.visible = true
			if Input.is_action_just_pressed("interact"):
				if hit.unlocks_key_id in keys:
					show_text("Alarm already disarmed.")
				else:
					alarm_ui.open(hit.alarm_code, func(): keys.append(hit.unlocks_key_id))
		elif (hit.has_method("pick_up") or hit.get_parent().has_method("pick_up")) and held_item == null:
			if !crosshair.visible:
				crosshair.visible = true
			if Input.is_action_just_pressed("interact"):
				var item = hit if hit.has_method("pick_up") else hit.get_parent()
				if item.pick_up(hold_point, get_parent().get_parent()):
					held_item = item
					add_exception(item)
		else:
			if crosshair.visible:
				crosshair.visible = false
	else:
		if crosshair.visible:
			crosshair.visible = false

func use_door(door):
	if (door.required_key_id == "" and !has_node("drawer")) or door.unlocked or (has_node("drawer") and door.drawer.required_key_id == ""):
		door.toggle_door()
	elif door.required_key_id in keys:
		door.unlocked = true
		if door.has_node("UnlockSound"): door.get_node("UnlockSound").play()
		door.toggle_door()
		flashing = true
		crosshair.visible = false
		unlock_crosshair.visible = true
		await get_tree().create_timer(1.0).timeout
		unlock_crosshair.visible = false
		flashing = false
	else:
		if door.has_node("LockedSound"): door.get_node("LockedSound").play()
		show_text(door.locked_message)

func show_text(msg):
	text_box.text = msg
	text_box.visible = true
	await get_tree().create_timer(2.0).timeout
	text_box.visible = false
