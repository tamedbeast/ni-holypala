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

local values = {
    ["Aura MasteryThreshold"] = 65,
    ["Divine IlluminationThreshold"] = 65,
    ["Divine ShieldThreshold"] = 35,
    ["Hand of ProtectionThreshold"] = 40,
    ["Divine ProtectionThreshold"] = 40,
    ["Lay on HandsThreshold"] = 25,
    ["Divine SacrificeThreshold"] = 75,
    ["Divine FavorThreshold"] = 25,
    ["Hand of FreedomThreshold"] = 65,
    ["Holy ShockThreshold"] = 88,
    ["Flash of LightThreshold"] = 88,
    ["Seal of WisdomThreshold"] = 35,
    ["Seal of LightThreshold"] = 70,
}

local enables = {}
local spellIDs = {}

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

-- Assign spell IDs to spell names
for _, spellName in ipairs(queue) do
    spellIDs[spellName] = GetSpellIdByName(spellName)
end

-- Function to check if the player is eligible to cast a spell
local function ucheck(target, spell)
    return not IsMounted() and not UnitInVehicle("player") and not UnitIsDeadOrGhost("player")
        and not UnitChannelInfo("player") and not UnitCastingInfo("player")
end

-- Function to cast a spell if the conditions are met, including line of sight check
local function spellCast(spellID, target)
    local hasLOS, _, _, _, _, _, x, y, z = ni.unit.los("player", target)

    if hasLOS then
        if ucheck(target, spellID) then
            ni.spell.cast(spellID, target)
        end
    else
        -- Handle the case when line of sight is obstructed
        -- You can perform actions or adjustments here if needed
    end
end


