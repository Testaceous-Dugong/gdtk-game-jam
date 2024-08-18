class_name BossScaler
extends Node2D

const Boss = preload("res://scenes/enemies/boss.gd")

@export var max_health: int = 4

func on_child_entered(entity: Node2D) -> void:
	var boss = entity as Boss
	if not boss:
		return

	boss.max_health = max_health
