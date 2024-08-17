extends PowerUp


func apply_powerup(entity_stats: EntityStats) -> EntityStats:
	var result = super.apply_powerup(entity_stats)
	result.power_level += 1
	return result
