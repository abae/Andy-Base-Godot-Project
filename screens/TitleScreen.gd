extends Control

onready var buttons = $Menu/CenterRow/Buttons
onready var button = $Menu/CenterRow/Buttons/NewGame
var clicked = false

func _ready():
	#button.grab_focus()
# warning-ignore:shadowed_variable
	for button in buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])
		button.connect("mouse_entered", self, "_on_Button_hovered", [self])
	MusicController.play_menu_music()
		
func _on_Button_pressed(scene_to_load):
	if !clicked:
		clicked = true
		if scene_to_load == "quit":
			get_tree().quit()
		elif scene_to_load == "res://Pregame.tscn":
			$StartSFX.play()
			Transition.change_scene(scene_to_load)
			PlayerStats.reset_values()
		else:
			get_tree().change_scene(scene_to_load)
	
func _on_Button_hovered(hovered_button):
	pass
	#hovered_button.grab_focus()
