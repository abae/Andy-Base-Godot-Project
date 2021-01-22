extends KinematicBody2D

export var MAX_SPEED = 80
export var ACCEL = 500
export var FRICT = 500
export var GRAVITY = 800
export var JUMP_SPEED = 600
export var FALL_SPEED = 800

export var SQUISHINESS = 0.08

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
onready var sprite = $Sprite
onready var hitbox = $Hitbox
onready var hurtbox = $Hurtbox
onready var sfx = $SFX

const Dust = preload("res://effect/Dust.tscn")

signal screen_shake(shakeMagnitude, shakeLength)
signal cam_move(x, y)
signal cam_zoom(value)
signal cam_free(state)

func _ready():
	randomize()
	stats.connect("no_health", self, "queue_free")

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)
	
	#update to previous values
	update_p_values()

func move_state(delta):
	#get user input
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if input.length() > 1.0:
		input = input.normalized()
	
	#horizontal movement
	if input != Vector2.ZERO:
		vel.x = move_toward(vel.x, input.x * MAX_SPEED, ACCEL * delta)
	else:
		vel.x = move_toward(vel.x, 0, FRICT * delta)
	
	#vertical movement
	vel.y = move_toward(vel.y, FALL_SPEED, GRAVITY * delta)
	if is_on_floor():
		if Input.is_action_just_pressed("ui_accept"):
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

func squash_n_stretch():
	var squash = SQUISHINESS*(abs(vel.x)/MAX_SPEED - abs(vel.y)/MAX_SPEED)
	var defaultScale = 0.31 #get rid of this once we actually use a sprite
	sprite.scale = defaultScale * Vector2(1 + squash, 1 - squash)
	sprite.offset.y = -2 * sprite.texture.get_size().y * (sprite.scale.y - defaultScale)

func _on_DustTimer_timeout():
	if is_on_floor():
		if(input.x > 0):
			emit_dust($BottomLeft.global_position)
		if(input.x < 0):
			emit_dust($BottomRight.global_position)
		
func emit_dust(pos):
	$DustTimer.start()
	var dust = Dust.instance()
	level.get_node("Particles").add_child(dust)
	dust.scale.x = sign(pos.x - global_position.x)
	dust.global_position = pos

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()

func update_p_values():
	p_vel = vel
	p_input = input
	p_is_on_floor = is_on_floor()
