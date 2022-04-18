extends MarginContainer

var highlighted_button := 0
var accepting_inputs := false

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	hide_menu()

func show_menu():
	$MenuList.get_child(highlighted_button).grab_focus()
	accepting_inputs = true
	show()

func hide_menu():
	$MenuList.get_child(highlighted_button).release_focus()
	accepting_inputs = false
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(accepting_inputs):
		if(Input.is_action_just_pressed("move_up")):
			$MenuList.get_child(highlighted_button).emit_signal("focus_exited")
			if(highlighted_button == 0):
				highlighted_button = $MenuList.get_child_count() -1
			else:
				highlighted_button -= 1
			$MenuList.get_child(highlighted_button).emit_signal("focus_entered")
		if(Input.is_action_just_pressed("move_down")):
			$MenuList.get_child(highlighted_button).emit_signal("focus_exited")
			if(highlighted_button == $MenuList.get_child_count() - 1):
				highlighted_button = 0
			else:
				highlighted_button += 1
			$MenuList.get_child(highlighted_button).emit_signal("focus_entered")
		if(Input.is_action_just_pressed("make_selection")):
			$MenuList.get_child(highlighted_button).emit_signal("pressed", $MenuList.get_child(highlighted_button).name)
			hide_menu()
