local queue = {
	"Divine Shield",
	"Hand of Protection",
    "Lay on Hands",
	"Divine Protection",
	"Use Healthstone",
    "Divine Sacrifice",
    "Hand of Sacrifice",
    "Hammer of Wrath",
    "Hammer of Justice",
	"Aura Mastery",
	"Divine Favor",
    "Divine Illumination",
    "Hand of Freedom",
    "Holy Shock",
    "Flash of Light",
    "Cleanse",
    "Sacred Shield",
    "Beacon of Light",
    "Greater Blessing of Kings",
    "Blessing of Kings",
}

local values = {
	["Divine ShieldThreshold"] = 35,
	["Hand of ProtectionThreshold"] = 40,
    ["Divine ProtectionThreshold"] = 40,
    ["Lay on HandsThreshold"] = 25,
    ["Aura MasteryThreshold"] = 65,
    ["Divine IlluminationThreshold"] = 65,
    ["Divine SacrificeThreshold"] = 75,
    ["Divine FavorThreshold"] = 25,
    ["Hand of FreedomThreshold"] = 65,
	["Hand of SacrificeThreshold"] = 40,
    ["Holy ShockThreshold"] = 88,
    ["Flash of LightThreshold"] = 88,
    ["Seal of WisdomThreshold"] = 35,
    ["Seal of LightThreshold"] = 70,
	["Hammer of WrathThreshold"] = 20,
}
local dispellableDebuffs = {
}
local HoFDebuff = {
    "Frost Nova",
    "Frostbite",
    "Cone of Cold",
    "Entangling Roots",
    "Hamstring",
    "Crippling Poison",
    "Chains of Ice",
    "Infected Wounds",
    "Earthbind",
    "Curse of Exhaustion",
    "Wing Clip",
    "Frost Shock",
    "Piercing Howl",
    "Improved Wing Clip",
    "Improved Hamstring",
    "Frostfire Bolt",
    "Mind-numbing Poison",
    "Curse of Tongues",
    "Slow",
    "Sap",
    "Garrote - Silence",
    "Kidney Shot",
    "Gouge",
    "Blind",
    "Polymorph",
    "Repentance",
    "Intimidating Shout",
    "Howl of Terror",
    "Psychic Scream",
    "Fear",
    "Hex",
    "Turn Evil",
    "Seduction",
    "Wyvern Sting",
    "Mortal Coil",
    "Sap"
}

local CleanseDebuff = {
    "Viper Sting",
    "Serpent Sting",
    "Corruption",
    "Curse of Agony",
    "Curse of the Elements",
    "Curse of Tongues",
    "Curse of Weakness",
    "Frost Fever",
    "Blood Plague",
    "Deadly Poison",
    "Mind Flay",
    "Shadow Word: Pain",
    "Devouring Plague",
    "Polymorph",
    "Fear",
    "Psychic Scream",
    "Hex",
    "Repentance",
    "Frostbolt",
    "Freeze",
    "Wound Poison",
    "Arcane Torrent",
    "Strangulate",
    "Silence",
    "Garrote - Silence",
    "Counterspell",
    "Silencing Shot",
    "Pummel",
    "Skull Bash",
    "Kick",
    "Wind Shear"
}


-- Local Containers
local enables = {}

local function GUICallback(key, item_type, value)
    if item_type == "enabled" and enables[key] ~= nil then
        enables[key] = value
    elseif item_type == "value" and values[key] ~= nil then
        values[key] = value
    end
end

local items = {
    callback = GUICallback,
    { type = "title", text = "Holy Paladin PvP Profile" },
    { type = "separator" },
}

for _, ability in ipairs(queue) do
    table.insert(items, {
        type = "entry",
        text = ability,
        value = values[ability.."Threshold"],
        min = 0,
        max = 100,
        step = 1,
        key = ability.."Threshold",
        enabled = enables[ability]
    })
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

