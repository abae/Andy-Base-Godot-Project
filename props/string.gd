extends Node2D


@export var length: float = 30
@export var constrain: float = 1
@export var gravity: Vector2 = Vector2(0,9.8)
@export var friction: float = 0.9
@export var start_pin: bool = true
@export var end_pin: bool = true
@export var offset: Vector2 = Vector2(0,0)

var pos: PackedVector2Array
var pos_ex: PackedVector2Array
var count: int

func _ready():
	count = get_count(length)
	resize_arrays()
	init_position()

func get_count(distance: float):
	var new_count = ceil(distance / constrain)
	return new_count

func resize_arrays():
	pos.resize(count)
	pos_ex.resize(count)

func init_position():
	position = get_parent().position
	for i in range(count):
		pos[i] = position + Vector2(0, constrain *i)
		pos_ex[i] = pos[i]
	position = Vector2.ZERO

func _process(delta):
	pos[0] = get_parent().position
	update_points(delta)
	update_distance()
	update_distance()	#Repeat to get tighter rope
	update_distance()
	for i in range(count):
		pos[i] -= get_parent().position - offset
	$Line2D.points = pos
	for i in range(count):
		pos[i] += get_parent().position - offset

func update_points(delta):
	for i in range (count):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=count-1) || (i==0 && !start_pin) || (i==count-1 && !end_pin):
			var vec2 = (pos[i] - pos_ex[i]) * friction
			pos_ex[i] = pos[i]
			pos[i] += vec2 + (gravity * delta)

func update_distance():
	for i in range(count):
		if i == count-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = constrain - distance
		var percent = difference / distance
		var vec2 = pos[i+1] - pos[i]
		if i == 0:
			if start_pin:
				pos[i+1] += vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
		elif i == count-1:
			pass
		else:
			if i+1 == count-1 && end_pin:
				pos[i] -= vec2 * percent
			else:
				pos[i] -= vec2 * (percent/2)
				pos[i+1] += vec2 * (percent/2)
