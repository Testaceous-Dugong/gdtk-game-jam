extends Node

signal register_player(player: Player)
signal unregister_player(player: Player)

signal pause_input()
signal unpause_input()

signal advance_turn()
signal advance_level()

signal restart_level()

signal set_level(index: int)

func _ready() -> void:
	assert(register_player)
	assert(unregister_player)

	assert(pause_input)
	assert(unpause_input)

	assert(advance_turn)
	assert(advance_level)

	assert(restart_level)

	assert(set_level)