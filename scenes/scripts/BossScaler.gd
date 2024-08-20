class_name BossScaler
extends Node2D

const Boss = preload("res://scenes/enemies/boss.gd")

@export var max_health: int = 4
@export var power_level: int = 2

func on_child_entered(entity: Node) -> void:
	var boss = entity as Boss
	if not boss:
		return

	boss.max_health = max_health
	boss.power_level = power_level
