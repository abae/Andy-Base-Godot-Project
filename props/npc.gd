
extends CharacterBody2D

@export var speed := 80.0
@export var start_waypoint: Waypoint

var current_wp: Waypoint
var target_wp: Waypoint
var waiting := false

@export var dialog_timeline: String = "" # pass the Dialogic timeline id or path here

var player_in_range: bool = false
var player_ref = null

func _ready():
	current_wp = start_waypoint
	_pick_next_waypoint()
	add_to_group("interactable_npcs")
	if $InteractArea:
		$InteractArea.body_entered.connect(_on_body_entered)
		$InteractArea.body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if waiting or target_wp == null:
		velocity = Vector2.ZERO
		return

	var dir = (target_wp.global_position - global_position)
	if dir.length() < 6.0:
		_arrive_at_waypoint()
		return

	velocity = dir.normalized() * speed
	move_and_slide()

func _on_body_entered(body: Node) -> void:
	print("[NPC] Body entered interaction area: %s" % body)
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
	print("[NPC] Body exited interaction area: %s" % body)
	if body == null:
		return
	if body == player_ref:
		player_in_range = false
		player_ref = null

func _pick_next_waypoint():
	if current_wp.connections.is_empty():
		target_wp = null
		return

	target_wp = current_wp.connections.pick_random()

func _arrive_at_waypoint():
	current_wp = target_wp
	velocity = Vector2.ZERO

	if current_wp.wait_time > 0:
		waiting = true
		await get_tree().create_timer(current_wp.wait_time).timeout
		waiting = false

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

