extends CanvasLayer


var random_num_gen = RandomNumberGenerator.new()
var random_num

var is_loading = true
var clicked = false   # User clicked after Click to Continue shown, but loadscreen still present until timeout
const DEFAULT_PATH_TO_STARTUP = "res://scenes/ui/opening_screens.tscn"
@onready var color_rect = get_node("ColorRect")
@onready var label = get_node("Label")
@onready var quote = get_node("Holder/Quote")
var next_scene_path: String = ""
var next_scene: PackedScene
var error

func _input(event: InputEvent):
	if !clicked:   # Without this, clicking many times will cause crash in load_scene
		if (
				(
					(event is InputEventMouseButton and event.is_pressed())
					or event.is_action_released("ui_accept") or event.is_action_released("ui_cancel")
				)
				and not is_loading
		):
			clicked = true


func _ready():
	next_scene_path = LoadScene.next_scene
	LoadScene.next_scene = ""
#	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	if(next_scene_path.is_empty()):
		get_tree().change_scene_to_file(DEFAULT_PATH_TO_STARTUP)
		return
	else:
		error = ResourceLoader.load_threaded_request(next_scene_path)

	random_num_gen.randomize()
	if GameManager.act > 4:
		# late game
		random_num = random_num_gen.randi_range(0, LoadQuotes.list3.size()-1)
		quote.text = LoadQuotes.list3[random_num]
	if GameManager.act > 2:
		# mid game
		random_num = random_num_gen.randi_range(0, LoadQuotes.list2.size()-1)
		quote.text = LoadQuotes.list2[random_num]
	else:
		# early game
		random_num = random_num_gen.randi_range(0, LoadQuotes.list1.size()-1)
		##TODO: LoadQuotes.list1 is empty
		print("List 1 size: "+ str(LoadQuotes.list1.size()))

		quote.text = LoadQuotes.list1[random_num]
	$LoadTimer.start()
	# Is here to hopefully ensure the quotes showup before the freeze on loading
	await get_tree().create_timer(0.1).timeout   # To attempt to ensure lowend computers get something showing before it freezes


func on_scene_loaded():
	is_loading = false
	$Label.text = "Click to Continue"

func set_next_scene(path: String) -> void:
	next_scene_path = path


func _on_load_timer_timeout():
	#Every 0.5s, check if the next scene has loaded yet
	var progress = []
	match ResourceLoader.load_threaded_get_status(next_scene_path, progress):
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_IN_PROGRESS: 
			print("Still loading, " + str(progress[0]) + "% done")
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_FAILED:
			printerr("PANIC, can't load " + next_scene_path)
			get_tree().change_scene_to_file(DEFAULT_PATH_TO_STARTUP)
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_INVALID_RESOURCE:
			printerr("PANIC, BAD or NO Resource " + next_scene_path)
			get_tree().change_scene_to_file(DEFAULT_PATH_TO_STARTUP)
		ResourceLoader.ThreadLoadStatus.THREAD_LOAD_LOADED:
			print("Good, loaded next scene! ")
			get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(next_scene_path))
