
extends CharacterBody2D

@export var target_speed := 80.0
@export var offset := 20
@export var speed := 1
@export var start_waypoint: Waypoint

var current_wp: Waypoint
var target_wp: Waypoint
var previous_wp: Waypoint
var waiting := false
var move_dir := Vector2.ZERO
var target := Vector2.ZERO

@export var dialog_timeline: String = "" # pass the Dialogic timeline id or path here

var player_in_range: bool = false
var player_ref = null

func _ready():
	current_wp = start_waypoint
	start_waypoint.home = true
	target_wp = start_waypoint
	global_position = current_wp.global_position
	previous_wp = current_wp
	add_to_group("interactable_npcs")
	if $InteractArea:
		$InteractArea.body_entered.connect(_on_body_entered)
		$InteractArea.body_exited.connect(_on_body_exited)
	target = global_position

func _physics_process(delta):
	var dir = (target_wp.global_position - target)
	if dir.length() < 6.0 and not waiting:
		_arrive_at_waypoint()

	var right_side = Vector2.ZERO
	if not waiting and target_wp != null:
		right_side = Vector2(-dir.normalized().y, dir.normalized().x) * offset
		target += dir.normalized() * target_speed * delta
	velocity = (target - global_position) * speed + right_side
	move_and_slide()
	
	$Sprite2D.global_position = target

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
	previous_wp = current_wp

func _arrive_at_waypoint():
	current_wp = target_wp
	#velocity = Vector2.ZERO
	target = current_wp.global_position

	if current_wp == start_waypoint:
		waiting = true
		current_wp.open = true
		await get_tree().create_timer(30+randf_range(0.0, 90)).timeout
		while current_wp.occupied:
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

func start_dialogue() -> void:
	print("[NPC] Starting dialogue: %s" % dialog_timeline)
	if dialog_timeline == "":
		return
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
