extends Node

# Holds the actions capably of being made during a battle.

var actor = [] # array coordinates for the character performing the action
var target = [] # array coordinates for the character targeted by the action
var action

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(actor_side, actor_pos, target_side, target_pos, what):
	actor.append(actor_side)
	actor.append(actor_pos)
	target.append(target_side)
	target.append(target_pos)
	action = what

