local queue = {
    "Aura Mastery",
    "Divine Illumination",
    "Divine Shield",
    "Hand of Protection",
    "Divine Protection",
    "Lay on Hands",
    "Divine Sacrifice",
    "Hand of Sacrifice",
    "Divine Favor",
    "Use Healthstone",
    "Hammer of Wrath",
    "Hammer of Justice",
    "Hand of Freedom",
    --"Cleanse",
    "Holy Shock",
    "Flash of Light",
    "Sacred Shield",
    "Beacon of Light",
    "Blessing of Kings",
    "Seal of Wisdom",
    "Seal of Light",
}

local values = {}
local enables = {}
local spellIDs = {}

local function GetSpellIdByName(spellName)
    if not spellName then return end
    local spellLink = GetSpellLink(spellName)
    if spellLink then
        return tonumber(spellLink:match("spell:(%d+)"))
    end
    return nil
end

for _, spellName in ipairs(queue) do
    spellIDs[spellName] = GetSpellIdByName(spellName)
end

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

local function getLowestHealthAlly()
    local lowestHealth = 100
    local lowestHealthAlly = nil
    for i = 1, #ni.members do
        local memberHealth = ni.members[i]:hp()
        if memberHealth < lowestHealth then
            lowestHealth = memberHealth
            lowestHealthAlly = ni.members[i]
        end
    end
    return lowestHealthAlly
end

-- Universal Checker
local function ucheck(target, spell)
    local inRange = ni.spell.inrange(spell, target)
    local inLOS = ni.unit.lineofsight("player", target)
    return not IsMounted()
        and not UnitInVehicle("player")
        and not UnitIsDeadOrGhost("player")
        and not UnitChannelInfo("player")
        and not UnitCastingInfo("player")
        and not ni.player.islooting()
        and inRange
        and inLOS
end

