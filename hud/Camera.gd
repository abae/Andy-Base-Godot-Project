extends Camera2D

onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

var freeCam = false
var zoomTarget = 1.0
var zoomSpeed = .1
var shakeMagnitude = 0.0
var shakeLength = 1.0
var shakeRemain = 0.0
	
signal cam2player()
	
func _ready():
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_right = bottomRight.position.x
	
func _process(delta):
	recover()
	if !freeCam:
		emit_signal("cam2player")

func recover():
	offset = Vector2(rand_range(-shakeRemain,shakeRemain), rand_range(-shakeRemain,shakeRemain)) 
	shakeRemain = max(0, shakeRemain - ((1.0/shakeLength)*shakeMagnitude))
	zoom += (Vector2(zoomTarget,zoomTarget) - zoom)*zoomSpeed

func screen_shake(_shakeMagnitude, _shakeLength):
	if _shakeMagnitude > shakeRemain:
		shakeMagnitude = _shakeMagnitude
		shakeRemain = _shakeMagnitude
		shakeLength = _shakeLength

func cam_free(state):
	freeCam = state

func cam_move(x,y):
	freeCam = true
	position.x = x
	position.y = y
	
func cam_zoom(value):
	zoomTarget = value
