extends Node2D

@export var levels: Array[PackedScene]
@export var current_level: int = 0:
	set(value):
		assert(value >= 0)
		assert(value < levels.size())
		current_level = value
		for child in get_children():
			remove_child(child)
			child.queue_free()

		add_child(levels[current_level].instantiate())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level = current_level

	GlobalMessageBus.advance_level.connect(advance_level)
	GlobalMessageBus.restart_level.connect(restart_level)
	GlobalMessageBus.set_level.connect(set_level)

func advance_level() -> void:
	current_level = (current_level + 1) % levels.size()

func restart_level() -> void:
	current_level = current_level

func set_level(value: int) -> void:
	current_level = value
