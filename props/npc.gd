
extends CharacterBody2D

@export var target_speed := 80.0
@export var offset := 20
@export var speed := 1
@export var start_waypoint: Waypoint
@export var progress_disable: String = ""

var current_wp: Waypoint
var target_wp: Waypoint
var previous_wp: Waypoint
var waiting := false
var move_dir := Vector2.ZERO
var target := Vector2.ZERO

@export var dialog_timeline: String = "" # pass the Dialogic timeline id or path here

enum {
	MOVE,
	TALK
}

var state = MOVE
var npc_approach = false

var player_in_range: bool = false
var player_ref = null

var sprite_yoff = 0
var eyes = null
var eyes_origin = Vector2.ZERO
var eyes_offset = Vector2.ZERO

@onready var anim = $AnimationPlayer

func _ready():
	current_wp = start_waypoint
	start_waypoint.home = true
	target_wp = start_waypoint
	global_position = current_wp.global_position
	previous_wp = current_wp
	sprite_yoff = $Icon.offset.y
	add_to_group("interactable_npcs")
	if $InteractArea:
		$InteractArea.body_entered.connect(_on_body_entered)
		$InteractArea.body_exited.connect(_on_body_exited)
	target = global_position
	Dialogic.timeline_ended.connect(_on_dialogue_finished)

	if has_node("Icon/Eyes"):
		eyes = get_node("Icon/Eyes")
		eyes_origin = eyes.get("position")
		eyes_offset = eyes_origin
	_blink_animation()

	# _pick_next_waypoint()

func _physics_process(delta):
	if state == TALK:
		velocity = Vector2.ZERO
		_face_player()
		move_and_slide()
		update_animation()
		return

	var dir = (target_wp.global_position - target)
	var approach_dist = 6.0
	if npc_approach:
		approach_dist = 100.0
	if dir.length() < approach_dist and not waiting:
		_arrive_at_waypoint()

	var right_side = Vector2.ZERO
	if not waiting and target_wp != null:
		right_side = Vector2(-dir.normalized().y, dir.normalized().x) * offset
		target += dir.normalized() * target_speed * delta
	velocity = (target - global_position) * speed + right_side
	if velocity.x < 0:
		$Icon.scale.x = -1
	else:
		$Icon.scale.x = 1
	if waiting and velocity.length() < 5.0:
		if current_wp == start_waypoint:
			$Icon.scale.x = start_waypoint.facing_dir
		else:
			$Icon.scale.x = -current_wp.facing_dir
	move_and_slide()
	
	if (global_position-target).length() > 500.0:
		global_position = target
	$Sprite2D.global_position = target
	update_animation()

func _on_body_entered(body: Node) -> void:
	#print("[NPC] Body entered interaction area: %s" % body)
	# detect the Player by script path or node name
	if body == null:
		return
	var is_player := false
	if body.name == "Player":
		is_player = true
	elif body.get_script() and body.get_script().resource_path == "res://player/Player.gd":
		is_player = true
	if is_player:
		player_in_range = true
		player_ref = body

func _on_body_exited(body: Node) -> void:
	#print("[NPC] Body exited interaction area: %s" % body)
	if body == null:
		return
	if body == player_ref:
		player_in_range = false
		player_ref = null

func _pick_next_waypoint():
	if current_wp.connections.is_empty():
		target_wp = null
		return

	var choices: Array[Waypoint] = []
	
	for wp in current_wp.connections:
		if wp == previous_wp:
			continue
		if wp.home:
			if wp == start_waypoint or (wp.open and not wp.occupied):
				pass
			else:
				continue
		choices.append(wp)

	if choices.is_empty():
		choices = current_wp.connections.duplicate()

	target_wp = choices.pick_random()
	if target_wp.open:
		target_wp.occupied = true
		npc_approach = true
	else:
		npc_approach = false
	previous_wp = current_wp

func _arrive_at_waypoint():
	current_wp = target_wp
	#velocity = Vector2.ZERO
	if not npc_approach:
		target = current_wp.global_position

	if current_wp == start_waypoint:
		waiting = true
		current_wp.open = true
		await get_tree().create_timer(30+randf_range(0.0, 90)).timeout
		while current_wp.occupied or not Dialogic.VAR.bunnyOpen:
			await get_tree().create_timer(10+randf_range(0.0, 50)).timeout
		current_wp.open = false
		waiting = false
	elif current_wp.occupied:
		waiting = true
		await get_tree().create_timer(10+randf_range(0.0, 50)).timeout
		current_wp.occupied = false
		waiting = false
	else:
		pass

	_pick_next_waypoint()

