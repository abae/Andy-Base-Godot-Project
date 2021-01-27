extends KinematicBody2D

export var MAX_SPEED = 80
export var ACCEL = 500
export var FRICT = 500
export var GRAVITY = 700
export var FALL_GRAVITY = 300
export var JUMP_SPEED = 280
export var FALL_SPEED = 300

export var SQUISHINESS = 0.1

enum{
	MOVE,
}
var state = MOVE
var vel = Vector2.ZERO
var p_vel = vel
var input = Vector2.ZERO
var p_input = input
var p_is_on_floor = true

onready var level = get_tree().get_current_scene()
onready var stats = GameState.playerStats

const Dust = preload("res://effect/Dust.tscn")

func _ready():
	randomize()
	var startingPosition = position
	stats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
	
	#update to previous values
	update_p_values()

func move_state(delta):
	#get user input
	input.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	if input.length() > 1.0:
		input = input.normalized()
	
	#horizontal movement
	if input != Vector2.ZERO:
		vel.x = move_toward(vel.x, input.x * MAX_SPEED, ACCEL * delta)
	else:
		vel.x = move_toward(vel.x, 0, FRICT * delta)
	
	#vertical movement
	vel.y = move_toward(vel.y, FALL_SPEED, GRAVITY * delta)
	if !Input.is_action_pressed("jump"):
		vel.y = move_toward(vel.y, FALL_SPEED, FALL_GRAVITY * delta)
	#jumping
	if is_on_floor():
		$JumpTimer.start()
	if jump():
		vel.y -= JUMP_SPEED
		
	#calculate collisions
	move()
	
	#sprite manipulation
	squash_n_stretch()
	if is_on_floor():
		if(input.x > 0 && p_input.x <= 0):
			emit_dust($BottomLeft.global_position)
		if(input.x < 0 && p_input.x >= 0):
			emit_dust($BottomRight.global_position)
		if !p_is_on_floor:
			emit_dust($BottomLeft.global_position)
			emit_dust($BottomRight.global_position)

func move():
	vel = move_and_slide(vel, Vector2(0,-1))
func jump() -> bool:
	if Input.is_action_pressed("jump"):
		if !$PreJumpTimer.is_stopped() && is_on_floor():
			return true
	if Input.is_action_just_pressed("jump"):
		$PreJumpTimer.start()
		if !$JumpTimer.is_stopped():
			$JumpTimer.stop()
			return true
	return false

func squash_n_stretch():
	var squash = -SQUISHINESS * abs(vel.y)/MAX_SPEED
	$Sprite.scale = Vector2(sign($Sprite.scale.x)*(1 + squash), 1 - squash)
	#flip sprite for direction
	if vel.x > 0:
		$Sprite.scale.x = abs($Sprite.scale.x)
		$Hair.offset.x = -2
	elif vel.x < 0:
		$Sprite.scale.x = -abs($Sprite.scale.x)
		$Hair.offset.x = 2
func emit_dust(pos):
	$DustTimer.start()
	var dust = Dust.instance()
	level.get_node("Particles").add_child(dust)
	dust.scale.x = sign(pos.x - global_position.x)
	dust.global_position = pos

func update_p_values():
	p_vel = vel
	p_input = input
	p_is_on_floor = is_on_floor()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	$Hurtbox.start_invincibility(0.5)
	$Hurtbox.create_hit_effect()

func _on_DustTimer_timeout():
	if is_on_floor():
		if(input.x > 0):
			emit_dust($BottomLeft.global_position)
		if(input.x < 0):
			emit_dust($BottomRight.global_position)
