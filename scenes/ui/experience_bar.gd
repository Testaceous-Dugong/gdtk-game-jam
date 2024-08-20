extends Control

@export var bar_height: int = 16
@export var bar_spacing: int = 4

@export var progress = 0.0:
	set(value):
		progress = clampf(value, 0.0, 1.0)
		queue_redraw()

var players = {}

var current_level = 1
var current_experience = 0

var target_level = 1
var target_experience = 0


@onready var animation_player = $AnimationPlayer as AnimationPlayer
@onready var label = $Label as Label

func _ready() -> void:
	GlobalMessageBus.register_player.connect(on_player_added.call_deferred)
	GlobalMessageBus.unregister_player.connect(on_player_removed.call_deferred)
	GlobalMessageBus.level_changed.connect(reset)
	GlobalMessageBus.restart_level.connect(reset)

func _draw() -> void:
	var level = current_level
	var experience = current_experience + progress * get_experience_difference()
	while experience > level + 1:
		experience %= level + 1
	
	label.text = "lvl%s" % level

	var y_offset = size.y as int - bar_height
	var bar_size = Vector2i(
		(((size.x as int) - (bar_spacing * level)) as float / (level + 1)) as int,
		bar_height
	)

	for x in range(experience):
		draw_rect(
			Rect2i(
				Vector2i(x * (bar_size.x + bar_spacing), y_offset),
				bar_size
			),
			Color.BLUE
		)

	var remainder = experience - floorf(experience)
	if remainder > 0:
		experience = ceilf(experience)
		var filled_length = ceili(remainder * bar_size.x)
		draw_rect(
			Rect2i(
				Vector2i((experience - 1) * (bar_size.x + bar_spacing), y_offset),
				Vector2i(filled_length, bar_height)
			),
			Color.BLUE
		)
		draw_rect(
			Rect2i(
				Vector2i((experience - 1) * (bar_size.x + bar_spacing) + filled_length, y_offset),
				Vector2i(bar_size.x - filled_length, bar_height)
			),
			Color.LIGHT_GRAY
		)
	
	for x in range(experience, level + 1):
		draw_rect(
			Rect2i(
				Vector2i(x * (bar_size.x + bar_spacing), y_offset),
				bar_size
			),
			Color.LIGHT_GRAY
		)

func on_player_added(player: Player) -> void:
	players[player] = true
	player.experience_changed.connect(on_experience_changed)

func on_player_removed(player: Player) -> void:
	players.erase(player)

func on_experience_changed(level: int, experience: int) -> void:
	if level == current_level and experience == current_experience:
		return
	current_experience += ceili(progress * get_experience_difference())
	while current_experience > current_level + 1:
		current_experience %= current_level + 1

	progress = 0.0
	target_level = level
	target_experience = experience
	animation_player.play(&"gain_experience")

func reset(_index: int = 0) -> void:

	current_level = 1
	current_experience = 0
	target_level = 1
	target_experience = 0

	queue_redraw()

func get_experience_difference() -> int:
	match target_level - current_level:
		0:
			return target_experience - current_experience
		1:
			return target_experience + (current_level + 1) - current_experience
		var level_diff:
			var level_count = level_diff - 1
			var first_level = current_level + 1
			var last_level = current_level + level_count
			return level_count * (first_level + last_level + 2) / 2 + target_experience + (current_level + 1) - current_experience

func set_to_target() -> void:
	current_level = target_level
	current_experience = target_experience
	progress = 0.0
	queue_redraw()
