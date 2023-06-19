local queue = {
    "layOnHands",
    "divineShield",
    "handOfProtection",
    "auraMastery",
    "divineIllumination",
    "divineFavor",
    "holyShock",
    "flashOfLight",
    "beaconOfLight",
    "sacredShield",
    "blessingOfKings",
    "handOfFreedom",
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
    beaconOfLight = 53563,
    sacredShield = 53601,
    blessingOfKings = 20217,
    handOfFreedom = 1044,
}

local values = {
    holyShockThreshold = 88,
    flashOfLightThreshold = 88,
    divineFavorThreshold = 75,
    auraMasteryThreshold = 65,
    divineIlluminationThreshold = 65,
    divineShieldThreshold = 35,
    handOfProtectionThreshold = 40,
    layOnHandsThreshold = 25,
}

local enables = {
    layOnHands = true,
    holyShock = true,
    flashOfLight = true,
    divineFavor = true,
    auraMastery = true,
    divineIllumination = true,
    divineShield = true,
    handOfProtection = true,
    beaconOfLight = true,
    sacredShield = true,
    blessingOfKings = true,
    handOfFreedom = true,
}

local function GUICallback(key, item_type, value)
    if item_type == "enabled" then
        if enables[key] ~= nil then
            enables[key] = value
        end
    elseif item_type == "value" then
        if values[key] ~= nil then
            values[key] = value
        end
    end
end

local items = {
    callback = GUICallback,
    { type = "title", text = "Holy Paladin PvP Profile" },
    { type = "separator" },
    { type = "entry", text = "Holy Shock", value = values.holyShockThreshold, min = 0, max = 100, step = 1, key = "holyShockThreshold" },
    { type = "entry", text = "Flash of Light", value = values.flashOfLightThreshold, min = 0, max = 100, step = 1, key = "flashOfLightThreshold" },
    { type = "entry", text = "Divine Favor", value = values.divineFavorThreshold, min = 0, max = 100, step = 1, key = "divineFavorThreshold" },
    { type = "entry", text = "Aura Mastery", value = values.auraMasteryThreshold, min = 0, max = 100, step = 1, key = "auraMasteryThreshold" },
    { type = "entry", text = "Divine Illumination", value = values.divineIlluminationThreshold, min = 0, max = 100, step = 1, key = "divineIlluminationThreshold" },
    { type = "entry", text = "Divine Shield", value = values.divineShieldThreshold, min = 0, max = 100, step = 1, key = "divineShieldThreshold" },
    { type = "entry", text = "Hand of Protection", value = values.handOfProtectionThreshold, min = 0, max = 100, step = 1, key = "handOfProtectionThreshold" },
    { type = "entry", text = "Lay on Hands", value = values.layOnHandsThreshold, min = 0, max = 100, step = 1, key = "layOnHandsThreshold" },
    { type = "separator" },
    { type = "entry", text = "Lay on Hands", enabled = enables.layOnHands, key = "layOnHands" },
    { type = "entry", text = "Holy Shock", enabled = enables.holyShock, key = "holyShock" },
    { type = "entry", text = "Flash of Light", enabled = enables.flashOfLight, key = "flashOfLight" },
    { type = "entry", text = "Divine Favor", enabled = enables.divineFavor, key = "divineFavor" },
    { type = "entry", text = "Aura Mastery", enabled = enables.auraMastery, key = "auraMastery" },
    { type = "entry", text = "Divine Illumination", enabled = enables.divineIllumination, key = "divineIllumination" },
    { type = "entry", text = "Divine Shield", enabled = enables.divineShield, key = "divineShield" },
    { type = "entry", text = "Hand of Protection", enabled = enables.handOfProtection, key = "handOfProtection" },
    { type = "entry", text = "Beacon of Light", enabled = enables.beaconOfLight, key = "beaconOfLight" },
    { type = "entry", text = "Sacred Shield", enabled = enables.sacredShield, key = "sacredShield" },
    { type = "entry", text = "Blessing of Kings", enabled = enables.blessingOfKings, key = "blessingOfKings" },
    { type = "entry", text = "Hand of Freedom", enabled = enables.handOfFreedom, key = "handOfFreedom" },
}


