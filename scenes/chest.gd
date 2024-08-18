extends PowerUp


func apply_powerup(entity_stats: EntityStats) -> EntityStats:
	var result = super.apply_powerup(entity_stats)
	result.health = result.max_health
	return result
