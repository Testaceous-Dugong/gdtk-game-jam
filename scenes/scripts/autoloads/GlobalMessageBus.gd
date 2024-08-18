extends Node

signal register_player(player: Player)
signal unregister_player(player: Player)

signal pause_input()
signal unpause_input()

signal advance_turn()
signal advance_level()

signal restart_level()

signal set_level(index: int)