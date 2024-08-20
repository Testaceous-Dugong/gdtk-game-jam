class_name MoveAnimator
extends Node2D

@export var animation_target: NodePath

@export var start_position: Vector2 = Vector2.ZERO
@export var target_position: Vector2 = Vector2.RIGHT

@export var progress = 0.0: set = set_progress

func set_progress(value: float) -> void:
		progress = clampf(value, 0.0, 1.0)
		var node = get_node_or_null(animation_target)
		if not node:
			return
		node.position = start_position.lerp(target_position, progress)