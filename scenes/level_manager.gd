extends Node2D

@export var levels: Array[PackedScene]
@export var current_level: int = 0:
	set(value):
		assert(value >= 0)
		assert(value < levels.size())
		current_level = value
		for child in get_children():
			remove_child(child)

		add_child(levels[current_level].instantiate())

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_level = current_level

	GlobalMessageBus.advance_level.connect(advance_level)

func advance_level() -> void:
	current_level = (current_level + 1) % levels.size()