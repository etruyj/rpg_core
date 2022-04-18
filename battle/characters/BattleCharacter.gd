extends Node2D

signal is_dead
signal is_hit
signal is_turn
signal _revived
signal timer_value
signal turn_over

enum state {ALIVE, DEAD}
enum team {PLAYER, ENEMY}

var char_name = "Max"
var hp
var max_hp
var speed
var attack
var defend
var array_index: int
var side
var status

# Called when the node enters the scene tree for the first time.
func initialize_character(name: String, health: int, max_health: int, rate: int, queue_position: int, group: int, pos):
	hide()
	char_name = name
	hp = health
	max_hp = max_health
	array_index = queue_position
	side = group
	speed = rate
	attack = 5
	defend = 3
	status = state.ALIVE
	position = pos;
	$ActionTimer.set_wait_time(15 - (speed * .4))
	

func _ready():
	print("Starting " + char_name + "'s timer")
	$ActionTimer.connect('timeout', get_parent(), '_on_action_timer_timeout', [char_name, side, array_index])
	$ActionTimer.start()
	
	if(status == state.ALIVE):
		$AnimatedSprite.animation=="standing"
	else:
		$AnimatedSprite.animation=="dead"
	
	show()


func is_attacked(damage, accuracy, type) -> bool:
	if((randi() % 100 + 1) < accuracy):
		# Attack hits
		self._is_hit(damage)
		return true
	else:
		# Attack misses
		return false

func _is_healed(health):
	if((hp+health)>max_hp):
		hp = max_hp
	else:
		hp += health

func _is_hit(damage):
	if(damage > defend):
		hp -= damage - defend
	else:
		hp -= 1
	
	if(hp<=0):
		hp = 0
		dies()
	
	emit_signal("is_hit", hp)

func is_targeted():
	$AnimatedSprite.animation = "targeted"

func is_not_targeted():
	$AnimatedSprite.animation = "standing"

func action_time_left()->float:
	return $ActionTimer.time_left

func action_time_wait()->float:
	return $ActionTimer.wait_time

func dies():
	$AnimatedSprite.animation = "dead"
	print(char_name + " dies")
	status = state.DEAD
	stop_action_timer()
	emit_signal("is_dead", side, array_index)

func end_Turn():
	emit_signal("turn_over")

func get_status()-> int:
	return status

func pause_action_timer():
	stop_action_timer()

func start_Action_Timer():
	$ActionTimer.start()

func stop_action_timer():
	$ActionTimer.stop()

func start_Turn():
	emit_signal("is_turn")

func toggle_focus():
	print(char_name + ".toggle_focus(): $AnimatedSprint.animation==" + $AnimatedSprite.animation)
	if($AnimatedSprite.animation == "standing"):
		$AnimatedSprite.animation = "targeted"
	else:
		$AnimatedSprite.animation = "standing"

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	
	#Update the action timer
	var timer_val = action_time_wait() - action_time_left()
	
	
	emit_signal("timer_value", timer_val)	

