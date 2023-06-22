local queue = {
	"Divine Shield",
	"Hand of Protection",
    "Divine Protection",
    "Lay on Hands",
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
    "Concussive Shot",
    "Wing Clip",
    "Hamstring",
    "Improved Hamstring",
    "Frost Shock",
    "Crippling Poison",
    "Frostbolt",
    "Frost Nova",
    "Chilled",
    "Slow",
    "Deadly Throw",
    "Frostbrand Attack"
}

-- Local Containers
local enables = {}
local spellIDs = {}
local itemIDs = {}

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

-- Function to get spell ID by name
local function GetSpellIdByName(spellName)
    if not spellName then return end
    local spellLink = GetSpellLink(spellName)
    if spellLink then
        return tonumber(spellLink:match("spell:(%d+)"))
    end
    return nil
end

-- Assign spell IDs to spell names, "Use Healthstone is excempted"
for _, spellName in ipairs(queue) do
    if spellName ~= "Use Healthstone" then
        local spellId = GetSpellIdByName(spellName)
        if spellId then
            spellIDs[spellName] = spellId
        else
            print("Could not find spell ID for " .. spellName)
        end
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

-- Function to check if the player is eligible to cast a spell
local function ucheck()
    return not IsMounted() and not UnitInVehicle("player") and not UnitIsDeadOrGhost("player")
        and not UnitChannelInfo("player") and not UnitCastingInfo("player")
        and not ni.unit.isstunned("player") and not ni.unit.issilenced("player")
        and not ni.unit.ispacified("player") and not ni.unit.isdisarmed("player")
        and not ni.unit.isfleeing("player") and not ni.unit.ispossessed("player")
end


-- Function Dispellable Debuffs
local function canDispel(unit)
    for i = 1, #dispellableDebuffs do
        if ni.unit.debuff(unit, dispellableDebuffs[i]) then
            return true
        end
    end
    return false
end

-- Function Line of Sight Checker
local function losCheck()
    for i = 1, #ni.members do
        if ni.members[i]:los() then
            return true
        end
    end
    return false
end

-- Function to target an enemy within range
local function tarEnemy(range)
    local enemies = ni.unit.enemiesinrange("player", range)
    local target = nil

    for i = 1, #enemies do
        if target == nil or enemies[i].distance < target.distance then
            target = enemies[i]
        end
    end

    if target then
        return target.guid
    end

    return nil
end

