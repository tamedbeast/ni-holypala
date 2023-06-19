local GetBuildInfo, select, ipairs, pairs, tonumber, GetSpellInfo, IsUsableSpell, GetTime, UnitAffectingCombat, IsMounted, ni_tanks, UnitInVehicle, UnitIsDeadOrGhost, UnitChannelInfo, UnitCastingInfo = GetBuildInfo, select, ipairs, pairs, tonumber, GetSpellInfo, IsUsableSpell, GetTime, UnitAffectingCombat, IsMounted, ni.tanks, UnitInVehicle, UnitIsDeadOrGhost, UnitChannelInfo, UnitCastingInfo

local queue = {
    "layOnHands",
    "divineShield",
    "handOfProtection",
	"hammerOfWrath",
    "auraMastery",
    "divineIllumination",
    "divineFavor",
    "holyShock",
    "flashOfLight",
    "beaconOfLight",
    "sacredShield",
    "blessingOfKings",
    "handOfFreedom",
	"aura",
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
	crusaderAura = 32223,
    concentrationAura = 19746,
	hammerOfWrath = 10308,
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
	hammerOfWrathThreshold = 10,
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
	hammerOfWrath = true,
}

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
    { type = "entry", text = "Hammer of Wrath", value = values.hammerOfWrathThreshold, min = 0, max = 100, step = 1, key = "hammerOfWrathThreshold" },
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
    { type = "entry", text = "Hammer of Wrath", enabled = enables.hammerOfWrath, key = "hammerOfWrath" },
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

local function OnLoad()
    ni.GUI.AddFrame("HolyPaladin", items)
end

local function OnUnLoad()
    ni.GUI.DestroyFrame("HolyPaladin")
end

local debuffHoF = {
    "Crippling Poison",
    "Hamstring",
    "Frostbite",
    "Entangling Roots",
    "Frost Nova",
    "Frost Shock",
	"Wing Clip",
	"Root",
	"Chains of Ice",
	"Concussive Shot",
	
}

local function castAura()
    if ni.player.ismounted() then
        if not ni.player.buff(spells.crusaderAura) then
            ni.spell.cast(spells.crusaderAura)
        end
    else
        if not ni.player.buff(spells.concentrationAura) then
            ni.spell.cast(spells.concentrationAura)
        end
    end
end

local function hasAnyDebuff(target, debuffList)
    for _, debuffName in ipairs(debuffList) do
        if target.debuff(debuffName) then
            return true
        end
    end
    return false
end

local function UCheck(spell)
    return not IsMounted()
        and not UnitInVehicle("player")
        and not UnitIsDeadOrGhost("player")
        and not UnitChannelInfo("player")
        and not UnitCastingInfo("player")
        and not ni.player.islooting()
        and ni.spell.available(spell)
end

local function castSpellBuff(spell)
    local spellName = nil
    for k, v in pairs(spells) do
        if v == spell then
            spellName = k
            break
        end
    end
    if spellName and UCheck(spell) and enables[spellName] and ni.spell.available(spell) and not ni.player.buff(spell) then
        if spell == spells.handOfFreedom and hasAnyDebuff(ni.player, debuffHoF) then
            ni.spell.cast(spell, "player")
        elseif spell ~= spells.handOfFreedom then
            ni.spell.cast(spell, "player")
        end
    end
end

local function castSpell(spell, target, threshold)
    if not UCheck(spell) then
        return
    end

    if target == 'player' and ni.player.hp() <= threshold then
        ni.spell.stopcasting()
        ni.spell.cast(spell, 'player')
        return
    end

    for i = 1, #ni.members do
        local ally = ni.members[i]
        if ally:valid(spell, false, true) and ally:los() and ally:hp() <= threshold and (spell ~= spells.flashOfLight or not ni.player.ismoving()) then
            if spell == spells.handOfFreedom and hasAnyDebuff(ally, debuffHoF) and ally.ismoving() then
                ni.spell.cast(spell, ally.guid)
            elseif spell ~= spells.handOfFreedom then
                ni.spell.cast(spell, ally.guid)
            end
        end
    end
