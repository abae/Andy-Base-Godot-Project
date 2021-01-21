extends KinematicBody2D

export var MAX_SPEED = 80
export var ACCEL = 500
export var FRICT = 500

enum{
	MOVE,
}

var state = MOVE
var vel = Vector2.ZERO
var p_vel = vel
var input = Vector2.ZERO
var p_input = input

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

func _process(delta):
	match state:
		MOVE:
			move_state(delta)
	
	#update to previous values
	update_p_values()

func move_state(delta):
	#get user input
	input.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input = input.normalized()
	
	#movement
	if input != Vector2.ZERO:
		vel = vel.move_toward(input * MAX_SPEED, ACCEL * delta)
	else:
		vel = vel.move_toward(Vector2.ZERO, FRICT * delta)
	
	#sprite manipulation
	squash_n_stretch()
	if(input.x > 0 && p_input.x <= 0):
		emit_dust($BottomLeft.global_position)
	if(input.x < 0 && p_input.x >= 0):
		emit_dust($BottomRight.global_position)
	
	#calculate collisions
	move()

func move():
	vel = move_and_slide(vel)

func squash_n_stretch():
	var squash = 0.15*(abs(vel.x)/MAX_SPEED - abs(vel.y)/MAX_SPEED)
	var defaultScale = 0.31 #get rid of this once we actually use a sprite
	sprite.scale = defaultScale * Vector2(1 + squash, 1 - squash)

func _on_DustTimer_timeout():
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