local function OnLoad()
    ni.GUI.AddFrame("HolyPaladin", items)
end

local function OnUnLoad()
    ni.GUI.DestroyFrame("HolyPaladin")
end
local crowdControlDebuffs = {
    "Crippling Poison",
    "Hamstring",
    "Frostbite",
    "Entangling Roots",
    "Frost Nova",
    "Frost Shock"
}

local function hasAnyDebuff(target, debuffList)
    for _, debuffName in ipairs(debuffList) do
        if target.debuff(debuffName) then
            return true
        end
    end
    return false
end

local function castSpell(spell, target, threshold)
    if ni.player.ismounted() or UnitIsDeadOrGhost("player") or not ni.spell.available(spell) or ni.spell.gcd() then
        return
    end

    local forbearance = 25771
    if spell == spells.handOfProtection or spell == spells.divineShield or spell == spells.layOnHands then
        if ni.player.debuff(forbearance) then
            return
        end
    end

    if target == 'player' and ni.player.hp() <= threshold then
        ni.spell.stopcasting()
        ni.spell.cast(spell, 'player')
        return
    end

    for i = 1, #ni.members do
        local ally = ni.members[i]
        if ally:valid(spell, false, true) and ally:los() and ally:hp() <= threshold and (spell ~= spells.flashOfLight or not ni.player.ismoving()) then
            if spell == spells.handOfFreedom and hasAnyDebuff(ally, crowdControlDebuffs) then
                ni.spell.cast(spell, ally.guid)
            elseif spell ~= spells.handOfFreedom then
                ni.spell.cast(spell, ally.guid)
            end
        end
    end
end

local function castSelfBuff(spell)
    if ni.player.ismounted() or UnitIsDeadOrGhost("player") or not ni.spell.available(spell) or ni.spell.gcd() or ni.player.buff(spell) then
        return
    end

    if spell == spells.handOfFreedom and hasAnyDebuff(ni.player, crowdControlDebuffs) then
        ni.spell.cast(spell, "player")
    elseif spell ~= spells.handOfFreedom then
        ni.spell.cast(spell, "player")
    end
end

local abilities = {
    layOnHands = function() if enables.layOnHands then castSpell(spells.layOnHands, 'player', values.layOnHandsThreshold) end end,
    holyShock = function() if enables.holyShock then castSpell(spells.holyShock, 'ally', values.holyShockThreshold) end end,
    flashOfLight = function() if enables.flashOfLight then castSpell(spells.flashOfLight, 'ally', values.flashOfLightThreshold) end end,
    divineFavor = function() if enables.divineFavor then castSpell(spells.divineFavor, 'player', values.divineFavorThreshold) end end,
    auraMastery = function() if enables.auraMastery then castSpell(spells.auraMastery, 'player', values.auraMasteryThreshold) end end,
    divineIllumination = function() if enables.divineIllumination then castSpell(spells.divineIllumination, 'player', values.divineIlluminationThreshold) end end,
    divineShield = function() if enables.divineShield then castSpell(spells.divineShield, 'player', values.divineShieldThreshold) end end,
    handOfProtection = function() if enables.handOfProtection then castSpell(spells.handOfProtection, 'ally', values.handOfProtectionThreshold) end end,
    beaconOfLight = function() if enables.beaconOfLight then castSelfBuff(spells.beaconOfLight) end end,
    sacredShield = function() if enables.sacredShield then castSelfBuff(spells.sacredShield) end end,
    blessingOfKings = function() if enables.blessingOfKings then castSelfBuff(spells.blessingOfKings) end end,
    handOfFreedom = function() if enables.handOfFreedom then castSelfBuff(spells.handOfFreedom) end end,
}

ni.bootstrap.profile("HolyPaladin", queue, abilities, OnLoad, OnUnLoad)
