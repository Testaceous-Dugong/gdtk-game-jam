class_name EntityStats
extends RefCounted

static func copy(prev: EntityStats) -> EntityStats:
	var stats = EntityStats.new()
	stats.max_health = prev.max_health
	stats.health = prev.health
	stats.power_level = prev.power_level
	stats.experience = prev.experience
	return stats

var max_health: int
var health: int
var power_level: int
var experience: int
