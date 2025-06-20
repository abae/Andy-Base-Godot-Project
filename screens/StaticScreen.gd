extends Control

@onready var button = $Button

func _ready():
	#button.grab_focus()
# warning-ignore:shadowed_variable
	button.connect("pressed", Callable(self, "_on_Button_pressed").bind(button.scene_to_load))
		
func _on_Button_pressed(scene_to_load):
	get_tree().change_scene_to_file(scene_to_load)
