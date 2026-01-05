@tool
extends Node2D
class_name Waypoint

@export var connections: Array[Waypoint] = []
@export var wait_time := 0.0 
@export var facing_dir := 1.0 # 1.0 = right, -1.0 = left

@export var debug_color := Color(0, 1, 0)
@export var debug_width := 2.0
@export var debug_radius := 4.0

var home = false
var open = false
var occupied = false

func _ready():
	queue_redraw()

func _process(_delta):
	queue_redraw()


func _draw():
	if not Engine.is_editor_hint() or GameState.debug == false:
		draw_circle(Vector2.ZERO, 30, Color8(253,203,176))
		for wp in connections:
			if wp:
				draw_line(
					Vector2.ZERO,
					to_local(wp.global_position),
					Color8(253,203,176),
					60
				)
		return

	if home:
		draw_circle(Vector2.ZERO, debug_radius, Color(1, 0, 0))
	else:
		draw_circle(Vector2.ZERO, debug_radius, debug_color)

	for wp in connections:
		if wp:
			draw_line(
				Vector2.ZERO,
				to_local(wp.global_position),
				debug_color,
				debug_width
			)
			_draw_arrow(Vector2.ZERO, to_local(wp.global_position), debug_color, debug_radius * 5)
			
func _draw_arrow(start: Vector2, end: Vector2, color: Color, arrow_size: float = 8.0):
	var dir = (end - start).normalized()
	var perp = Vector2(-dir.y, dir.x)

	var tip = end
	var left = end - dir * arrow_size + perp * (arrow_size * 0.5)
	var right = end - dir * arrow_size - perp * (arrow_size * 0.5)

	draw_polygon([tip, left, right], [color])
