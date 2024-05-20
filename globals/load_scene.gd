extends Node

const Loadscreen = preload("res://scenes/ui/loadscreen/load_screen.tscn")
var next_scene:String = ""

func change_scene_to_file(path:String) -> void:
	next_scene = path
	get_tree().change_scene_to_packed(Loadscreen)
