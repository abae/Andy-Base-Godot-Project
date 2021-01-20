extends KinematicBody2D

export var MAX_SPEED = 80
export var ACCEL = 500
export var FRICT = 500

enum{
	MOVE,
}

var state = MOVE
var velocity = Vector2.ZERO

onready var level = get_tree().get_current_scene()
onready var stats = GameState.playerStats
onready var hitbox = $Hitbox
onready var hurtbox = $Hurtbox
onready var sfx = $SFX

signal screen_shake(shakeMagnitude, shakeLength)
signal cam_move(x, y)
signal cam_zoom(value)
signal cam_free(state)

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")

func _process(delta):
	match state:
		MOVE:
			move_state(delta)

func move_state(delta):
	#get user input
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	#movement
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICT * delta)
	
	#calculate collisions
	move()

func move():
	velocity = move_and_slide(velocity)
	if Input.is_action_pressed("ui_accept"):
		emit_signal("cam_move", 300, 300)
		emit_signal("cam_zoom", .5)
	else:
		emit_signal("cam_free", false)


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
