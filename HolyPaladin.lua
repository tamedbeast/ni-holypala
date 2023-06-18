local enables = {
    ["heal"] = true,
    ["offense"] = true,
}

local values = {
    ["holyShockThreshold"] = 88, -- Set the default threshold for Holy Shock to 88
    ["flashOfLightThreshold"] = 88, -- Set the default threshold for Flash of Light to 88
    ["divineFavorThreshold"] = 25, -- Set the default threshold for Divine Favor to 25
    ["auraMasteryThreshold"] = 65, -- Set the default threshold for Aura Mastery to 65
    ["divineIlluminationThreshold"] = 65, -- Set the default threshold for Divine Illumination to 65
    ["divineShieldThreshold"] = 35, -- Set the default threshold for Divine Shield to 35
    ["handOfProtectionThreshold"] = 40, -- Set the default threshold for Hand of Protection to 40
    ["layOnHandsThreshold"] = 25, -- Adjust the threshold as desired	
}

local spells = {
    layOnHands = 48788,
    holyShock = 48825,
    flashOfLight = 48785,
    divineFavor = 20216,
    auraMastery = 31821,
    divineIllumination = 31842,
    divineShield = 642,
    handOfProtection = 10278,
}

local function GUICallback(key, item_type, value)
    if item_type == "enabled" then
        enables[key] = value
    elseif item_type == "value" then
        values[key] = value
    end
end

local items = {
    callback = GUICallback,
    { type = "title", text = "Holy Paladin PvP Profile" },
    { type = "separator" },
    { type = "entry", text = "Enable Healing", tooltip = "Enable or disable automatic healing", enabled = true, key = "heal" },
    { type = "entry", text = "Aura Mastery Threshold", tooltip = "The health percentage at which to use Aura Mastery", value = 65, min = 0, max = 100, step = 1, key = "auraMasteryThreshold" },
	{ type = "entry", text = "Divine Illumination Threshold", tooltip = "The mana percentage at which to use Divine Illumination", value = 65, min = 0, max = 100, step = 1, key = "divineIlluminationThreshold" },
	{ type = "entry", text = "Divine Shield Threshold", tooltip = "The health percentage at which to use Divine Shield", value = 35, min = 0, max = 100, step = 1, key = "divineShieldThreshold" },
	{ type = "entry", text = "Hand of Protection Threshold", tooltip = "The health percentage at which to use Hand of Protection", value = 40, min = 0, max = 100, step = 1, key = "handOfProtectionThreshold" },
	{ type = "entry", text = "Lay on Hands Threshold", tooltip = "The health percentage at which to use Lay on Hands", value = 10, min = 0, max = 100, step = 1, key = "layOnHandsThreshold" },
    { type = "entry", text = "Divine Favor Threshold", tooltip = "The health percentage at which to use Divine Favor", value = 25, min = 0, max = 100, step = 1, key = "divineFavorThreshold" },
	{ type = "separator" },
	{ type = "entry", text = "Holy Shock Threshold", tooltip = "The health percentage at which to use Holy Shock", value = 88, min = 0, max = 100, step = 1, key = "holyShockThreshold" },
    { type = "entry", text = "Flash of Light Threshold", tooltip = "The health percentage at which to use Flash of Light", value = 88, min = 0, max = 100, step = 1, key = "flashOfLightThreshold" },
    { type = "separator" },
    { type = "entry", text = "Enable Offense", tooltip = "Enable or disable automatic offensive actions", enabled = true, key = "offense" },
}

local function OnLoad()
    ni.GUI.AddFrame("HolyPaladin", items)
end

local function OnUnLoad()
    ni.GUI.DestroyFrame("HolyPaladin")
end

local queue = {
	"auraMastery",
    "divineIllumination",
	"divineShield",
    "handOfProtection",
    "layOnHands",
	"divineFavor",
    "holyShock",
    "flashOfLight",
    "offense",
    "buffs",
}

local abilities = {
    ["layOnHands"] = function()
        if enables["heal"] and ni.player.hp() <= values["layOnHandsThreshold"] and ni.spell.available(spells.layOnHands) and not ni.player.ismounted() and not UnitIsDeadOrGhost("player") then
            ni.spell.stopcasting()
            ni.spell.cast(spells.layOnHands, 'player')
        end
    end,
	
    ["divineShield"] = function()
        if ni.player.hp() <= values["divineShieldThreshold"] and ni.spell.available(spells.divineShield) and not ni.player.ismounted() and not UnitIsDeadOrGhost("player") then
            ni.spell.stopcasting()
            ni.spell.cast(spells.divineShield, 'player')
        end
    end,

    ["handOfProtection"] = function()
        local allBelowThreshold = true
        for i = 1, #ni.members do
            local ally = ni.members[i]
            if ally:hp() > values["handOfProtectionThreshold"] then
                allBelowThreshold = false
                break
            end
        end
        if allBelowThreshold and ni.spell.available(spells.handOfProtection) and not ni.player.ismounted() and not UnitIsDeadOrGhost("player") then
            ni.spell.stopcasting()
            ni.spell.cast(spells.handOfProtection, 'player')
        end
    end,
	
    ["auraMastery"] = function()
        if enables["heal"] and ni.player.hp() <= values["auraMasteryThreshold"] and ni.spell.available(spells.auraMastery) and not ni.player.ismounted() and not UnitIsDeadOrGhost("player") then
            ni.spell.cast(spells.auraMastery, 'player')
        end
    end,

    ["divineIllumination"] = function()
        local power = ni.power.currentraw("player") -- Get current player mana
        if enables["heal"] and power <= (values["divineIlluminationThreshold"] * 10000) and ni.spell.available(spells.divineIllumination) and not ni.player.ismounted() and not UnitIsDeadOrGhost("player") then
            ni.spell.cast(spells.divineIllumination, 'player')
        end
    end,
	
    ["divineFavor"] = function()
        if enables["heal"] and ni.player.hp() <= values["divineFavorThreshold"] and ni.spell.available(spells.divineFavor) and not ni.player.ismounted() and not UnitIsDeadOrGhost("player") then
            ni.spell.cast(spells.divineFavor, 'player')
        end
    end,
	
    ["holyShock"] = function()
        if enables["heal"] and not ni.player.ismounted() and not UnitIsDeadOrGhost("player") then
            for i = 1, #ni.members do
                local ally = ni.members[i]
                if ally:hp() <= values["holyShockThreshold"] and ally:valid(spells.holyShock, false, true) and ni.spell.available(spells.holyShock) and ally:los() then
                    ni.spell.cast(spells.holyShock, ally.guid)
                end
            end
        end
    end,

    ["flashOfLight"] = function()
        if enables["heal"] and not ni.player.ismoving("player") and not ni.player.ismounted() and not UnitIsDeadOrGhost("player") then
            for i = 1, #ni.members do
                local ally = ni.members[i]
                if ally:hp() <= values["flashOfLightThreshold"] and ally:valid(spells.flashOfLight, false, true) and ni.spell.available(spells.flashOfLight) and ally:los() then
                    ni.spell.delaycast(spells.flashOfLight, ally.guid, 0.1)
                end
            end
        end
    end,

    ["offense"] = function()
        -- Add offensive logic here
    end,

    ["buffs"] = function()
        if not ni.player.ismounted() and not UnitIsDeadOrGhost("player") then
            if not ni.player.buff(53563) then
                ni.spell.cast(53563, 'player')
            end
            if not ni.player.buff(53601) then
                ni.spell.cast(53601, 'player')
            end
        end
    end,
}

ni.bootstrap.profile("HolyPaladin", queue, abilities, OnLoad, OnUnLoad)
