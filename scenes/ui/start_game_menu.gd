extends Control


const GAME_SCENE = preload("res://scenes/game.tscn")
var game

func _ready() -> void:
	game = GAME_SCENE.instantiate()
	##Why are any of the following lines necessary?
	##11 adds a STATIC scene's unchanged node's data to a node's variables here?
	%StartGameSettings.attach_settings(game.get_node("%LocalSettings"))
	##13 does the same to a different UI node?
	%SettingsUI.attach_settings(game.get_node("%LocalSettings"), false)
	BackgroundMusic.volume_db = -10


func _input(event):
	if event.is_action_pressed("misc|fullscreen"):
		VideoSettings.set_fullscreen_enabled(!VideoSettings.fullscreen_enabled)


func _on_ZombieSpawnChance_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_CultistSpawnChance_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_GhostDetectionRange_value_changed(value: float) -> void:
	pass # Replace with function body.


func _on_StartGame_pressed() -> void:
	$MarginContainer/HBoxContainer.visible = false
	$TextureRect.visible = false
	BackgroundMusic.stop()
	$AudioStreamPlayer.play()
	$Timer.start(3)
	#It was NOT one shot, so it would attempt to show intro multiple times


func _on_Timer_timeout():
	$GameIntro.show_intro()


func _on_GameIntro_intro_done():
	GameManager.is_player_dead = false
	GameManager.act = 1
	##ISSUE: if changing to a file, don't change to an instantiated scene. It expects a PATH
	LoadScene.change_scene_to_file("res://scenes/game.tscn")
	#LoadScene.change_scene_to_file("res://scenes/game.tscn")


func _on_ReturnButton_pressed() -> void:
	var _error = get_tree().change_scene_to_file("res://scenes/ui/title_menu.tscn")
