extends CharacterBody2D

@export var MAX_SPEED = 80
@export var ACCEL = 500
@export var FRICT = 500

enum{
	MOVE,
	TALK
}
var state = MOVE
var can_interact = true
var vel = Vector2.ZERO
var p_vel = vel
var p_dir = Vector2(1.0, 0.0)
var input = Vector2.ZERO
var p_input = input
var p_is_on_floor = true

# Animation controller
var tail = null
var tail_origin = Vector2.ZERO
var tail_offset = Vector2.ZERO
var neck = null
var neck_origin = Vector2.ZERO
var neck_offset = Vector2.ZERO
var head = null
var head_origin = Vector2.ZERO
var head_offset = Vector2.ZERO
var sin_wave = 0.0
var eyes = null
var eyes_origin = Vector2.ZERO
var eyes_offset = Vector2.ZERO

@onready var level = get_tree().get_current_scene()
@onready var stats = GameState.playerStats

func _ready():
	randomize()
	var _startingPosition = position
	stats.connect("no_health", Callable(self, "queue_free"))
	# Listen for Dialogic timeline end so we can return to MOVE state after talking
	if typeof(Dialogic) != TYPE_NIL:
		if Dialogic.has_subsystem('Text'):
			var _text_sys = Dialogic.get_subsystem('Text')
			if not _text_sys.is_connected('animation_textbox_hide', Callable(self, '_on_dialogue_hide')):
				_text_sys.animation_textbox_hide.connect(Callable(self, '_on_dialogue_hide'))
	else:
		if Engine.has_singleton("Dialogic"):
			var d = Engine.get_singleton("Dialogic")
			if d and d.has_subsystem('Text'):
				var _ts = d.get_subsystem('Text')
				if not _ts.is_connected('animation_textbox_hide', Callable(self, '_on_dialogue_hide')):
					_ts.animation_textbox_hide.connect(Callable(self, '_on_dialogue_hide'))

	if has_node("Tail"):
		tail = get_node("Tail")
		tail_origin = tail.get("offset")
		tail_offset = tail_origin

	if has_node("Neck"):
		neck = get_node("Neck")
		neck_origin = neck.get("offset")
		neck_offset = neck_origin

	if has_node("Head"):
		head = get_node("Head")
		head_origin = head.get("offset")
		head_offset = head_origin

	if has_node("Eyes"):
		eyes = get_node("Eyes")
		eyes_origin = eyes.get("position")
		eyes_offset = eyes_origin
	_blink_animation()

func _physics_process(delta):
	match state:
		MOVE:
			interact()
			move_state(delta)
	
	#update to previous values
	update_p_values()

func move_state(delta):
	#get user input
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	if input.length() > 1.0:
		input = input.normalized()
	
	#movement
	if input != Vector2.ZERO:
		vel.x = move_toward(vel.x, input.x * MAX_SPEED, ACCEL * delta)
		vel.y = move_toward(vel.y, input.y * MAX_SPEED, ACCEL * delta)
	else:
		vel.x = move_toward(vel.x, 0, FRICT * delta)
		vel.y = move_toward(vel.y, 0, FRICT * delta)

	#calculate collisions
	move()

	var wave_offset = 0.0
	if vel != Vector2.ZERO && get_last_motion().length() > 0.01:
		sin_wave += get_last_motion().length()/10.0 * 0.2
		wave_offset = -sin(sin_wave) * 20.0
	else:
		sin_wave = 0.0
		wave_offset = 0.0

	# Update the offsets for the animated parts
	if tail:
		tail.offset = lerp(tail.offset, Vector2(0, tail_origin.y) + (tail_origin.x - wave_offset) * p_dir, 0.1)
	if neck:
		neck.offset = lerp(neck.offset, Vector2(0, neck_origin.y) + (neck_origin.x + wave_offset) * p_dir, 0.1)
		if tail:
			neck.end_offset = tail.offset
	if head:
		head.offset = lerp(head.offset, Vector2(0, head_origin.y) + (head_origin.x + wave_offset) * p_dir, 0.1)
		if neck:
			head.end_offset = neck.offset
	if eyes:
		eyes.position = lerp(eyes.position, Vector2(0, eyes_origin.y) + (eyes_origin.x + wave_offset) * p_dir, 0.1)
		eyes.rotation = (p_dir.angle())
		var eye_highlight_offset = Vector2(4.3, -2.5)
		eyes.get_node("Line2D3").position = eyes.get_node("Line2D").position + eye_highlight_offset.rotated(-p_dir.angle())
		eyes.get_node("Line2D4").position = eyes.get_node("Line2D2").position + eye_highlight_offset.rotated(-p_dir.angle())

func interact():
	#interact with objects
	if Input.is_action_just_pressed("interact") and can_interact:
		# look for any nearby NPCs (they add themselves to the 'interactable_npcs' group)
		for npc in get_tree().get_nodes_in_group("interactable_npcs"):
			if npc.has_method("start_dialogue") and npc.player_in_range:
				# trigger Dialogic timeline on the NPC
				npc.start_dialogue()
				p_dir = (npc.position - global_position).normalized()
				state = TALK
				can_interact = false
				return

func move():
	set_velocity(vel)
	set_up_direction(Vector2(0,-1))
	move_and_slide()
	vel = velocity

func update_p_values():
	p_vel = vel
	if vel != Vector2.ZERO:
		p_dir = vel.normalized()
	p_input = input
	p_is_on_floor = is_on_floor()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	$Hurtbox.start_invincibility(0.5)
	$Hurtbox.create_hit_effect()

func _on_dialogue_hide() -> void:
	state = MOVE
	while Dialogic.get_subsystem("Text").is_textbox_visible():
		await get_tree().process_frame
	can_interact = true

func _blink_animation() -> void:
	if eyes:
		var eye_blink_width = 3.0
		var eye_blink_length = 10.0
		var eye_hightlight_width = 4.0
		eyes.get_node("Line2D").width = eye_blink_width
		eyes.get_node("Line2D").points[0].y -= eye_blink_length / 2
		eyes.get_node("Line2D").points[1].y += eye_blink_length / 2
		eyes.get_node("Line2D2").width = eye_blink_width
		eyes.get_node("Line2D2").points[0].y -= eye_blink_length / 2
		eyes.get_node("Line2D2").points[1].y += eye_blink_length / 2
		eyes.get_node("Line2D3").width = 0.0
		eyes.get_node("Line2D4").width = 0.0
		await get_tree().create_timer(0.1).timeout
		eyes.get_node("Line2D").width = 12.0
		eyes.get_node("Line2D").points[0].y += eye_blink_length / 2
		eyes.get_node("Line2D").points[1].y -= eye_blink_length / 2
		eyes.get_node("Line2D2").width = 12.0
		eyes.get_node("Line2D2").points[0].y += eye_blink_length / 2
		eyes.get_node("Line2D2").points[1].y -= eye_blink_length / 2
		eyes.get_node("Line2D3").width = eye_hightlight_width
		eyes.get_node("Line2D4").width = eye_hightlight_width
		await get_tree().create_timer(2.0 + randf() * 1.0).timeout
		_blink_animation()
