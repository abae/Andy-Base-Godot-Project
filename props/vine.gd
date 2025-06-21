@tool
extends Line2D

var curve
@export var vinecolor = Color( 0, 0, 0, 1 ) # ( Color, RGBA )
@export var alpha := 0.2 # ( float, 0, 1.0 )
var start_points : PackedVector2Array
var cur_points : PackedVector2Array
var vel = Vector2.ZERO
var _is_oscillating = true

func _ready():
	curve = Curve2D.new()
	curve.add_point( Vector2.ZERO )
	curve.add_point( Vector2.ZERO )
	vel.x = 100
	if Engine.is_editor_hint():
		cur_points = points
		_update_curve( points )
	else:
		start_points = points
		cur_points = points
		_update_curve( cur_points )
		default_color.a = 0
		#cur_points[1] += Vector2( -18, 0 )
	$Area3D/Poly.polygon[0] = cur_points[0]
	$Area3D/Poly.polygon[1] = cur_points[2]
	$Area3D/Poly.polygon[2] = cur_points[1]
		
func _on_Timer_timeout():
	_is_oscillating = true
#
#	pass # Replace with function body.


func _physics_process(delta):
	if Engine.is_editor_hint():
		_update_curve( points )
		$Area3D/Poly.polygon[0] = points[0]
		$Area3D/Poly.polygon[1] = points[2]
		$Area3D/Poly.polygon[2] = points[1]
		return
	vel -= 4 * ( cur_points[1] - start_points[1] ) * delta
	vel *= .99
	cur_points[1] += vel * delta
	_update_curve( cur_points )


func _update_curve( polypoints ):
	if polypoints.size() < 3:
		return
	if curve == null:
		curve = Curve2D.new()
		curve.add_point( Vector2.ZERO )
		curve.add_point( Vector2.ZERO )
	curve.set_point_position( 0, polypoints[0] )
	curve.set_point_position( 1, polypoints[2] )
	curve.set_point_out( 0, ( polypoints[1] - polypoints[0] ) * alpha )
	curve.set_point_in( 1, ( polypoints[1] - polypoints[2] ) * alpha )
	queue_redraw()

func _draw():
	if curve == null: return
	draw_polyline( curve.get_baked_points(), vinecolor )

func _on_Area_body_entered(body):
	vel += 0.2 * body.vel