end

local function castSpellWithDebuffCheck(spell, target, threshold)
    if not UCheck(spell) then
        return
    end

    if target == 'player' and ni.player.hp() <= threshold then
        ni.spell.stopcasting()
        ni.spell.cast(spell, 'player')
        return
    end

    for i = 1, #ni.members do
        local ally = ni.members[i]
        if ally:valid(spell, false, true) and ally:los() and ally:hp() <= threshold and (spell ~= spells.flashOfLight or not ni.player.ismoving()) then
            if spell == spells.handOfFreedom and hasAnyDebuff(ally, debuffHoF) then
                ni.spell.cast(spell, ally.guid)
            elseif spell ~= spells.handOfFreedom then
                ni.spell.cast(spell, ally.guid)
            end
        end
    end
end

local function emergencyCast(spell, target, threshold)
    if not UCheck(spell) then
        return
    end

    if target == 'player' and ni.player.hp() <= threshold and ni.player.combat() then
        ni.spell.stopcasting()
        ni.spell.cast(spell, 'player')
        return
    end

    for i = 1, #ni.members do
        local ally = ni.members[i]
        if ally:valid(spell, false, true) and ally:los() and ally:hp() <= threshold and (spell ~= spells.flashOfLight or not ni.player.ismoving()) then
            ni.spell.cast(spell, ally.guid)
        end
    end
end

local function findLowestEnemyPlayerInRange()
    local lowestHealth = 101
    local lowestEnemy = nil

    if ni.enemies then
        for i = 1, #ni.enemies do
            local enemy = ni.enemies[i]
            if enemy.player and enemy.health and enemy.health.percent() <= 10 and ni.player.distance(enemy) <= 30 then
                if enemy.health.percent() < lowestHealth then
                    lowestHealth = enemy.health.percent()
                    lowestEnemy = enemy
                end
            end
        end
    end

    return lowestEnemy
end


local function castHammerOfWrath()
    local lowestEnemy = findLowestEnemyPlayerInRange()
    if lowestEnemy then
        ni.spell.cast(spells.hammerOfWrath, lowestEnemy.guid)
    end
end

local abilities = {
    layOnHands = function() if enables.layOnHands then castSpell(spells.layOnHands, 'player', values.layOnHandsThreshold) end end,
    holyShock = function() if enables.holyShock then castSpell(spells.holyShock, 'ally', values.holyShockThreshold) end end,
    flashOfLight = function() if enables.flashOfLight then castSpell(spells.flashOfLight, 'ally', values.flashOfLightThreshold) end end,
    divineFavor = function() if enables.divineFavor then castSpell(spells.divineFavor, 'player', values.divineFavorThreshold) end end,
    auraMastery = function() if enables.auraMastery then castSpell(spells.auraMastery, 'player', values.auraMasteryThreshold) end end,
    divineIllumination = function() if enables.divineIllumination then castSpell(spells.divineIllumination, 'player', values.divineIlluminationThreshold) end end,
    divineShield = function() if enables.divineShield then emergencyCast(spells.divineShield, 'player', values.divineShieldThreshold) end end,
	handOfProtection = function() if enables.handOfProtection then emergencyCast(spells.handOfProtection, 'player', values.handOfProtectionThreshold) end end,
    beaconOfLight = function() if enables.beaconOfLight then castSpellBuff(spells.beaconOfLight) end end,
    sacredShield = function() if enables.sacredShield then castSpellBuff(spells.sacredShield) end end,
    blessingOfKings = function() if enables.blessingOfKings then castSpellBuff(spells.blessingOfKings) end end,
    handOfFreedom = function() if enables.handOfFreedom then castSpellBuff(spells.handOfFreedom) end end,
	aura = function() castAura() end,
	hammerOfWrath = function() if enables.hammerOfWrath then castHammerOfWrath() end end,
}

ni.bootstrap.profile("HolyPaladin", queue, abilities, OnLoad, OnUnLoad)
