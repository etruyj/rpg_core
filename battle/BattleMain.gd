extends Node2D

const BattleAction = preload("res://battle/BattleAction.gd")
const BattleCharacter = preload("res://battle/characters/BattleCharacter.tscn")
const BattleLogic = preload("res://battle/BattleLogic.gd")
const PlayerInfo = preload("res://battle/HUD/status_bar/CharacterStats.tscn")
const StartingPosition = preload("res://battle/StartingPosition.gd")
# non-constants/non-static methods.
var PlayerOptions = preload("res://battle/PlayerOptions.gd").new()

enum action {ATTACK, MOVE, ITEM}
enum team {PLAYER, NPC}

var screen_size
var fighting: bool #whether the battle is active or over.
var selecting_target := false
var action_ready := false

var combatants_list = []# two dimensional array of both teams of combatants.
var combatant # memory space for dynamic declaration of combatants.
var living_characters = [] # how many characters are alive or dead.
var timers # timers for each of the arrays.
var player_target = []
var player_choice

# Queues for processing execution order.
# Action queues are the queues for action decisions to be
# made. Having separate player and npc queues, allows the
# NPCs process actions if the player doesn't respond.
# The execution queue hold the moves to be executed serially
# after they are chosen.
var player_action_queue = []
var npc_action_queue = []
var execution_queue = []


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_viewport_rect().size
	
	# Make a two dimensional array for easy scrolling.
	# and target selection.
	combatants_list.append([])
	combatants_list.append([])
	
	living_characters.append(3) # team.PLAYER
	living_characters.append(3) # team.NPC
	
	fighting = true # battle is active
	player_target.append(team.NPC)
	player_target.append(0)
	$HUD/ActionMenu/MenuList/Attack.connect("pressed", self, "_action_selected")
	$HUD/ActionMenu/MenuList/Item.connect("pressed", self, "_action_selected")
	PlayerOptions.connect("return_to_menu", self, "_escape_target_selection")
	
	#============================================
	# Generation of blank characters for testing.
	var name
	var start
	var stats_bar
	var itr = 0
	for x in 2:
		for y in 3:
			start = StartingPosition.get_start_position(x, y, screen_size)
			name = "Fighter " + str(itr)
			combatant = BattleCharacter.instance()
			if(x==0):
				combatant.initialize_character(name, 5, 10, 2 * (x+y), y, team.PLAYER, start.position)
			else:
				combatant.initialize_character(name, 5, 10, 2 * (x+y), y, team.NPC, start.position)
			combatants_list[x].append(combatant)
			add_child(combatant)
			combatant.connect("is_dead", self, "_someone_dies")
			
			if(x==team.PLAYER):
				stats_bar = PlayerInfo.instance()
				stats_bar.load_values(combatant.char_name, combatant.hp, combatant.max_hp, combatant.action_time_left(), combatant.action_time_wait())
				combatant.connect("is_hit", stats_bar, "_update_hp")
				combatant.connect("timer_value", stats_bar, "_update_action_bar")
				$HUD/StatsBar/HBoxContainer/VBoxContainer.add_child(stats_bar)
				#if(y==0):
				#	$StatsBar/HBoxContainer/VBoxContainer/Party_0.load_values(combatant.char_name, combatant.hp, combatant.max_hp, combatant.action_time_left(), combatant.action_time_wait())
				#	combatant.connect("is_hit", $StatsBar/HBoxContainer/VBoxContainer/Party_0, "_update_hp")
				#	combatant.connect("timer_value", $StatsBar/HBoxContainer/VBoxContainer/Party_0, "_update_action_bar")
				#if(y==1):
				#	$StatsBar/HBoxContainer/VBoxContainer/Party_1.load_values(combatant.char_name, combatant.hp, combatant.max_hp, combatant.action_time_left(), combatant.action_time_wait())
				#	combatant.connect("is_hit", $StatsBar/HBoxContainer/VBoxContainer/Party_1, "_update_hp")
				#	combatant.connect("timer_value", $StatsBar/HBoxContainer/VBoxContainer/Party_1, "_update_action_bar")
				#if(y==2):
				#	$StatsBar/HBoxContainer/VBoxContainer/Party_2.load_values(combatant.char_name, combatant.hp, combatant.max_hp, combatant.action_time_left(), combatant.action_time_wait())
				#	combatant.connect("is_hit", $StatsBar/HBoxContainer/VBoxContainer/Party_2, "_update_hp")
				#	combatant.connect("timer_value", $StatsBar/HBoxContainer/VBoxContainer/Party_2, "_update_action_bar")
			print("Added " + name + " to roster")
			itr+= 1
	#============================================


