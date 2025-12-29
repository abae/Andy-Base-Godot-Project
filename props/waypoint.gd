@tool
extends Node2D
class_name Waypoint

@export var connections: Array[Waypoint] = []
@export var wait_time := 0.0 
@export var facing_dir := 1.0 # 1.0 = right, -1.0 = left

@export var debug_color := Color(0, 1, 0)
@export var debug_width := 2.0
@export var debug_radius := 4.0

func _ready():
	queue_redraw()

func _process(_delta):
	queue_redraw()


func _draw():
	if not Engine.is_editor_hint():
		return

	draw_circle(Vector2.ZERO, debug_radius, debug_color)

	for wp in connections:
		if wp:
			draw_line(
				Vector2.ZERO,
				to_local(wp.global_position),
				debug_color,
				debug_width
			)