-- Ability functions
local abilities = {
	-- Divine Shield
	-- Casts Divine Shield on the player if their health is below the threshold, they do not have the Forbearance debuff, and meet certain conditions.
	["Divine Shield"] = function()
		if ni.unit.hp("player") <= values["Divine ShieldThreshold"] and not ni.members[i]:debuff(spellIDs["Forbearance"], "exact") and ni.spell.available(spellIDs["Divine Shield"]) and not IsMounted() and not UnitInVehicle("player") and not UnitIsDeadOrGhost("player") and UnitAffectingCombat("player") then
			if UnitCastingInfo("player") or UnitChannelInfo("player") then
				ni.spell.stopcasting()
			end
			ni.spell.cast(spellIDs["Divine Shield"], "player")
			print("Divine Shield")
			return true
		end
		return false
	end,

	-- Divine Protection
	-- Casts Divine Protection on the player if their health is below the threshold and Divine Shield is not available.
	["Divine Protection"] = function()
		if ni.unit.hp("player") <= values["Divine ProtectionThreshold"] and not ni.members[i]:debuff(spellIDs["Forbearance"], "exact") and ucheck() and ni.spell.available(spellIDs["Divine Protection"]) and UnitAffectingCombat("player") then
			if UnitCastingInfo("player") or UnitChannelInfo("player") then
				ni.spell.stopcasting()
			end
			ni.spell.cast(spellIDs["Divine Protection"], "player")
			print("Divine Protection")
			return true
		end
		return false
	end,

	-- Hand of Protection
	-- Casts Hand of Protection on any group member if their health is below the threshold and the player has line of sight to them, and they do not have the Forbearance debuff.
	["Hand of Protection"] = function()
		for i = 1, #ni.members do
			if ni.members[i]:hp() <= values["Hand of ProtectionThreshold"] and not ni.members[i]:debuff(spellIDs["Forbearance"], "exact") and ucheck() and ni.spell.available(spellIDs["Hand of Protection"]) and ni.members[i]:valid(spellIDs["Hand of Protection"], false, true) and ni.members[i]:combat() then
				if UnitCastingInfo("player") or UnitChannelInfo("player") then
					ni.spell.stopcasting()
				end
				ni.spell.cast(spellIDs["Hand of Protection"], ni.members[i].guid)
				print("Hand of Protection")
				return true
			end
		end
		return false
	end,


    -- Lay on Hands
    -- Casts Lay on Hands on any group member if their health is below the threshold and the player has line of sight to them.
	["Lay on Hands"] = function()
		for i = 1, #ni.members do
			if ni.members[i]:hp() <= values["Lay on HandsThreshold"] and not ni.members[i]:debuff(spellIDs["Forbearance"], "exact") and ucheck() and ni.spell.available(spellIDs["Lay on Hands"]) and ni.members[i]:valid(spellIDs["Lay on Hands"]) and ni.members[i]:combat() then
				if UnitCastingInfo("player") or UnitChannelInfo("player") then
					ni.spell.stopcasting()
				end
				ni.spell.cast(spellIDs["Lay on Hands"], ni.members[i].guid)
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
			if ni.members[i]:hp() <= values["Hand of SacrificeThreshold"] and ucheck() and ni.spell.available(spellIDs["Hand of Sacrifice"]) and ni.members[i]:valid(spellIDs["Hand of Sacrifice"]) and ni.members[i]:combat() then
				ni.spell.cast(spellIDs["Hand of Sacrifice"], ni.members[i].guid)
				print("Hand of Sacrifice")
				return true
			end
		end
		return false
	end,

    -- Aura Mastery
    -- Casts Aura Mastery if the player's health is below the threshold.
    ["Aura Mastery"] = function()
		if ni.unit.hp("player") <= values["Aura MasteryThreshold"] and ucheck() and ni.spell.available(spellIDs["Aura Mastery"]) and UnitAffectingCombat("player") then
			ni.spell.cast(spellIDs["Aura Mastery"], "player")
			print("Aura Mastery")
			return true
		end
		return false
	end,

    -- Divine Illumination
    -- Casts Divine Illumination if the player's mana is below the threshold.
	   ["Divine Illumination"] = function()
		if ni.unit.power("player") <= values["Divine IlluminationThreshold"] and ucheck() and ni.spell.available(spellIDs["Divine Illumination"]) and UnitAffectingCombat("player") then
			ni.spell.cast(spellIDs["Divine Illumination"], "player")
			print("Divine Illumination")
			return true
		end
		return false
	end,
	
    -- Divine Sacrifice
    -- Casts Divine Sacrifice on any group member if their health is below the threshold and the player has line of sight to them.
	["Divine Sacrifice"] = function()
		for i = 1, #ni.members do
			if ni.members[i]:hp() <= values["Divine SacrificeThreshold"] and ucheck() and ni.spell.available(spellIDs["Divine Sacrifice"]) and ni.members[i]:valid(spellIDs["Divine Sacrifice"]) and ni.members[i]:combat() then
				ni.spell.cast(spellIDs["Divine Sacrifice"], ni.members[i].guid)
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
			if ni.members[i]:hp() <= values["Divine FavorThreshold"] and ucheck() and ni.spell.available(spellIDs["Divine Favor"]) and ni.members[i]:combat() then
				ni.spell.cast(spellIDs["Divine Favor"], ni.members[i].guid)
				print("Divine Favor")
				return true
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
		local target = tarEnemy(30)
		if target and ni.unit.hp(target) <= values["Hammer of WrathThreshold"] and ucheck() and ni.spell.available(spellIDs["Hammer of Wrath"]) and ni.spell.valid(target, spellIDs["Hammer of Wrath"], false, true) then
				ni.player.lookat(target)
				ni.spell.cast(spellIDs["Hammer of Wrath"], target)
				print("Hammer of Wrath")
			
			return true
		end
		return false
	end,

	-- Hammer of Justice
	--Casts on an enemy target within 10 yards if they are casting or channeling, and the spell is available.
	["Hammer of Justice"] = function()
		local target = tarEnemy(10)
		if target and (ni.unit.iscasting(target) or ni.unit.ischanneling(target)) and ucheck() and ni.spell.available(spellIDs["Hammer of Justice"]) and ni.spell.valid(target, spellIDs["Hammer of Justice"]) then
			ni.spell.cast(spellIDs["Hammer of Justice"], target)
			print("Hammer of Justice")
			return true
		end
		return false
	end,
	
	-- Hand of Freedom
    -- Casts Hand of Freedom on any group member if they have a Snare debuff and the player has line of sight to them.
    ["Hand of Freedom"] = function()
        for i = 1, #ni.members do
            if ni.members[i]:debufftype("Snare") and ucheck() and ni.spell.available(spellIDs["Hand of Freedom"]) and ni.members[i]:valid(spellIDs["Hand of Freedom"], false, true) then
                ni.spell.cast(spellIDs["Hand of Freedom"], ni.members[i].guid)
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
			if ni.healing.candispel(ni.members[i].guid) and not ni.healing.dontdispel(ni.members[i].guid) and ucheck() and ni.spell.available(spellIDs["Cleanse"]) and ni.members[i]:valid(spellIDs["Cleanse"], false, true) then
				ni.spell.cast(spellIDs["Cleanse"], ni.members[i].guid)
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
            if ni.members[i]:hp() <= values["Holy ShockThreshold"] and ucheck() and ni.spell.available(spellIDs["Holy Shock"]) and ni.members[i]:valid(spellIDs["Holy Shock"], false, true) then
                ni.spell.cast(spellIDs["Holy Shock"], ni.members[i].guid)
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
		local hasInfusionOfLight = ni.unit.buff("player", spellIDs["Infusion of Light"], "exact")
		for i = 1, #ni.members do
			if (not isMoving or hasInfusionOfLight) and ni.members[i]:hp() <= values["Flash of LightThreshold"] and ucheck() and ni.spell.available(spellIDs["Flash of Light"]) and ni.members[i]:valid(spellIDs["Flash of Light"], false, true) then
				ni.spell.cast(spellIDs["Flash of Light"], ni.members[i].guid)
				print("Flash of Light")
				return true
			end
		end
		return false
	end,

    -- Sacred Shield
    -- Casts Sacred Shield on the player if they do not already have the Sacred Shield buff.
    ["Sacred Shield"] = function()
		if not ni.unit.buff("player", spellIDs["Sacred Shield"], "exact") and ucheck("player", spellIDs["Sacred Shield"]) and ni.spell.available(spellIDs["Sacred Shield"]) then
            ni.spell.cast(spellIDs["Sacred Shield"], "player")
            print("Sacred Shield")
			return true
        end
        return false
    end,

    -- Beacon of Light
    -- Casts Beacon of Light on the player if they do not already have the Beacon of Light buff.
    ["Beacon of Light"] = function()
        if not ni.unit.buff("player", spellIDs["Beacon of Light"], "exact") and ucheck("player", spellIDs["Beacon of Light"]) and ni.spell.available(spellIDs["Beacon of Light"]) then
            ni.spell.cast(spellIDs["Beacon of Light"], "player")
			print("Beacon of Light")
            return true
        end
        return false
    end,

    -- Blessing of Kings
    -- If we do not have Blessing of Kings buff, buff self
    -- If we have Greater of Blessing of Kings, do not override buff by cast Blessing of Kings
    ["Blessing of Kings"] = function()
        local hasGreaterBlessing = ni.unit.buff("player", spellIDs["Greater Blessing of Kings"])
        local hasBlessing = ni.unit.buff("player", spellIDs["Blessing of Kings"])
        if not hasBlessing and not hasGreaterBlessing and ucheck("player", spellIDs["Blessing of Kings"]) and ni.spell.available(spellIDs["Blessing of Kings"]) then
            ni.spell.cast(spellIDs["Blessing of Kings"], "player")
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
