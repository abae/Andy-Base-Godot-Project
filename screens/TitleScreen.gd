extends Control

@onready var buttons = $Menu/CenterRow/Buttons
@onready var button = $Menu/CenterRow/Buttons/NewGame
var clicked = false

func _ready():
	#button.grab_focus()
# warning-ignore:shadowed_variable
	for button in buttons.get_children():
		button.connect("pressed", Callable(self, "_on_Button_pressed").bind(button.scene_to_load))
		button.connect("mouse_entered", Callable(self, "_on_Button_hovered").bind(self))
	MusicController.play_menu_music()
		
func _on_Button_pressed(scene_to_load):
	if !clicked:
		clicked = true
		if scene_to_load == "quit":
			get_tree().quit()
		elif scene_to_load == "res://levels/Template.tscn":
			$StartSFX.play()
			Transition.change_scene_to_file(scene_to_load)
		else:
# warning-ignore:return_value_discarded
			get_tree().change_scene_to_file(scene_to_load)
