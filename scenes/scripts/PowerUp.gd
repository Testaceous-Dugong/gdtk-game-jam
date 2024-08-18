class_name PowerUp
extends Node2D

func apply_powerup(entity_stats: EntityStats) -> EntityStats:
	return EntityStats.copy(entity_stats)