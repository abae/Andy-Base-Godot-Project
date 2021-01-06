extends KinematicBody2D

export var MAX_SPEED = 80
export var ACCEL = 500
export var FRICT = 500

enum{
	MOVE,
}

var state = MOVE
var velocity = Vector2.ZERO
var stats = PlayerStats

onready var swordHitbox = $Hitbox
onready var hurtbox = $Hurtbox

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
	


func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()