-- Ability functions
local abilities = {
    ["Aura Mastery"] = function()
        -- Cast Aura Mastery if you or an ally have 65% hp or less, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Aura Mastery"]
        if spellID then
            local threshold = values["Aura MasteryThreshold"]
            if ni.unit.hp("player") <= threshold and ni.spell.available(spellID) then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Divine Illumination"] = function()
        -- Cast Divine Illumination if you have 65% mana or less, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Divine Illumination"]
        if spellID then
            local threshold = values["Divine IlluminationThreshold"]
            if ni.unit.power("player", "percent") <= threshold and ni.spell.available(spellID) then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Divine Shield"] = function()
        -- Cast Divine Shield if you have 35% hp or less, it's off cooldown, you don't have the "Forbearance" debuff, and ucheck passes
        local spellID = spellIDs["Divine Shield"]
        if spellID then
            local threshold = values["Divine ShieldThreshold"]
            local hasForbearance = ni.unit.debuff("player", spellIDs["Forbearance"], "exact")
            if ni.unit.hp("player") <= threshold and ni.spell.available(spellID) and not hasForbearance then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Hand of Protection"] = function()
        -- Cast Hand of Protection on the ally with 40% hp or less if it's off cooldown and ucheck passes
        local spellID = spellIDs["Hand of Protection"]
        if spellID then
            local threshold = values["Hand of ProtectionThreshold"]
            local lowHealthMember = ni.unit.hp("lowest") <= threshold
            if lowHealthMember and ni.spell.available(spellID) then
                spellCast(spellID, lowHealthMember)
            end
        end
    end,

    ["Divine Protection"] = function()
        -- Cast Divine Protection if you have 40% hp or less, Divine Shield is on cooldown, and ucheck passes
        local spellID = spellIDs["Divine Protection"]
        if spellID then
            local threshold = values["Divine ProtectionThreshold"]
            if ni.unit.hp("player") <= threshold and not ni.spell.available(spellIDs["Divine Shield"]) then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Lay on Hands"] = function()
        -- Cast Lay on Hands if you have 25% hp or less, it's off cooldown, you don't have the "Forbearance" debuff, and ucheck passes
        local spellID = spellIDs["Lay on Hands"]
        if spellID then
            local threshold = values["Lay on HandsThreshold"]
            local hasForbearance = ni.unit.debuff("player", spellIDs["Forbearance"], "exact")
            if ni.unit.hp("player") <= threshold and ni.spell.available(spellID) and not hasForbearance then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Divine Sacrifice"] = function()
        -- Cast Divine Sacrifice on an ally if they have 75% hp or less and ucheck passes
        local spellID = spellIDs["Divine Sacrifice"]
        if spellID then
            local threshold = values["Divine SacrificeThreshold"]
            local lowHealthMember = ni.unit.hp("lowest") <= threshold
            if lowHealthMember and ni.spell.available(spellID) then
                spellCast(spellID, lowHealthMember)
            end
        end
    end,

    ["Divine Favor"] = function()
        -- Cast Divine Favor if you or an ally has 25% hp or lower, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Divine Favor"]
        if spellID then
            local threshold = values["Divine FavorThreshold"]
            if ni.unit.hp("player") <= threshold and ni.spell.available(spellID) then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Use Healthstone"] = function()
        -- Use Healthstone when your health reaches 20% or less and ucheck passes
        local spellID = spellIDs["Use Healthstone"]
        if spellID then
            if ni.unit.hp("player") <= 20 and ucheck("player", spellID) then
                ni.player.useitem(spellID)
            end
        end
    end,

    ["Hammer of Wrath"] = function()
        -- Stop casting and cast Hammer of Wrath on the enemy that is in range and has 20% hp or lower and ucheck passes
        local spellID = spellIDs["Hammer of Wrath"]
        if spellID then
            if ni.unit.hp("target") <= 20 and ni.spell.available(spellID) then
                ni.spell.stopcasting()
                spellCast(spellID, "target")
            end
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
                spellCast(spellIDs["Hammer of Justice"], target)
                break -- Exit the loop after casting on the first eligible enemy found
            end
        end
    end,

    ["Hand of Freedom"] = function()
        -- Cast Hand of Freedom on yourself or an ally if they have 65% hp or less, have a Snare debuff, and ucheck passes
        local spellID = spellIDs["Hand of Freedom"]
        if spellID then
            local threshold = values["Hand of FreedomThreshold"]
            local lowHealthMember = ni.unit.hp("lowest") <= threshold
            if lowHealthMember and ni.spell.available(spellID) and ni.unit.debufftype(lowHealthMember, "Snare") then
                spellCast(spellID, lowHealthMember)
            end
        end
    end,

    ["Cleanse"] = function()
        -- Cast Cleanse on yourself if you have 60% mana or more and there is a debuff that requires dispelling
        -- Iterate through each ally and cast Cleanse on the first eligible ally found 
        local spellID = spellIDs["Cleanse"]
        if spellID then
            if ni.unit.power("player", "percent") >= 60 and ni.healing.candispel("player") then
                spellCast(spellID, "player")
            else
                for i = 1, #ni.members do
                    if ni.unit.power(ni.members[i].guid, "percent") >= 60 and ni.healing.candispel(ni.members[i].guid) then
                        spellCast(spellID, ni.members[i].guid)
                        break
                    end
                end
            end
        end
    end,

    ["Holy Shock"] = function()
        -- Cast Holy Shock on yourself or an ally if they have 88% hp or lower, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Holy Shock"]
        if spellID then
            local threshold = values["Holy ShockThreshold"]
            if ni.unit.hp("player") <= threshold and ni.spell.available(spellID) then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Flash of Light"] = function()
        -- Cast Flash of Light on yourself or an ally if they have 88% hp or lower, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Flash of Light"]
        if spellID then
            local threshold = values["Flash of LightThreshold"]
            if ni.unit.hp("player") <= threshold and ni.spell.available(spellID) then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Sacred Shield"] = function()
        -- Cast Sacred Shield on yourself if you don't have the buff, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Sacred Shield"]
        if spellID then
            if not ni.unit.buff("player", spellID, "exact") and ni.spell.available(spellID) then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Beacon of Light"] = function()
        -- Cast Beacon of Light on yourself if you don't have the buff, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Beacon of Light"]
        if spellID then
            if not ni.unit.buff("player", spellID, "exact") and ni.spell.available(spellID) then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Blessing of Kings"] = function()
        -- Cast Blessing of Kings on yourself if you don't have the buff or if we don't have the Greater Blessing of Kings buff, it's off cooldown, and ucheck passes
		local spellID = spellIDs["Blessing of Kings"]
		local greaterBlessingID = spellIDs["Greater Blessing of Kings"]
		local hasBlessing = ni.unit.buff("player", spellID, "exact")
		local hasGreaterBlessing = ni.unit.buff("player", greaterBlessingID, "exact")
		local isSpellAvailable = ni.spell.available(spellID)
		if spellID and greaterBlessingID and not (hasBlessing or hasGreaterBlessing) and isSpellAvailable then
			spellCast(spellID, "player")
		end
	end,


    ["Seal of Wisdom"] = function()
        -- Cast Seal of Wisdom on yourself if you have 35% mana or less, it's not already active, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Seal of Wisdom"]
        if spellID then
            local threshold = values["Seal of WisdomThreshold"]
            if ni.unit.power("player", "percent") <= threshold and not ni.unit.buff("player", spellID, "exact") and ni.spell.available(spellID) then
                spellCast(spellID, "player")
            end
        end
    end,

    ["Seal of Light"] = function()
        -- Cast Seal of Light on yourself if you have 70% mana or more, it's not already active, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Seal of Light"]
        if spellID then
            local threshold = values["Seal of LightThreshold"]
            if ni.unit.power("player", "percent") >= threshold and not ni.unit.buff("player", spellID, "exact") and ni.spell.available(spellID) then
                spellCast(spellID, "player")
            end
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
