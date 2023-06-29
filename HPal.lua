local queue = {
	"Pause",
	"Divine Shield",
	"Lay on Hands",
	"Divine Protection",
	"Hand of Protection",
	"Divine Sacrifice",
	"Hand of Sacrifice",
	"Use Healthstone",
	"Sacred Shield",
	"Beacon of Light",
	"Aura Mastery",
	"Divine Favor",
	"Divine Illumination",
	"Hand of Freedom",
	"Hammer of Wrath",
	"Hammer of Justice",
	"Bauble of True Blood",
	"Holy Shock",
	"Flash of Light",
	"Cleanse",
	"Blessing of Kings",
}

local values = {
	["Divine ShieldThreshold"] = 35,
	["Lay on HandsThreshold"] = 35,
	["Divine ProtectionThreshold"] = 35,
	["Hand of ProtectionThreshold"] = 35,
	["Divine SacrificeThreshold"] = 50,
	["Hand of SacrificeThreshold"] = 65,
	["Use HealthstoneThreshold"] = 40,
	--["Sacred ShieldThreshold"] = 0,
	--["Beacon of LightThreshold"] = 0,
	["Aura MasteryThreshold"] = 65,
	["Divine FavorThreshold"] = 75,
	["Divine IlluminationThreshold"] = 65,
	["Hand of FreedomThreshold"] = 65,
	["Hammer of WrathThreshold"] = 20,
	--["Hammer of JusticeThreshold"] = 0,
	["Bauble of True BloodThreshold"] = 50,
	["Holy ShockThreshold"] = 85,
	["Flash of LightThreshold"] = 85,
	--["CleanseThreshold"] = 0,
	--["Blessing of KingsThreshold"] = 0,
}

local enables = {
	["Divine Shield"] = true,
	["Lay on Hands"] = true,
	["Divine Protection"] = true,
	["Hand of Protection"] = true,
	["Divine Sacrifice"] = true,
	["Hand of Sacrifice"] = true,
	["Use Healthstone"] = true,
	["Sacred Shield"] = true,
	["Beacon of Light"] = true,
	["Aura Mastery"] = true,
	["Divine Favor"] = true,
	["Divine Illumination"] = true,
	["Hand of Freedom"] = true,
	["Hammer of Wrath"] = true,
	["Hammer of Justice"] = true,
	["Bauble of True Blood"] = true,
	["Holy Shock"] = true,
	["Flash of Light"] = true,
	["Cleanse"] = true,
	["Blessing of Kings"] = true,
}

local HoFDebuff = {
	"Chains of Ice",
	"Hamstring",
	"Crippling Poison",
	"Frostbolt",
	"Seal of Justice",
	"Cleave",
	"Slow",
	"Earthgrab Totem",
	"Ice Barrier",
	"Chilblains",
	"Blade Twisting",
	"Frost Nova",
	"Frostfire Bolt",
	"Dazed",
	"Entangling Roots",
	"Feral Charge - Cat",
	"Infected Wounds",
	"Typhoon",
	"Counterattack",
	"Entrapment",
	"Concussive Barrage",
	"Concussive Shot",
	"Wing Clip",
	"Glyph of Frost Nova",
	"Frostfire Orb",
	"Black Arrow",
	"T.N.T.",
	"Venom Web Spray",
	"Web",
	"Freeze",
	"Shattered Barrier",
	"Blast Wave",
	"Chilled",
	"Cone of Cold",
	"Frostbolt",
	"Frostfire Bolt",
	"Slow",
	"Seal of Command",
	"Blade Flurry",
	"Crippling Poison II",
	"Deadly Throw",
	"Earth and Moon",
	"Freeze",
	"Frost Shock",
	"Frostbrand Attack",
	"Aftermath",
	"Curse of Exhaustion",
	"Binding Heal",
	"Healing Touch",
	"Piercing Howl",
	"Frost Grenade",
	"Frost Presence",
	"Ice Barrier",
	"Dazed",
}

local cleanseDebuff = {34916, 34917, 34919, 48159, 48160, 30404, 30405, 31117, 34438, 35183, 43522, 47841, 47843, 65812, 68154, 68155, 68156, 44461, 55359, 55360, 55361, 55362, 61429}

local function GUICallback(key, item_type, value)
    if item_type == "enabled" then
        local ability = key:gsub("Threshold", "")
        enables[ability] = value
    elseif item_type == "value" then
        values[key] = value
    end
