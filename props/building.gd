extends StaticBody2D

@export var dialog_timeline: String = "" # pass the Dialogic timeline id or path here
@export var progress_disable: String = ""

var player_in_range: bool = false
var player_ref = null

func _ready() -> void:
	add_to_group("interactable_npcs")
	if $InteractArea:
		$InteractArea.body_entered.connect(_on_body_entered)
		$InteractArea.body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if Dialogic.VAR.get(progress_disable):
		remove_from_group("interactable_npcs")

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
