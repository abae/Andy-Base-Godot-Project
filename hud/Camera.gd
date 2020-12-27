extends Camera2D


var shakeMagnitude = 0.0
var shakeLength = 1.0
var shakeRemain = 0.0
	
func _process(delta):
	shake_recover()
	
func camera_shake(_shakeMagnitude, _shakeLength):
	if _shakeMagnitude > shakeRemain:
		shakeMagnitude = _shakeMagnitude
		shakeRemain = _shakeMagnitude
		shakeLength = _shakeLength

func shake_recover():
	offset = Vector2(rand_range(-shakeRemain,shakeRemain), rand_range(-shakeRemain,shakeRemain)) 
	shakeRemain = max(0, shakeRemain - ((1.0/shakeLength)*shakeMagnitude))
