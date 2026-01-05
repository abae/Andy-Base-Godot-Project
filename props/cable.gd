extends Node2D


@export var length: float = 30
@export var constrain: float = 1
@export var gravity: Vector2 = Vector2(0,9.8)
@export var friction: float = 0.9
@export var start_pin: bool = true
@export var end_pin: bool = true
@export var offset: Vector2 = Vector2(0,0)
@export var tightness: int = 3
@export var target_distance: float = 5.0
@export var spring_k: float = 10.0 # spring stiffness (force per unit length)
@export var spring_damping: float = 0.9 # applied to the implicit velocity when using springs
@export var max_spring_force: float = 500.0

var pos: PackedVector2Array
var pos_ex: PackedVector2Array
var count: int
var time = 0.0

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
	global_position = position + get_parent().position
	for i in range(count):
		pos[i] = global_position + Vector2(0, constrain *i)
		pos_ex[i] = pos[i]

func _process(delta):
	pos[0] = global_position
	if end_pin:
		pos[count - 1] = global_position + $End.position - offset
	update_points(delta)
	for i in range(tightness):
		update_distance()
	for i in range(count):
		pos[i] -= global_position - offset
	$Line2D.points = pos
	if has_node("Line2D2"):
		$Line2D2.points = pos
	for i in range(count):
		pos[i] += global_position - offset
	time += delta
	gravity.y = (500.0 * sin(time / 2.0 + randf_range(0.0, PI))) + 1500.0 + randf_range(-200.0, 200.0)

func update_points(delta):
	for i in range (count):
		# not first and last || first if not pinned || last if not pinned
		if (i!=0 && i!=count-1) || (i==0 && !start_pin) || (i==count-1 && !end_pin):
			var vec2 = (pos[i] - pos_ex[i]) * friction	
			pos_ex[i] = pos[i]
			# Compute spring forces from neighbors (damped Hooke springs)
			var spring_force := Vector2.ZERO
			if i > 0:
				var dprev = pos[i] - pos[i-1]
				var lprev = dprev.length()
				if lprev - target_distance != 0:
					spring_force += -((lprev - target_distance) * dprev / lprev) * spring_k
			if i < count-1:
				var dnext = pos[i] - pos[i+1]
				var lnext = dnext.length()
				if lnext - target_distance != 0:
					spring_force += -((lnext - target_distance) * dnext / lnext) * spring_k

			# Apply spring damping to the implicit velocity to stabilize oscillation
			vec2 *= spring_damping

			# Integrate using Verlet-style acceleration term (use delta^2).
			# Treat spring_force as acceleration (mass = 1). Clamp the force
			# magnitude to avoid runaway accelerations.
			if spring_force.length() > max_spring_force:
				spring_force = spring_force.normalized() * max_spring_force

			var accel := gravity + spring_force
			# Verlet-style step: pos += velocity_term + accel * dt^2
			pos[i] += (vec2 * delta) + (accel * (delta * delta))

func update_distance():
	for i in range(count):
		if i == count-1:
			return
		var distance = pos[i].distance_to(pos[i+1])
		var difference = target_distance - distance
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
