extends Container

const PlayerDisplay = preload("res://scenes/ui/player.gd")
const PlayerDisplayScene = preload("res://scenes/ui/player.tscn")

var players: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalMessageBus.register_player.connect(on_player_added.call_deferred)
	GlobalMessageBus.unregister_player.connect(on_player_removed.call_deferred)

func on_player_added(player: Player) -> void:
	var player_display: PlayerDisplay = PlayerDisplayScene.instantiate()
	add_child(player_display)

	players[player] = player_display

	player_display.set_health(player.health)
	player_display.set_power_level(player.get_power_level())

	player.health_changed.connect(player_display.set_health)
	player.power_level_changed.connect(player_display.set_power_level)

func on_player_removed(player: Player) -> void:
	print("hello")
	var player_display = players[player]
	remove_child(player_display)
	players[player].queue_free()
	players.erase(player)