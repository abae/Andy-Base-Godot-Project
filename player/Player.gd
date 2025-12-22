extends CharacterBody2D

@export var MAX_SPEED = 80
@export var ACCEL = 500
@export var FRICT = 500

enum{
	MOVE,
}
var state = MOVE
var vel = Vector2.ZERO
var p_vel = vel
var input = Vector2.ZERO
var p_input = input
var p_is_on_floor = true

@onready var level = get_tree().get_current_scene()
@onready var stats = GameState.playerStats

const Dust = preload("res://effect/Dust.tscn")

func _ready():
	randomize()
	var _startingPosition = position
	stats.connect("no_health", Callable(self, "queue_free"))

func _physics_process(delta):
	match state:
		MOVE:
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

func move():
	set_velocity(vel)
	set_up_direction(Vector2(0,-1))
	move_and_slide()
	vel = velocity

func update_p_values():
	p_vel = vel
	p_input = input
	p_is_on_floor = is_on_floor()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	$Hurtbox.start_invincibility(0.5)
	$Hurtbox.create_hit_effect()

