class_name StatDisplay
extends HBoxContainer

@export var stat_icon: PackedScene
@export var missing_stat_icon: PackedScene

var stat_value: int:
	set(value):
		stat_value = value
		if stat_value > max_stat_value:
			max_stat_value = stat_value
		else:
			update()

var max_stat_value: int:
	set(value):
		max_stat_value = value
		update()

func update() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()

	for i in range(stat_value):
		add_child(stat_icon.instantiate())

	if not missing_stat_icon:
		return
	for i in range(max_stat_value - stat_value):
		add_child(missing_stat_icon.instantiate())
