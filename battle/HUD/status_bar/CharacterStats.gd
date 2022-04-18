extends MarginContainer

# Display health and action count stats for the characters.
var hp_max
var hp
var action_bar_max
var action_bar
var display_name


# Called when the node enters the scene tree for the first time.
func _ready():
	_remove_Highlight()
	show()

func _highlight_Bar():
	$Highlight.show()

func load_values(name, health, max_health, ap_bar, ap_bar_max):
	display_name = name
	hp = health
	hp_max = max_health
	action_bar = ap_bar
	action_bar_max = ap_bar_max
	
	$HBoxContainer/Name.text = display_name
	$HBoxContainer/ProgressBars/HPInfo/HBoxContainer/HPGauge.max_value = hp_max
	$HBoxContainer/ProgressBars/ReadyInfo/ReadyGauge.max_value = action_bar_max
	_update_hp(hp)
	_update_action_bar(action_bar)
	

func _remove_Highlight():
	$Highlight.hide()

func _update_hp(new_hp):
	$HBoxContainer/ProgressBars/HPInfo/HBoxContainer/HP.text = str(new_hp) + "/" + str(hp_max)
	$HBoxContainer/ProgressBars/HPInfo/HBoxContainer/HPGauge.value = new_hp

func _update_action_bar(new_ap):
	$HBoxContainer/ProgressBars/ReadyInfo/ReadyGauge.value = new_ap

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
