extends Node

enum team {PLAYER, NPC}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

static func get_start_position(side, spot, screen_size):
	var horizontal = screen_size.x / 4
	var vertical = screen_size.y / 3
	var start = Position2D.new()
	
	start.position.y = (2 * vertical) - 60 * spot
	
	if(side == team.PLAYER):
		if(spot % 2 == 0):
			start.position.x = (3 * horizontal) + 40
		else:
			start.position.x = (3 * horizontal) - 40
	else:
		if(spot % 2 == 0):
			start.position.x = horizontal - 40
		else:
			start.position.x = horizontal + 40
	return start
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