-- Function to check if the player is eligible to cast a spell
local function ucheck()
    return not IsMounted() and not UnitInVehicle("player") and not UnitIsDeadOrGhost("player")
        and not UnitChannelInfo("player") and not UnitCastingInfo("player") and not ni.unit.isstunned("player") and not ni.unit.issilenced("player") and not ni.unit.ispacified("player") and not ni.unit.isdisarmed("player") and not ni.unit.isfleeing("player") and not ni.unit.ispossessed("player") and not ni.unit.buff("player", "Polymorph")
end

-- Ability functions
local abilities = {
	-- Divine Shield
	-- Casts Divine Shield on the player if their health is below the threshold.
	["Divine Shield"] = function()
		if ni.unit.hp("player") <= values["Divine ShieldThreshold"] and not ni.unit.debuff("player", "Forbearance") and ucheck() and ni.spell.available("Divine Shield") and UnitAffectingCombat("player") then
			if UnitCastingInfo("player") or UnitChannelInfo("player") then
				ni.spell.stopcasting()
			end
			ni.spell.cast("Divine Shield", "player")
			print("Divine Shield")
			return true
		end
		return false
	end,	
	
	-- Divine Protection
	-- Casts Divine Protection on the player if their health is below the threshold.
	["Divine Protection"] = function()
		if ni.unit.hp("player") <= values["Divine ProtectionThreshold"] and not ni.unit.debuff("player", "Forbearance") and ucheck() and not ni.spell.available("Divine Shield") and ni.spell.available("Divine Protection") and UnitAffectingCombat("player") then
			if UnitCastingInfo("player") or UnitChannelInfo("player") then
				ni.spell.stopcasting()
			end
			ni.spell.cast("Divine Protection", "player")
			print("Divine Protection")
			return true
		end
		return false
	end,

	-- Hand of Protection
	-- Casts Hand of Protection on any group member if their health is below the threshold.
	["Hand of Protection"] = function()
		for i = 1, #ni.members do
			if ni.members[i]:hp() <= values["Hand of ProtectionThreshold"] and not ni.members[i]:debuff("Forbearance") and ucheck() and ni.spell.available("Hand of Protection") and ni.members[i]:valid("Hand of Protection", false, true) and ni.members[i]:combat() then
				if UnitCastingInfo("player") or UnitChannelInfo("player") then
					ni.spell.stopcasting()
				end
				ni.spell.cast("Hand of Protection", ni.members[i].guid)
				print("Hand of Protection")
				return true
			end
		end
		return false
	end,


    -- Lay on Hands
    -- Casts Lay on Hands on any group member if their health is below the threshold.
	["Lay on Hands"] = function()
		for i = 1, #ni.members do
			if ni.members[i]:hp() <= values["Lay on HandsThreshold"] and not ni.members[i]:debuff("Forbearance") and ucheck() and ni.spell.available("Lay on Hands") and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection")) and ni.members[i]:valid("Lay on Hands") and ni.members[i]:combat() then
				if UnitCastingInfo("player") or UnitChannelInfo("player") then
					ni.spell.stopcasting()
				end
				ni.spell.cast("Lay on Hands", ni.members[i].guid)
				print("Lay on Hands")
				return true
			end
		end
		return false
	end,

	-- Hand of Sacrifice
	-- Casts Hand of Sacrifice on any group member if their health is below the threshold, the player is in combat, and they pass the ucheck conditions.
	["Hand of Sacrifice"] = function()
		for i = 1, #ni.members do
			if ni.members[i]:hp() <= values["Hand of SacrificeThreshold"] and ucheck() and ni.spell.available("Hand of Sacrifice") and ni.members[i]:valid("Hand of Sacrifice") and ni.members[i]:combat() and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection"))
			then
				ni.spell.cast("Hand of Sacrifice", ni.members[i].guid)
				print("Hand of Sacrifice")
				return true
			end
		end
		return false
	end,

    -- Aura Mastery
    -- Casts Aura Mastery if the player's health is below the threshold.
    ["Aura Mastery"] = function()
		if ni.unit.hp("player") <= values["Aura MasteryThreshold"] and
        ni.unit.buff("player", "Concentration Aura") and ucheck() and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection")) and ni.spell.available("Aura Mastery") and UnitAffectingCombat("player") then
			ni.spell.cast("Aura Mastery", "player")
			print("Aura Mastery")
			return true
		end
		return false
	end,

    -- Divine Illumination
    -- Casts Divine Illumination if the player's mana is below the threshold.
	   ["Divine Illumination"] = function()
		if ni.unit.power("player") <= values["Divine IlluminationThreshold"] and ucheck() and ni.spell.available("Divine Illumination") and UnitAffectingCombat("player") then
			ni.spell.cast("Divine Illumination", "player")
			print("Divine Illumination")
			return true
		end
		return false
	end,
	
    -- Divine Sacrifice
    -- Casts Divine Sacrifice on any group member if their health is below the threshold and the player has line of sight to them.
	["Divine Sacrifice"] = function()
		for i = 1, #ni.members do
			if ni.members[i]:hp() <= values["Divine SacrificeThreshold"] and ucheck() and ni.spell.available("Divine Sacrifice") and ni.members[i]:valid("Divine Sacrifice") and ni.members[i]:combat() then
				ni.spell.cast("Divine Sacrifice", ni.members[i].guid)
				print("Divine Sacrifice")
				return true
			end
		end
		return false
	end,

    -- Divine Favor
    -- Casts Divine Favor if their health is below the threshold and the player has line of sight to them.
	["Divine Favor"] = function()
		for i = 1, #ni.members do
			-- Check if the conditions for Holy Shock are met
			if ni.members[i]:hp() <= values["Holy ShockThreshold"] and ucheck() and ni.spell.available("Holy Shock") and ni.members[i]:valid("Holy Shock", false, true) and ni.members[i]:combat() then
				-- If the conditions for Holy Shock are met, check if Divine Favor can be cast
				if ni.members[i]:hp() <= values["Divine FavorThreshold"] and ucheck() and ni.spell.available("Divine Favor") then
					ni.spell.cast("Divine Favor", ni.members[i].guid)
					print("Divine Favor")
					return true
				end
			end
		end
		return false
	end,

    -- Use Healthstone
	-- Uses a Healthstone if the player's health is below 20% and passes the ucheck conditions.
	["Use Healthstone"] = function()
		if ni.unit.hp("player") <= 20 and ni.player.hasitem("Fel Healthstone") and ucheck() and UnitAffectingCombat("player") then
			ni.player.useitem(GetItemIdByName("Fel Healthstone"))
			print("Healthstone")
			return true
		end
		return false
	end,

	-- Hammer of Wrath
	-- Casts on an enemy target within 30 yards if their health is below the threshold and the spell is available.
	["Hammer of Wrath"] = function()
		local enemies = ni.unit.enemiesinrange("player", 30)
		for i = 1, #enemies do
			local target = enemies[i].guid
			if ni.unit.hp(target) <= values["Hammer of WrathThreshold"] and ucheck() and ni.spell.available("Hammer of Wrath") and ni.spell.valid(target, "Hammer of Wrath", false, true) then
				ni.player.lookat(target)
				ni.spell.cast("Hammer of Wrath", target)
				print("Hammer of Wrath")
				return true
			end
		end

		return false
	end,

	-- Hammer of Justice
	-- Casts on an enemy target within 10 yards if they are casting or channeling, and the spell is available.
	["Hammer of Justice"] = function()
		local enemies = ni.unit.enemiesinrange("player", 10)
		for i = 1, #enemies do
			local target = enemies[i].guid
			if (ni.unit.iscasting(target) or ni.unit.ischanneling(target)) and ucheck() and ni.spell.available("Hammer of Justice") and ni.spell.valid(target, "Hammer of Justice") then
				ni.spell.cast("Hammer of Justice", target)
				print("Hammer of Justice")
				return true
			end
		end

		return false
	end,

	-- Hand of Freedom
	-- Casts Hand of Freedom on any group member in combat if they have a Snare, Root, or Stun debuff and the player has line of sight to them.
	["Hand of Freedom"] = function()
		for i = 1, #ni.members do
			if ni.members[i]:combat() and ni.spell.debuff(ni.members[i].guid, HoFDebuff) and ucheck() and ni.spell.available("Hand of Freedom") and ni.members[i]:valid("Hand of Freedom", false, true) then
				ni.spell.cast("Hand of Freedom", ni.members[i].guid)
				print("Hand of Freedom")
				return true
			end
		end
		return false
	end,

	-- Cleanse
	-- Casts Cleanse on any group member if they have a dispellable debuff and the player has line of sight to them.
	["Cleanse"] = function()
		for i = 1, #ni.members do
			if ni.healing.candispel(ni.members[i].guid) and not ni.healing.dontdispel(ni.members[i].guid) and ucheck() and ni.spell.available("Cleanse") and ni.spell.debuff(ni.members[i].guid, CleanseDebuff) and ni.members[i]:valid("Cleanse", false, true) then
				ni.spell.cast("Cleanse", ni.members[i].guid)
				print("Cleanse")
				return true
			end
		end
		return false
	end,

    -- Holy Shock
    -- Casts Holy Shock on any group member if their health is below the threshold and the player has line of sight to them.
    ["Holy Shock"] = function()
        for i = 1, #ni.members do
            if ni.members[i]:hp() <= values["Holy ShockThreshold"] and ucheck() and ni.spell.available("Holy Shock") and ni.members[i]:valid("Holy Shock", false, true) then
                ni.spell.cast("Holy Shock", ni.members[i].guid)
				print("Holy Shock")
                return true
            end
        end
        return false
    end,

	-- Flash of Light
	-- Casts Flash of Light on any group member if the player is not moving for 0.1 seconds or has the Infusion of Light buff, and the group member's health is below the threshold.
	["Flash of Light"] = function()
		local isMoving = ni.player.movingfor(0.1)
		local hasInfusionOfLight = ni.unit.buff("player", "Infusion of Light")
		for i = 1, #ni.members do
			if (not isMoving or hasInfusionOfLight) and ni.members[i]:hp() <= values["Flash of LightThreshold"] and ucheck() and ni.spell.available("Flash of Light") and ni.members[i]:valid("Flash of Light", false, true) then
				ni.spell.cast("Flash of Light", ni.members[i].guid)
				print("Flash of Light")
				return true
			end
		end
		return false
	end,

    -- Sacred Shield
    -- Casts Sacred Shield on the player if they do not already have the Sacred Shield buff.
    ["Sacred Shield"] = function()
		if not ni.unit.buff("player", "Sacred Shield") and ucheck("player", "Sacred Shield") and ni.spell.available("Sacred Shield") then
            ni.spell.cast("Sacred Shield", "player")
            print("Sacred Shield")
			return true
        end
        return false
    end,

    -- Beacon of Light
    -- Casts Beacon of Light on the player if they do not already have the Beacon of Light buff.
    ["Beacon of Light"] = function()
        if not ni.unit.buff("player", "Beacon of Light") and ucheck("player", "Beacon of Light") and ni.spell.available("Beacon of Light") then
            ni.spell.cast("Beacon of Light", "player")
			print("Beacon of Light")
            return true
        end
        return false
    end,

    -- Blessing of Kings
    -- If we do not have Blessing of Kings buff, buff self
    -- If we have Greater of Blessing of Kings, do not override buff by cast Blessing of Kings
    ["Blessing of Kings"] = function()
        local hasGreaterBlessing = ni.unit.buff("player", "Greater Blessing of Kings")
        local hasBlessing = ni.unit.buff("player", "Blessing of Kings")
        if not hasBlessing and not hasGreaterBlessing and ucheck("player", "Blessing of Kings") and ni.spell.available("Blessing of Kings") then
            ni.spell.cast("Blessing of Kings", "player")
			print("Blessing of Kings")
            return true
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
