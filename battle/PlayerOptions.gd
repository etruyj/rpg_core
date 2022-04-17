extends Node

enum state {ALIVE, DEAD}

signal return_to_menu
signal target_selected

# Target selection
# Added a more complex recursive code to prevent the selection of dead characters. If 
# the next target in the list is dead, skip the target. 
# Direction is used to determine if the player was scrolling up or down through the list.
# Up is assumed in the case of switch over from the left.
func select_Target(target, target_list, direction):
	if(target_list[target[0]][target[1]].status == state.DEAD):
		# Character is dead. Choose a new one based on the direction
		# pressed by the player.
		# Then call this function to see if that character is state.ALIVE
		if(direction == "up"):
			if(target[1] == target_list[target[0]].size()-1):
				target[1] = 0
			else:
				target[1] += 1
		else:
			if(target[1] == 0):
				target[1] = target_list.size()-1
			else:
				target[1] -= 1
		select_Target(target, target_list, direction)
	else:
		target_list[target[0]][target[1]].is_targeted()
		return target

# Called when the node enters the scene tree for the first time.
func find_target(last_target, target_list):
	var target = last_target
	
	if(Input.is_action_just_pressed("move_right") || Input.is_action_just_released("move_left")):
		target_list[last_target[0]][last_target[1]].is_not_targeted()
		if(target[0] == 0):
			target[0] = 1
		else:
			target[0] = 0
		select_Target(target, target_list, "up")
	
	if(Input.is_action_just_pressed("move_up")):
		target_list[last_target[0]][last_target[1]].is_not_targeted()
		
		if(target[1] == 0):
			target[1] = target_list[target[0]].size()-1
		else:
			target[1] -= 1
		
		select_Target(target, target_list, "up")
	
	if(Input.is_action_just_pressed("move_down")):
		target_list[last_target[0]][last_target[1]].is_not_targeted()
		
		if(target[1] == target_list[target[0]].size() - 1):
			target[1] = 0
		else:
			target[1] += 1
		
		select_Target(target, target_list, "down")
	
	if(Input.is_action_just_pressed("make_selection")):
		emit_signal("target_selected")
	
	if(Input.is_action_just_pressed("cancel_selection")):
		target_list[last_target[0]][last_target[1]].is_not_targeted()
		emit_signal("return_to_menu")
	return target
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
