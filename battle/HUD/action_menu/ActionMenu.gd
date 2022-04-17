extends MarginContainer

var highlighted_button := 0

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	hide_menu()

func show_menu():
	$MenuList.get_child(highlighted_button).grab_focus()
	show()

func hide_menu():
	hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if(Input.is_action_just_released("move_up")):
		$MenuList.get_child(highlighted_button).emit_signal("focus_exited")
		if(highlighted_button == 0):
			highlighted_button = $MenuList.get_child_count() -1
		else:
			highlighted_button -= 1
		$MenuList.get_child(highlighted_button).emit_signal("focus_entered")
	if(Input.is_action_just_released("move_down")):
		$MenuList.get_child(highlighted_button).emit_signal("focus_exited")
		if(highlighted_button == $MenuList.get_child_count() - 1):
			highlighted_button = 0
		else:
			highlighted_button += 1
		$MenuList.get_child(highlighted_button).emit_signal("focus_entered")
	if(Input.is_action_pressed("make_selection")):
		$MenuList.get_child(highlighted_button).emit_signal("pressed", $MenuList.get_child(highlighted_button).name)
		hide_menu()
