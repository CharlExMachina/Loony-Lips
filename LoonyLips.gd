extends Control

#export variables
export(String, MULTILINE) var intro_text

#nodes
onready var display = get_node("UIContainer/Story")
onready var input = get_node("UIContainer/HBoxContainer/PlayerInput")
onready var player_input_container = get_node("UIContainer/HBoxContainer")
onready var story_book = get_node("StoryBook")

#inner variables
var player_words = []
var shown_intro = false;
var game_has_ended = false;
var current_story

func _ready():
	pick_story()
	player_input_container.hide()
	set_intro_text()
	pass

# Keyboard events
func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.scancode == KEY_ENTER and event.pressed and !shown_intro:
		show_player_input()
		check_player_words()
		shown_intro = true;
	if event.is_action_pressed("ui_accept") and game_has_ended:
		get_tree().reload_current_scene()
	pass

#signals
func _on_TextureButton_pressed() -> void:
	add_to_player_words()
	check_player_words()
	pass

func _on_PlayerInput_text_entered(new_text: String) -> void:
	add_to_player_words()
	check_player_words()
	pass

#class functions
func add_to_player_words():
	if input.text != "":
		player_words.append(input.text)
	input.clear()
	pass

func is_story_done() -> bool:
	return player_words.size() == current_story.prompts.size()
	pass

func check_player_words():
	if is_story_done():
		tell_story()
		pass
	else:
		prompt_player()
		pass
	pass

func tell_story():
	display.text = current_story.story % player_words
	display.text += "\nThis is the end for this story. Press enter to play again!"
	end_game()
	pass

func prompt_player():
	display.text = "May I have " + current_story.prompts[player_words.size()] + "?"
	input.grab_focus()
	pass

func set_intro_text():
	display.text = intro_text
	pass

func show_player_input():
	player_input_container.show()
	pass

func end_game():
	player_input_container.queue_free() # remove item from memory
	game_has_ended = true
	pass

func pick_story():
	randomize()
#	var stories = get_from_json("storybook.json")
#	current_story = stories[randi() % stories.size()]
	var stories = story_book.get_child_count()
	var selected_story_index = randi() % stories
	current_story = story_book.get_child(selected_story_index)
	current_story.prompts = story_book.get_child(selected_story_index).prompts
	current_story.story = story_book.get_child(selected_story_index).story
#	current_story = template[randi() % template.size()]
	pass

#func get_from_json(path):
#	var file = File.new()
#	file.open(path, File.READ)
#	var content = file.get_as_text()
#	var data = parse_json(content)
#	file.close()
#	return data

