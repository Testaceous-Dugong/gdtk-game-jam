class_name AttackAnimator
extends Node2D

@export var animation_target: NodePath
@export var attack_distance: float = 8.0

@export var target: Vector2 = Vector2.RIGHT

@export var progress = 0.0: set = set_progress

func set_progress(value: float) -> void:
		progress = clampf(value, 0.0, 1.0)
		var node = get_node_or_null(animation_target)
		if not node:
			return
		node.position = Vector2.ZERO.lerp(target * attack_distance, progress)