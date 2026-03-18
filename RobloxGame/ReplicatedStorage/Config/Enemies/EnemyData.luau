local EnemyData = {}

EnemyData.List = {

	Dog = {
		Level = 3,
		MaxHealth = 60,
		Damage = 8,
		AttackCooldown = 1.5,
		XP = 23,
		WalkSpeed = 14,
		AttackRange = 3,
		ActivationRadius = 80,
		SeparationDistance = 4,
		AggroType = "Aggressive",

		DropTable = {
			{ Item = "Sword", Chance = 0.025, Amount = {1,1} },
			{ Item = "AddBonus", Chance = 0.20, Amount = {1,2} }
		}
	},

	Amazon = {
		Level = 12,
		MaxHealth = 140,
		Damage = 18,
		AttackCooldown = 2,
		XP = 70,
		WalkSpeed = 13,
		AttackRange = 4,
		ActivationRadius = 100,
		SeparationDistance = 4,
		AggroType = "Passive",

		DropTable = {
			{ Item = "ChangeBonus", Chance = 0.15, Amount = {1,1} },
			{ Item = "Marble", Chance = 0.15 , Amount = {1,2}}
		}
	},

	Militar = {
		Level = 20,
		MaxHealth = 220,
		Damage = 25,
		AttackCooldown = 2.2,
		XP = 120,
		WalkSpeed = 12,
		AttackRange = 4,
		ActivationRadius = 120,
		SeparationDistance = 4,
		AggroType = "Passive",

		DropTable = {
			{ Item = "SteelArmor", Chance = 0.03, Amount = {1,1}  },
			{ Item = "GoldCoin", Chance = 0.80, Amount = {1,2} }
		}
	}

}

return EnemyData