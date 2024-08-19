extends Control

@export var bar_height: int = 16
@export var bar_spacing: int = 4

var players = {}

var current_level = 1
var current_experience = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GlobalMessageBus.register_player.connect(on_player_added.call_deferred)
	GlobalMessageBus.unregister_player.connect(on_player_removed.call_deferred)
	GlobalMessageBus.level_changed.connect(reset)
	GlobalMessageBus.restart_level.connect(reset)

func _draw() -> void:
	var y_offset = size.y as int - bar_height * 2
	var bar_size = Vector2i(((size.x as int) - (bar_spacing * current_level)) / (current_level + 1), bar_height)
	for x in range(current_level + 1):
		var color = Color.BLUE if x < current_experience else Color.DARK_GRAY
		draw_rect(Rect2i(Vector2i(x * (bar_size.x + bar_spacing), y_offset), bar_size), color)

func on_player_added(player: Player) -> void:
	players[player] = true
	player.experience_changed.connect(on_experience_changed)

func on_player_removed(player: Player) -> void:
	players.erase(player)

func on_experience_changed(level: int, experience: int) -> void:
	current_level = level
	current_experience = experience
	queue_redraw()

func reset(_index: int = 0) -> void:
	current_level = 1
	current_experience = 0
	queue_redraw()
