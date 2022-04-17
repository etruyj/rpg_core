extends Node

# Logic for how targets are chosen
enum state {ALIVE, DEAD}
enum team {PLAYER, NPC}

var actor
var target_list


# Called when the node enters the scene tree for the first time.
#func _ready():
#	pass # Replace with function body.

static func auto_find_target(actor, target_list):
	if(actor.side == team.PLAYER):
		for x in target_list[team.NPC].size():
			if (target_list[team.NPC][x].status == state.ALIVE):
				return [team.NPC, x]
	
	if(actor.side == team.NPC):
		for x in target_list[team.PLAYER].size():
			if (target_list[team.PLAYER][x].status == state.ALIVE):
				return [team.PLAYER, x]



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