func _battle_over():
	fighting = false
	for x in combatants_list.size():
		for y in combatants_list[x].size():
			combatants_list[x][y].stop_action_timer()

func _on_action_timer_timeout(character, action_queue, index):
	if action_queue == team.PLAYER:
		player_action_queue.append(index)
		print("added " + character + " to the player action queue")
	else:
		npc_action_queue.append(index)
		print("added " + character + " to the NPC action queue")

func _action_selected(choice):
	print("Action [" + choice + "] selected")
	player_choice = choice
	selecting_target = true

func _escape_target_selection():
	selecting_target = false
	$HUD/ActionMenu.show_menu()

func _someone_dies(side):
	if(side == team.PLAYER):
		living_characters[team.PLAYER] -= 1
	else:
		living_characters[team.NPC] -= 1
		
	if(living_characters[team.PLAYER] == 0 || living_characters[team.NPC] == 0):
		if(living_characters[team.PLAYER] == 0):
			print("Player defeated")
		else:
			print("NPCs defeated")
		_battle_over()

func _target_selected():
	selecting_target = false
	action_ready = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# Process the player and npc action queues as
	# well as the execution queue.
	
	var npc_choice
	var npc_target

	if(fighting):
		if(player_action_queue.size() > 0):
			combatants_list[team.PLAYER][player_action_queue[0]].pause_action_timer()
			
			if(!selecting_target && !action_ready):
				$HUD/ActionMenu.show_menu()
			elif(!action_ready):
				combatants_list[player_target[0]][player_target[1]].is_targeted()
				player_target = PlayerOptions.find_target(player_target, combatants_list)
			else:
				print("Queuing action for " + combatants_list[team.PLAYER][player_action_queue[0]].char_name)
				player_choice = BattleAction.new(team.PLAYER, player_action_queue[0], player_target[0], player_target[1], player_choice)
				execution_queue.append(player_choice)
				player_action_queue.remove(0)
			#$ActionMenu.selection_made()
		
		if(npc_action_queue.size() > 0):
			combatants_list[team.NPC][npc_action_queue[0]].pause_action_timer()
			print("Queuing action for " + combatants_list[team.NPC][npc_action_queue[0]].char_name)
			npc_target = BattleLogic.auto_find_target(combatants_list[team.NPC][npc_action_queue[0]], combatants_list)
			npc_choice = BattleAction.new(team.NPC, npc_action_queue[0], npc_target[0], npc_target[1], action.ATTACK)
			execution_queue.append(npc_choice)
			npc_action_queue.remove(0)
		
		if(execution_queue.size() > 0):
			if(combatants_list[execution_queue[0].target[0]][execution_queue[0].target[1]].is_attacked(
				combatants_list[execution_queue[0].actor[0]][execution_queue[0].actor[1]].attack, 50, "nil")):
				print("Action: " + combatants_list[execution_queue[0].actor[0]][execution_queue[0].actor[1]].char_name 
					+ " attacks " + combatants_list[execution_queue[0].target[0]][execution_queue[0].target[1]].char_name)
			else:
				print("Action: " + combatants_list[execution_queue[0].actor[0]][execution_queue[0].actor[1]].char_name 
					+ " misses " + combatants_list[execution_queue[0].target[0]][execution_queue[0].target[1]].char_name)
			combatants_list[execution_queue[0].actor[0]][execution_queue[0].actor[1]].start_action_timer()
			execution_queue.remove(0)
