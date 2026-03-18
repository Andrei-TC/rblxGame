local BonusRegistry = {

	-- STATS
	STR = {Type="Stat"},
	DEX = {Type="Stat"},
	INT = {Type="Stat"},
	VIT = {Type="Stat"},

	MaxHP = {Type="Stat"},
	MaxMP = {Type="Stat"},

	AttackValue = {Type="Stat"},

	AttackSpeed = {Type="Stat"},
	CastingSpeed = {Type="Stat"},
	MoveSpeed = {Type="Stat"},

	HPRegen = {Type="Stat"},
	MPRegen = {Type="Stat"},

	-- CHANCE
	CriticalChance = {Type="Chance"},
	PenetrationChance = {Type="Chance"},
	BlockChance = {Type="Chance"},
	SlowChance = {Type="Chance"},
	PoisonChance = {Type="Chance"},

	LifeSteal = {Type="Chance"},
	ManaSteal = {Type="Chance"},
	ManaAbsorb = {Type="Chance"},

	-- DEFENSE
	SwordDefense = {Type="Defense"},
	TwoHandDefense = {Type="Defense"},
	DaggerDefense = {Type="Defense"},
	BellDefense = {Type="Defense"},
	FanDefense = {Type="Defense"},

	ArrowResistance = {Type="Defense"},
	MagicResistance = {Type="Defense"},
	LightningResistance = {Type="Defense"},
	WindResistance = {Type="Defense"},
	FireResistance = {Type="Defense"},

	PoisonResistance = {Type="Defense"},
	StunResistance = {Type="Defense"},
	SlowResistance = {Type="Defense"},
	ArrowDodge = {Type="Defense"},

	ReflectPhysicalDamage = {Type="Defense"},

	-- DAMAGE AGAINST
	StrongVsEsoteric = {Type="Damage"},
	StrongVsSemiHuman = {Type="Damage"},
	StrongVsOrc = {Type="Damage"},
	StrongVsDevil = {Type="Damage"},
	StrongVsAnimal = {Type="Damage"},
	StrongVsVampire = {Type="Damage"},

	-- ECONOMY
	BonusExperience = {Type="Economy"},
	DoubleYangDrop = {Type="Economy"},
	DoubleDrop = {Type="Economy"},

	-- WEAPON SPECIAL
	AverageDamage = {Type="Weapon"},
	SkillDamage = {Type="Weapon"}

}

return BonusRegistry