end

-- GUI
local items = {
	settingsfile = "HPal.json",
    callback = GUICallback,
	{ type = "separator" },
    { type = "title", text = "|cffFFFF00Holy Paladin|r PVP Profile" },
	{ type = "separator" },
}

for _, ability in ipairs(queue) do
    if ability ~= "Pause" and "Cache" then
        table.insert(items, {
            type = "entry",
            text = ability,
            enabled = enables[ability],
            value = values[ability.."Threshold"],
            key = ability.."Threshold"
        })
    end
end

-- Function to get item ID by name
local function GetItemIdByName(itemName)
    if not itemName then return end
    local _, itemLink = GetItemInfo(itemName)
    if itemLink then
        return tonumber(itemLink:match("item:(%d+)"))
    end
    return nil
end

-- Ability functions
local abilities = {
    -- Pause
	["Pause"] = function()
		if IsMounted()
			or UnitInVehicle("player")
			or UnitIsDeadOrGhost("player")
			or UnitChannelInfo("player")
			or UnitCastingInfo("player")
			or ni.player.islooting()
			or ni.unit.isstunned("player")
			or ni.unit.issilenced("player")
			or ni.unit.ispacified("player")
			or ni.unit.isdisarmed("player")
			or ni.unit.isfleeing("player")
			or ni.unit.ispossessed("player")
			or ni.unit.debuff("player", "Polymorph")
			or ni.unit.debuff("player", "Cyclone")
			or ni.unit.debuff("player", "Fear")
			or ni.unit.debuff("player", "Blind")
		then
			return true
		end
	end,

	-- Divine Shield
	["Divine Shield"] = function()
		if enables["Divine Shield"]
			and ni.spell.available("Divine Shield")
			and UnitAffectingCombat("player")
		then
			if ni.unit.hp("player") <= values["Divine ShieldThreshold"]
				and not ni.unit.debuff("player", "Forbearance")
			then
				if UnitCastingInfo("player") or UnitChannelInfo("player") 
				then
					ni.spell.stopcasting()
				end
				ni.spell.cast("Divine Shield", "player")
				print("Divine Shield")
				return true
			end
		end
		return false
	end,

	-- Lay on Hands
	["Lay on Hands"] = function()
		if enables["Lay on Hands"] then
			local inArena = select(2, IsInInstance()) == "arena"
			if inArena then
				return false
			end
			if ni.spell.available("Lay on Hands") 
				and UnitAffectingCombat("player")
				and not ni.unit.debuff("player", "Forbearance")			
			then
				local lowMember = ni.members.inrangebelow("player", 40, values["Lay on HandsThreshold"])[1]
				if lowMember 
					and lowMember:valid("Lay on Hands", false, true) 
				then
					ni.spell.cast("Lay on Hands", lowMember.guid)
					print("Lay on Hands", lowMember.name)
					return true
				end
			end
		end
		return false
	end,

	-- Divine Protection
	["Divine Protection"] = function()
		if enables["Divine Protection"]
			and ni.spell.available("Divine Protection")
			and UnitAffectingCombat("player")
		then
			if ni.unit.hp("player") <= values["Divine ShieldThreshold"]
				and not ni.unit.debuff("player", "Forbearance")
			then
				if UnitCastingInfo("player") or UnitChannelInfo("player")
				then
					ni.spell.stopcasting()
				end
				ni.spell.cast("Divine Protection", "player")
				print("Divine Protection")
				return true
			end
		end
		return false
	end,

	-- Hand of Protection
	["Hand of Protection"] = function()
		if enables["Hand of Protection"]
			and ni.spell.available("Hand of Protection")
			and UnitAffectingCombat("player")
		then
			local lowMember = ni.members.inrangebelow("player", 40, values["Hand of ProtectionThreshold"])[1]
			if lowMember 
				and lowMember:valid("Hand of Protection", false, true) 
				and not ni.unit.debuff("player", "Forbearance")
			then
				ni.spell.cast("Hand of Protection", lowMember.guid)
				print("Hand of Protection", lowMember.name)
				return true
			end
		end
		return false
	end,

	-- Divine Sacrifice
	["Divine Sacrifice"] = function()
		if enables["Divine Sacrifice"] 
			and ni.spell.available("Divine Sacrifice") 
			and UnitAffectingCombat("player")
		then
			local lowMember = ni.members.inrangebelow("player", 40, values["Divine SacrificeThreshold"])[1]
			if lowMember 
				and lowMember:valid("Divine Sacrifice", false, true) 
			then
				ni.spell.cast("Divine Sacrifice", lowMember.guid)
				print("Divine Sacrifice", lowMember.name)
				return true
			end
		end
		return false
	end,

	-- Hand of Sacrifice
	["Hand of Sacrifice"] = function()
		if enables["Hand of Sacrifice"] 
			and ni.spell.available("Hand of Sacrifice")
			and UnitAffectingCombat("player")
		then
			local lowMember = ni.members.inrangebelow("player", 40, values["Hand of SacrificeThreshold"])[1]
			if lowMember 
				and lowMember:valid("Hand of Sacrifice", false, true) 
			then
				ni.spell.cast("Hand of Sacrifice", lowMember.guid)
				print("Hand of Sacrifice", lowMember.name)
				return true
			end
		end
		return false
	end,

	-- Use Healthstone
	["Use Healthstone"] = function()
		if enables["Use Healthstone"]
			and ni.unit.hp("player") <= values["Use HealthstoneThreshold"]
		then
			if ni.player.hasitem(GetItemIdByName("Fel Healthstone"))
				and UnitAffectingCombat("player")
			then
				ni.player.useitem("Fel Healthstone")
				print("Healthstone")
				return true
			end
		end
		return false
	end,

	-- Sacred Shield
	["Sacred Shield"] = function()
		if enables["Sacred Shield"]
			and ni.spell.available("Sacred Shield")
		then
			if not ni.unit.buff("player", "Sacred Shield")
				and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection"))
			then
				ni.spell.cast("Sacred Shield", "player")
				print("Sacred Shield")
				return true
			end
		end
		return false
	end,

	-- Beacon of Light
	["Beacon of Light"] = function()
		if enables["Beacon of Light"]
			and ni.spell.available("Beacon of Light")
		then
			if not ni.unit.buff("player", "Beacon of Light")
				and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection"))
			then
				ni.spell.cast("Beacon of Light", "player")
				print("Beacon of Light")
				return true
			end
		end
		return false
	end,

	-- Aura Mastery
	["Aura Mastery"] = function()
		if enables["Aura Mastery"]
			and ni.spell.available("Aura Mastery")
		then
			if ni.unit.hp("player") <= values["Aura MasteryThreshold"]
				and ni.unit.buff("player", "Concentration Aura")
				and UnitAffectingCombat("player")
				and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection"))
			then
				ni.spell.cast("Aura Mastery", "player")
				print("Aura Mastery")
				return true
			end
		end
		return false
	end,

	-- Divine Favor
	["Divine Favor"] = function()
		if enables["Divine Favor"]
			and ni.spell.available("Divine Favor")
		then
			if ni.unit.hp("player") <= values["Divine FavorThreshold"]
				and ni.spell.available("Holy Shock")
				and UnitAffectingCombat("player")
			then
				local lowMember = ni.members.inrangebelow("player", 40, values["Divine FavorThreshold"])[1]
				if lowMember 
					and lowMember:valid("Holy Shock", false, true) 
				then
					ni.spell.cast("Divine Favor", "player")
					ni.spell.cast("Holy Shock", lowMember.guid)
					print("Divine Favor")
					print("Holy Shock", lowMember.name)
					return true
				end
			end
		end
		return false
	end,

	-- Divine Illumination
	["Divine Illumination"] = function()
		if enables["Divine Illumination"]
			and ni.spell.available("Divine Illumination")
		then
			if ni.unit.power("player") <= values["Divine IlluminationThreshold"]
				and UnitAffectingCombat("player")
			then
				ni.spell.cast("Divine Illumination", "player")
				print("Divine Illumination")
				return true
			end
		end
	end,

	-- Hammer of Wrath
	["Hammer of Wrath"] = function()
		if enables["Hammer of Wrath"] then
			local enemies = ni.unit.enemiesinrange("player", 30)
			for i = 1, #enemies do
				local target = enemies[i].guid
				if ni.unit.hp(target) <= values["Hammer of WrathThreshold"]
					and ni.spell.available("Hammer of Wrath")
					and ni.spell.valid(target, "Hammer of Wrath", false, true)
				then
					ni.player.lookat(target)
					ni.spell.cast("Hammer of Wrath", target)
					print("Hammer of Wrath", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Hand of Freedom
	["Hand of Freedom"] = function()
		if enables["Hand of Freedom"]
			and ni.spell.available("Hand of Freedom") 
		then
			for i = 1, #ni.members.sort() do
				local member = ni.members[i]
				local hasHoFDebuff = false
				for debuffName, debuffId in pairs(HoFDebuff) do
					if member:debuff(debuffId) then
						hasHoFDebuff = true
						break
					end
				end
				if member:combat() 
					and (ni.healing.candispel(member.guid) or hasHoFDebuff) 
					and member:valid("Hand of Freedom", false, true) 
				then
					ni.spell.cast("Hand of Freedom", member.unit)
					print("Hand of Freedom cast on " .. member.name)
					return true
				end
			end
		end
		return false
	end,

	-- Hammer of Justice
	["Hammer of Justice"] = function()
		if enables["Hammer of Justice"] 
			and ni.spell.available("Hammer of Justice") 
		then
			local targetEnemy = ni.unit.enemiesinrange("player", 10)
			if targetEnemy 
				and ni.spell.valid(targetEnemy, "Hammer of Justice") 
			then
				ni.spell.cast("Hammer of Justice", targetEnemy)
				print("Hammer of Justice", targetEnemy)
				return true
			end
		end
		return false
	end,

	-- Bauble of True Blood (Trinket)
	-- Uses the Bauble of True Blood trinket on any group member if their health is below the threshold.
	["Bauble of True Blood"] = function()
		if enables["Bauble of True Blood"] 
			and ni.player.hasitemequipped(50354) 
			and ni.player.itemcd(50354) == 0
		then
			local membersInRange = ni.members.inrange("player", 40)
			for i = 1, #membersInRange do
				local member = membersInRange[i]
				if member:hp() <= values["Bauble of True BloodThreshold"]
					and member:combat()
					and member:los()
				then
					ni.player.useitem(50354, member.guid)
					print("Bauble of True Blood", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,


	-- Holy Shock
	["Holy Shock"] = function()
		if enables["Holy Shock"]
			and ni.spell.available("Holy Shock")
		then
			local lowMember = ni.members.inrangebelow("player", 40, values["Holy ShockThreshold"])[1]
			if lowMember 
				and lowMember:valid("Holy Shock", false, true) 
			then
				ni.spell.cast("Holy Shock", lowMember.guid)
				print("Holy Shock", lowMember.name)
				return true
			end
		end
	end,

	-- Flash of Light
	["Flash of Light"] = function()
		if enables["Flash of Light"] then
			if (not ni.player.movingfor(0.1) or ni.unit.buff("player", "Infusion of Light"))
				and ni.spell.available("Flash of Light") 
			then
				local lowMember = ni.members.inrangebelow("player", 40, values["Flash of LightThreshold"])[1]
				if lowMember 
					and lowMember:valid("Flash of Light", false, true) 
				then
					ni.spell.cast("Flash of Light", lowMember.guid)
					print("Flash of Light", lowMember.name)
					return true
				end
			end
		end
	end,

	-- Cleanse
	["Cleanse"] = function()
		if enables["Cleanse"] 
			and ni.spell.available("Cleanse") 
		then
			local dispelMember = ni.members.inrange("player", 40)
			if dispelMember 
				and dispelMember.guid
				and ni.healing.candispel(dispelMember.guid) 
				and dispelMember:valid("Cleanse", false, true) 
			then
				ni.spell.cast("Cleanse", dispelMember.guid)
				print("Cleanse", dispelMember.name)
				return true
			end
		end
		return false
	end,

	-- Blessing of Kings
	["Blessing of Kings"] = function()
		if enables["Blessing of Kings"]
			and ni.spell.available("Blessing of Kings")
		then
			local hasGreaterBlessing = ni.unit.buff("player", "Greater Blessing of Kings")
			local hasBlessing = ni.unit.buff("player", "Blessing of Kings")

			if not hasBlessing and not hasGreaterBlessing then
				ni.spell.cast("Blessing of Kings", "player")
				print("Blessing of Kings")
				return true
			end
		end
		return false
	end,
}

local function OnLoad()
    ni.GUI.AddFrame("HPal", items)
end

local function OnUnLoad()
    ni.GUI.DestroyFrame("HPal")
end

ni.bootstrap.profile("HPal", queue, abilities, OnLoad, OnUnLoad)