local abilities = {
    ["Aura Mastery"] = function()
        -- Cast Aura Mastery if you or an ally have 65% hp or less, it's off cooldown, and ucheck passes
        if ni.unit.hp("player") <= 65 and ni.spell.available(spellIDs["Aura Mastery"]) and ucheck("player", spellIDs["Aura Mastery"]) then
            ni.spell.cast(spellIDs["Aura Mastery"])
        end
    end,
    ["Divine Illumination"] = function()
        -- Cast Divine Illumination if you have 65% mana or less, it's off cooldown, and ucheck passes
        if ni.unit.power("player", "percent") <= 65 and ni.spell.available(spellIDs["Divine Illumination"]) and ucheck("player", spellIDs["Divine Illumination"]) then
            ni.spell.cast(spellIDs["Divine Illumination"])
        end
    end,
    ["Divine Shield"] = function()
        -- Cast Divine Shield if you have 35% hp or less, it's off cooldown, you don't have the "Forbearance" debuff, and ucheck passes
        if ni.unit.hp("player") <= 35 and ni.spell.available(spellIDs["Divine Shield"]) and not ni.unit.debuff("player", spellIDs["Forbearance"], "exact") and ucheck("player", spellIDs["Divine Shield"]) then
            ni.spell.cast(spellIDs["Divine Shield"])
        end
    end,
    ["Hand of Protection"] = function()
        -- Cast Hand of Protection on the ally with 40% hp or less if it's off cooldown and ucheck passes
        local lowHealthMember = ni.unit.hp("lowest") <= 40
        if lowHealthMember and ni.spell.available(spellIDs["Hand of Protection"]) and ucheck(lowHealthMember, spellIDs["Hand of Protection"]) then
            ni.spell.cast(spellIDs["Hand of Protection"], lowHealthMember)
        end
    end,
    ["Divine Protection"] = function()
        -- Cast Divine Protection if you have 40% hp or less, Divine Shield is on cooldown, and ucheck passes
        if ni.unit.hp("player") <= 40 and not ni.spell.available(spellIDs["Divine Shield"]) and ucheck("player", spellIDs["Divine Protection"]) then
            ni.spell.cast(spellIDs["Divine Protection"])
        end
    end,
    ["Lay on Hands"] = function()
        -- Check if you have the "Forbearance" debuff
        local hasForbearance = ni.unit.debuff("player", spellIDs["Forbearance"], "exact")

        -- Cast Lay on Hands if you have 25% hp or less, it's off cooldown, you don't have the "Forbearance" debuff, and ucheck passes
        if ni.unit.hp("player") <= 25 and ni.spell.available(spellIDs["Lay on Hands"]) and not hasForbearance and ucheck("player", spellIDs["Lay on Hands"]) then
            ni.spell.cast(spellIDs["Lay on Hands"])
        end
    end,
		["Divine Sacrifice"] = function()
		-- Cast Divine Sacrifice on an ally if they have 75% hp or less and ucheck passes
		local lowHealthMember = ni.unit.hp("lowest") <= 75
		if lowHealthMember and ni.spell.available(spellIDs["Divine Sacrifice"]) and ucheck(lowHealthMember, spellIDs["Divine Sacrifice"]) then
			ni.spell.cast(spellIDs["Divine Sacrifice"], lowHealthMember)
		end
	end,
    ["Divine Favor"] = function()
        -- Cast Divine Favor if you or an ally has 25% hp or lower, it's off cooldown, and ucheck passes
        if ni.unit.hp("player") <= 25 and ni.spell.available(spellIDs["Divine Favor"]) and ucheck("player", spellIDs["Divine Favor"]) then
            ni.spell.cast(spellIDs["Divine Favor"])
        end
    end,
    ["Use Healthstone"] = function()
        -- Use Healthstone when our health reaches 20% or less and ucheck passes
        if ni.unit.hp("player") <= 20 and ucheck("player", 36892) then -- Replace 36892 with the correct item ID for the Healthstone
            ni.player.useitem(36892)
        end
    end,
    ["Hammer of Wrath"] = function()
        -- Stop casting and cast Hammer of Wrath on the enemy that is in range and has 20% hp or lower and ucheck passes
        if ni.unit.hp("target") <= 20 and ni.spell.available(spellIDs["Hammer of Wrath"]) and ucheck("target", spellIDs["Hammer of Wrath"]) then
            ni.spell.stopcasting()
            ni.spell.cast(spellIDs["Hammer of Wrath"], "target")
        end
    end,
    ["Hammer of Justice"] = function()
        -- Get all enemies within a specified range
        local enemies = ni.unit.enemiesinrange("player", 10) -- Set the range to 10 yards

        -- Iterate through each enemy
        for i = 1, #enemies do
            local target = enemies[i].guid
            local name = enemies[i].name
            local distance = enemies[i].distance

            -- Check if the enemy is casting a spell and within range
            if ni.unit.iscasting(target) and distance <= 10 and ucheck(target, spellIDs["Hammer of Justice"]) then
                -- Cast Hammer of Justice on the enemy
                ni.spell.cast(spellIDs["Hammer of Justice"], target)
                break -- Exit the loop after casting on the first eligible enemy found
            end
        end
    end,
    ["Hand of Freedom"] = function()
        -- Cast Hand of Freedom on yourself or an ally if they have 65% hp or less, have a debuff that Hand of Freedom can remove, and ucheck passes
        local lowHealthMember = ni.unit.hp("lowest") <= 65
        if lowHealthMember and ni.spell.available(spellIDs["Hand of Freedom"]) and ni.unit.debufftype(lowHealthMember, "Snare") and ucheck(lowHealthMember, spellIDs["Hand of Freedom"]) then
            ni.spell.cast(spellIDs["Hand of Freedom"], lowHealthMember)
        end
    end,
		["Cleanse"] = function()
		-- Check if you have 60% mana or more and there is a debuff that requires dispelling
		if ni.unit.power("player", "percent") >= 60 and ni.healing.candispel("player") and ucheck("player", spellIDs["Cleanse"]) then
			-- Cast Cleanse on yourself
			ni.spell.cast(spellIDs["Cleanse"], "player")
		else
			-- Iterate through each ally
			for i = 1, #ni.members do
				-- Check if the ally has 60% mana or more and there is a debuff that requires dispelling
				if ni.unit.power(ni.members[i].guid, "percent") >= 60 and ni.healing.candispel(ni.members[i].guid) and ucheck(ni.members[i].guid, spellIDs["Cleanse"]) then
					-- Cast Cleanse on the ally
					ni.spell.cast(spellIDs["Cleanse"], ni.members[i].guid)
					break -- Exit the loop after casting on the first eligible ally found
				end
			end
		end
	end,
    ["Holy Shock"] = function()
        -- Cast Holy Shock on yourself or an ally if they have 88% hp or lower, it's off cooldown, and ucheck passes
        if ni.unit.hp("player") <= 88 and ni.spell.available(spellIDs["Holy Shock"]) and ucheck("player", spellIDs["Holy Shock"]) then
            ni.spell.cast(spellIDs["Holy Shock"], "player")
        end
    end,
    ["Flash of Light"] = function()
        -- Cast Flash of Light on yourself or an ally if they have 88% hp or lower, it's off cooldown, and ucheck passes
        if ni.unit.hp("player") <= 88 and ni.spell.available(spellIDs["Flash of Light"]) and ucheck("player", spellIDs["Flash of Light"]) then
            ni.spell.cast(spellIDs["Flash of Light"], "player")
        end
    end,
    ["Sacred Shield"] = function()
        -- Cast Sacred Shield on yourself if you don't have the buff, it's off cooldown, and ucheck passes
        if not ni.unit.buff("player", spellIDs["Sacred Shield"], "exact") and ni.spell.available(spellIDs["Sacred Shield"]) and ucheck("player", spellIDs["Sacred Shield"]) then
            ni.spell.cast(spellIDs["Sacred Shield"], "player")
        end
    end,
    ["Beacon of Light"] = function()
        -- Cast Beacon of Light on yourself if you don't have the buff, it's off cooldown, and ucheck passes
        if not ni.unit.buff("player", spellIDs["Beacon of Light"], "exact") and ni.spell.available(spellIDs["Beacon of Light"]) and ucheck("player", spellIDs["Beacon of Light"]) then
            ni.spell.cast(spellIDs["Beacon of Light"], "player")
        end
    end,
    ["Blessing of Kings"] = function()
		-- Cast Blessing of Kings on yourself if you don't have the buff or if we don't have the Greater Blessing of Kings buff, it's off cooldown, and ucheck passes
		local blessingOfKingsId = spellIDs["Blessing of Kings"]
		local greaterBlessingOfKingsId = spellIDs["Greater Blessing of Kings"]
		if not blessingOfKingsId or not greaterBlessingOfKingsId then
			--print("Could not find spell ID for Blessing of Kings or Greater Blessing of Kings.")
		end
		if not ni.unit.buff("player", blessingOfKingsId, "exact") and not ni.unit.buff("player", greaterBlessingOfKingsId, "exact") and ni.spell.available(blessingOfKingsId) and ucheck("player", blessingOfKingsId) then
			ni.spell.cast(blessingOfKingsId, "player")
		end
	end,
    ["Seal of Wisdom"] = function()
        -- Cast Seal of Wisdom on yourself if you have 35% mana or less, it's not already active, it's off cooldown, and ucheck passes
        if ni.unit.power("player", "percent") <= 35 and not ni.unit.buff("player", spellIDs["Seal of Wisdom"], "exact") and ni.spell.available(spellIDs["Seal of Wisdom"]) and ucheck("player", spellIDs["Seal of Wisdom"]) then
            ni.spell.cast(spellIDs["Seal of Wisdom"], "player")
        end
    end,
    ["Seal of Light"] = function()
        -- Cast Seal of Light on yourself if you have 70% mana or more, it's not already active, it's off cooldown, and ucheck passes
        if ni.unit.power("player", "percent") >= 70 and not ni.unit.buff("player", spellIDs["Seal of Light"], "exact") and ni.spell.available(spellIDs["Seal of Light"]) and ucheck("player", spellIDs["Seal of Light"]) then
            ni.spell.cast(spellIDs["Seal of Light"], "player")
        end
    end,
}


local function OnLoad()
    ni.GUI.AddFrame("HPal", items)
end

local function OnUnLoad()
    ni.GUI.DestroyFrame("HPal")
end

ni.bootstrap.profile("HPal", queue, abilities, OnLoad, OnUnLoad)
