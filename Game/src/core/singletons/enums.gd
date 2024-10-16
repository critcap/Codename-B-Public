class_name Enums

enum StatType {
	HEALTH,
	MAX_HEALTH,
	DAMAGE,
	DEFENSE,
	DODGE,
	ACTION_SPEED,
	MOVE_SPEED,
	LEVEL,
	ENEMY_DAMAGE,
	ENEMY_DEFENSE,
	CRITICAL_CHANCE,
	AREA,
	LUCK,
	RANGE,
	THORNS,
}

enum ModType { MULITPLICATIVE, ADDITIVE }

enum Rarity {
	COMMON,
	RARE,
	EPIC,
	LEGENDARY,
}

## Standard sizes for objects and ranges
enum Size {
	POINT = 15,
	SMALL = 30,
	MEDIUM = 50,
	LARGE = 150,
	GIANT = 250,
}

enum Difficulty {
	EASY,
	MEDIUM,
	HARD,
	INSANE,
	BALLERN,
}

enum ItemType {
	CHARACTER = 0,
	WEAPON = 1,
	UPGRADE = 2,
	ITEM = 3,
}

enum PrizeType {
	NONE,
	WEAPON_BASE,
	WEAPON_UPGRADE,
	COMMON,
	RARE,  # can be item or weapon upgrade
	EPIC,  # can be item or weapon upgrade
	LEGENDARY,  # can be item or weapon upgrade
}

enum AttackType { MELEE, RANGED, CHARGE, SPECIAL }

enum MovementType { CHASE, FLEE, DRIVE_BY, ROAM, STATIONARY }


static func get_difficulty_dmg_multi(difficulty: Difficulty) -> float:
	match difficulty:
		Difficulty.HARD:
			return 1.12
		Difficulty.INSANE:
			return 1.24
		Difficulty.BALLERN:
			return 1.4
		_:
			return 1.0


static func rarity_to_prize(rarity: Rarity) -> PrizeType:
	match rarity:
		Rarity.COMMON:
			return PrizeType.COMMON
		Rarity.RARE:
			return PrizeType.RARE
		Rarity.EPIC:
			return PrizeType.EPIC
		Rarity.LEGENDARY:
			return PrizeType.LEGENDARY
		_:
			return PrizeType.COMMON

static func prize_to_rarity(prize: PrizeType) -> Rarity:
	match prize:
		PrizeType.COMMON:
			return Rarity.COMMON
		PrizeType.RARE:
			return Rarity.RARE
		PrizeType.EPIC:
			return Rarity.EPIC
		PrizeType.LEGENDARY:
			return Rarity.LEGENDARY
		_:
			return Rarity.COMMON
