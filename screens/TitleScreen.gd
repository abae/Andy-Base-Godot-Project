extends Control

@onready var buttons = $Menu/CenterRow/Buttons
@onready var start_button = $Menu/CenterRow/Buttons/NewGame

var clicked = false

func _ready():
	#button.grab_focus()
# warning-ignore:shadowed_variable
	for button in buttons.get_children():
		button.connect("pressed", Callable(self, "_on_Button_pressed").bind(button.scene_to_load))
	MusicController.play_menu_music()
		
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("pause"):
		if $HowToPlay.visible:
			$HowToPlay.visible = false
			$Menu.show()
			clicked = false
		elif $Credits.visible:
			$Credits.visible = false
			$Sprite2D.visible = true
			$Menu.show()
			clicked = false

func _on_Button_pressed(scene_to_load):
	if !clicked:
		clicked = true
		if scene_to_load == "quit":
			get_tree().quit()
		elif scene_to_load == "res://levels/Template.tscn":
			# $StartSFX.play()
			var tween = create_tween()
			tween.tween_method(func(t):
				$Menu.modulate = Color(1, 1, 1, lerp(1.0, 0.0, t))
				$Sprite2D.self_modulate = Color(1, 1, 1, lerp(1.0, 0.0, t))
			, 0.0, 1.0, 2.0)

			tween.finished.connect(func():
				$Menu.modulate = Color(1, 1, 1, 0.0)
				$LevelTemplate.create_player(GameState.transportPosition)
				var tween2 = create_tween()
				tween2.tween_method(func(t):
					God.cameraSpeed = lerp(0.0, 0.05, t)
				, 0.0, 1.0, 10.0)
				MusicController.fade_out_menu_music(2)
			)
			
			#MusicController.play_game_music()
		elif scene_to_load == "howToPlay":
# warning-ignore:return_value_discarded
			$Menu.hide()
			$HowToPlay.visible = true
		elif scene_to_load == "credits":
			$Menu.hide()
			$Sprite2D.visible = false
			$Credits.visible = true
