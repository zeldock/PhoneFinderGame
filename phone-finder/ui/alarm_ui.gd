extends CanvasLayer

@onready var display = $ControlBlur/Paper/Display
@onready var keypad = $ControlBlur/Paper/Keypad
var typed := ""
var correct_code := ""
var on_success: Callable

func _ready():
	$ControlBlur.set_anchors_preset(Control.PRESET_FULL_RECT)
	visible = false
	for key in ["1","2","3","4","5","6","7","8","9","Clear","0","Enter"]:
		var b = Button.new()
		b.text = key
		b.custom_minimum_size = Vector2(120, 100)
		b.pressed.connect(press.bind(key))
		keypad.add_child(b)

func open(code, success):
	correct_code = code
	on_success = success
	typed = ""
	update_display()
	visible = true
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close():
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	await get_tree().create_timer(0.1).timeout
	get_tree().paused = false

func press(key):
	$BeepSound.play()
	if key == "Clear":
		typed = ""
	elif key == "Enter":
		if typed == correct_code:
			display.text = "OK"
			$CorrectSound.play()
			on_success.call()
			await get_tree().create_timer(0.8).timeout
			close()
			return
		display.text = "WRONG"
		$WrongSound.play()
		typed = ""
		await get_tree().create_timer(0.8).timeout
	elif typed.length() < correct_code.length():
		typed += key
	update_display()

func update_display():
	display.text = typed + "-".repeat(correct_code.length() - typed.length())

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("interact"):
		close()
	elif event is InputEventKey and event.pressed and not event.echo:
		var k = OS.get_keycode_string(event.keycode)
		if k.is_valid_int():
			press(k)
		elif event.keycode == KEY_ENTER:
			press("Enter")
		elif event.keycode == KEY_BACKSPACE:
			press("Clear")
