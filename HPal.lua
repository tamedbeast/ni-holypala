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
    "Cleanse",
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
local dispellableDebuffs = {
    "Concussive Shot", -- Hunter ability
    "Wing Clip", -- Hunter ability
    "Hamstring", -- Warrior ability
    "Improved Hamstring", -- Warrior ability
    "Frost Shock", -- Shaman ability
    "Crippling Poison", -- Rogue ability
    "Frostbolt", -- Mage ability
    "Frost Nova", -- Mage ability
    "Chilled", -- Effect from various Frost spells, primarily Mage abilities
    "Slow", -- Mage ability
    "Deadly Throw", -- Rogue ability
    "Frostbrand Attack" -- Shaman ability
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

-- Function to cast a spell if the conditions are met
local function spellCast(spellID, target)
    if ucheck(target, spellID) then
        ni.spell.cast(spellID, target)
    end
end

local function canDispel(unit)
    for i = 1, #dispellableDebuffs do
        if ni.unit.debuff(unit, dispellableDebuffs[i]) then
            return true
        end
    end
    return false
end
local function losCheck()
    for i = 1, #ni.members do
        if ni.members[i]:los() then
            return true
        end
    end
    return false
end

-- Function to find the lowest ally to be healed
local function healAlly()
    local lowestHealthPercent = 100
    local lowestHealthMember = nil

    for i = 1, #ni.members do
        local healthPercent = ni.members[i]:hp()

        if healthPercent < lowestHealthPercent then
            lowestHealthPercent = healthPercent
            lowestHealthMember = ni.members[i].guid
        end
    end

    return lowestHealthMember
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

-- Function to find the lowest ally to be healed
local function healAlly()
    local lowestHealthPercent = 100
    local lowestHealthMember = nil

    for i = 1, #ni.members do
        local healthPercent = ni.members[i]:hp()

        if healthPercent < lowestHealthPercent then
            lowestHealthPercent = healthPercent
            lowestHealthMember = ni.members[i].guid
        end
    end

    return lowestHealthMember
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
                ni.spell.stopcasting()
                spellCast(spellID, "player")
            end
        end
    end,

    ["Hand of Protection"] = function()
        -- Cast Hand of Protection on the ally with 40% hp or less if it's off cooldown, line of sight is available, and ucheck passes
        local spellID = spellIDs["Hand of Protection"]
        if spellID then
            local threshold = values["Hand of ProtectionThreshold"]
            local lowHealthMember = healAlly()
            if lowHealthMember and ni.spell.available(spellID) and losCheck() then
                ni.spell.stopcasting()
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
                ni.spell.stopcasting()
                spellCast(spellID, "player")
            end
        end
    end,

    ["Lay on Hands"] = function()
        -- Cast Lay on Hands on the ally with the lowest health if they have 25% hp or less, it's off cooldown, you don't have the "Forbearance" debuff, and ucheck passes
        local spellID = spellIDs["Lay on Hands"]
        if spellID then
            local threshold = values["Lay on HandsThreshold"]
            local lowHealthMember = healAlly()
            local hasForbearance = ni.unit.debuff("player", spellIDs["Forbearance"], "exact")
            if lowHealthMember and ni.spell.available(spellID) and not hasForbearance then
                ni.spell.stopcasting()
                spellCast(spellID, lowHealthMember)
            end
        end
    end,

    ["Divine Sacrifice"] = function()
        -- Cast Divine Sacrifice on an ally if they have 75% hp or less and ucheck passes
        local spellID = spellIDs["Divine Sacrifice"]
        if spellID then
            local threshold = values["Divine SacrificeThreshold"]
            local lowHealthMember = healAlly()
            if lowHealthMember and ni.spell.available(spellID) then
                spellCast(spellID, lowHealthMember)
            end
        end
    end,

    ["Divine Favor"] = function()
        -- Cast Divine Favor on the ally with the lowest health if they have 25% hp or lower, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Divine Favor"]
        if spellID then
            local threshold = values["Divine FavorThreshold"]
            local lowHealthMember = healAlly()
            if lowHealthMember and ni.spell.available(spellID) then
                spellCast(spellID, lowHealthMember)
            end
        end
    end,

    ["Use Healthstone"] = function()
        -- Use Healthstone when your health reaches 20% or less and ucheck passes
        local spellID = spellIDs["Fel Healthstone"]
        if spellID then
            if ni.unit.hp("player") <= 20 and ucheck("player", spellID) then
                ni.player.useitem(spellID)
            end
        end
    end,

    ["Hammer of Wrath"] = function()
        -- Stop casting and cast Hammer of Wrath on an enemy that is within 30 yards, has 20% health or lower, and ucheck passes
        local spellID = spellIDs["Hammer of Wrath"]
        if spellID then
            local threshold = values["Hammer of WrathThreshold"]
            local target = tarEnemy(30) -- Set the range to 30 yards
            if target and ni.unit.hp(target) <= threshold and ni.spell.available(spellID) then
                ni.spell.stopcasting()
                spellCast(spellID, target)
            end
        end
    end,

    ["Hammer of Justice"] = function()
        -- Target an enemy within 10 yards and cast Hammer of Justice if the enemy is casting a spell and ucheck passes
        local spellID = spellIDs["Hammer of Justice"]
        if spellID then
            local target = tarEnemy(10) -- Set the range to 10 yards
            if target and ni.unit.iscasting(target) and ni.spell.available(spellID) then
                ni.spell.stopcasting()
				spellCast(spellID, target)
            end
        end
    end,

    ["Hand of Freedom"] = function()
        -- Cast Hand of Freedom on yourself or an ally if they have 65% hp or less, have a Snare debuff, and ucheck passes
        local spellID = spellIDs["Hand of Freedom"]
        if spellID then
            local threshold = values["Hand of FreedomThreshold"]
            local lowHealthMember = healAlly()
            if lowHealthMember and ni.spell.available(spellID) and ni.unit.debufftype(lowHealthMember, "Snare") then
                spellCast(spellID, lowHealthMember)
            end
        end
    end,

    ["Cleanse"] = function()
        -- Cast Cleanse on the ally with the lowest health if they have a debuff that requires dispelling
        local spellID = spellIDs["Cleanse"]
        if spellID then
            local lowHealthMember = healAlly()
            if lowHealthMember and canDispel(lowHealthMember) and ni.spell.available(spellID) then
                spellCast(spellID, lowHealthMember)
            else
                for i = 1, #ni.members do
                    if canDispel(ni.members[i].guid) then
                        spellCast(spellID, ni.members[i].guid)
                        break
                    end
                end
            end
        end
    end,

    ["Holy Shock"] = function()
        -- Cast Holy Shock on the ally with the lowest health if they have 88% hp or lower, it's off cooldown, and ucheck passes
        local spellID = spellIDs["Holy Shock"]
        if spellID then
            local threshold = values["Holy ShockThreshold"]
            local lowHealthMember = healAlly()
            if lowHealthMember and ni.spell.available(spellID) then
                spellCast(spellID, lowHealthMember)
            end
        end
    end,

    ["Flash of Light"] = function()
        -- Cast Flash of Light on the ally with the lowest health if they have 88% hp or lower, it's off cooldown, and the player is either not moving or has the Infusion of Light buff.
        -- If the player does not have the Infusion of Light buff, they must have been stationary for at least 0.1 seconds before the spell is cast.
        local spellID = spellIDs["Flash of Light"]
        local infusionOfLightID = spellIDs["Infusion of Light"]
        if spellID then
            local threshold = values["Flash of LightThreshold"]
            local lowHealthMember = healAlly()
            local isMoving = ni.player.movingfor(0.1)
            local hasInfusionOfLight = ni.unit.buff("player", infusionOfLightID, "exact")
            if lowHealthMember and ni.spell.available(spellID) and (not isMoving or hasInfusionOfLight) then
                spellCast(spellID, lowHealthMember)
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
		-- Do not cast Blessing of Kings if we have Greater Blessing of Kings already, it's off cooldown, and ucheck passes
		-- Cast Blessing of Kings on yourself as self-buff if Greater Blessing of Kings is not active, it's off cooldown, and ucheck passes
		local greaterBlessingID = spellIDs["Greater Blessing of Kings"]
		local hasGreaterBlessing = ni.unit.buff("player", greaterBlessingID, "exact")
		
		local spellID = spellIDs["Blessing of Kings"]
		if spellID and greaterBlessingID and not hasGreaterBlessing and ni.spell.available(spellID) then
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
