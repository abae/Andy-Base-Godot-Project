extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("splash")


func go_to_menu():
	Transition.change_scene("res://screens/TitleScreen.tscn")