func _face_player():
	if player_ref == null:
		return

	var dir = player_ref.global_position.x - global_position.x
	if dir < 0:
		$Icon.scale.x = -1
	else:
		$Icon.scale.x = 1

func update_animation():
	var anim_name := ""
	
	if (waiting and velocity.length() < 5.0) or state == TALK:
		anim_name = "idle"
	else:
		anim_name = "walk"
	
	# Only play if different to avoid restarting every frame
	if anim.current_animation != anim_name:
		anim.play(anim_name)
		if anim_name == "walk":
			anim.seek(0.2, true)  # jump to frame 2 immediately
	
	if anim.current_animation == "walk":
		if $Icon.frame == 0 or $Icon.frame == 4:
			$Icon.offset.y = sprite_yoff + 4
		if $Icon.frame == 1 or $Icon.frame == 3:
			$Icon.offset.y = sprite_yoff + 2
		if $Icon.frame == 2:
			$Icon.offset.y = sprite_yoff
		anim.speed_scale = min(1.0, velocity.length()/72.0)
	else:
		$Icon.offset.y = sprite_yoff
	
	if eyes:
		# eyes.rotation = ($Icon.scale.x*Vector2(1.0, 0.0)).angle()
		var eye_highlight_offset = Vector2($Icon.scale.x*3.5, -3.5)
		# eyes.position.x = eyes_origin.x * ($Icon.scale.x)
		# print(eyes.position.x)
		eyes.position.y = eyes_origin.y + ($Icon.offset.y - sprite_yoff)
		eyes.get_node("Line2D3").position = eyes.get_node("Line2D").position + eye_highlight_offset
		eyes.get_node("Line2D4").position = eyes.get_node("Line2D2").position + eye_highlight_offset

func _blink_animation() -> void:
	if eyes:
		var eye_blink_width = 3.0
		var eye_blink_length = 10.0
		var eye_hightlight_width = 3.0
		eyes.get_node("Line2D").width = eye_blink_width
		eyes.get_node("Line2D").points[0].x -= eye_blink_length / 2
		eyes.get_node("Line2D").points[1].x += eye_blink_length / 2
		eyes.get_node("Line2D2").width = eye_blink_width
		eyes.get_node("Line2D2").points[0].x -= eye_blink_length / 2
		eyes.get_node("Line2D2").points[1].x += eye_blink_length / 2
		eyes.get_node("Line2D3").width = 0.0
		eyes.get_node("Line2D4").width = 0.0
		await get_tree().create_timer(0.1).timeout
		eyes.get_node("Line2D").width = 12.0
		eyes.get_node("Line2D").points[0].x += eye_blink_length / 2
		eyes.get_node("Line2D").points[1].x -= eye_blink_length / 2
		eyes.get_node("Line2D2").width = 12.0
		eyes.get_node("Line2D2").points[0].x += eye_blink_length / 2
		eyes.get_node("Line2D2").points[1].x -= eye_blink_length / 2
		eyes.get_node("Line2D3").width = eye_hightlight_width
		eyes.get_node("Line2D4").width = eye_hightlight_width
		await get_tree().create_timer(2.0 + randf() * 1.0).timeout
		_blink_animation()

func start_dialogue() -> void:
	print("[NPC] Starting dialogue: %s" % dialog_timeline)
	if dialog_timeline == "":
		return
	state = TALK
	waiting = true
	velocity = Vector2.ZERO
	# Prefer the global Dialogic autoload if present
	if typeof(Dialogic) != TYPE_NIL:
		Dialogic.start(dialog_timeline)
	else:
		# fallback: try Engine singleton check
		if Engine.has_singleton("Dialogic"):
			var d = Engine.get_singleton("Dialogic")
			if d and d.has_method("start"):
				d.start(dialog_timeline)
				return
		print("[NPC] Dialogic not available or not autoloaded")
		player_ref.state = player_ref.MOVE

func _on_dialogue_finished() -> void:
	# print("back to move")
	state = MOVE
	waiting = false
