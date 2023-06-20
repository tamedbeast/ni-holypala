local GetBuildInfo, select, ipairs, pairs, tonumber, GetSpellInfo, IsUsableSpell, GetTime, UnitAffectingCombat, IsMounted, ni_tanks, UnitInVehicle, UnitIsDeadOrGhost, UnitChannelInfo, UnitCastingInfo = GetBuildInfo, select, ipairs, pairs, tonumber, GetSpellInfo, IsUsableSpell, GetTime, UnitAffectingCombat, IsMounted, ni.tanks, UnitInVehicle, UnitIsDeadOrGhost, UnitChannelInfo, UnitCastingInfo

local spellList = {
    { name = "Lay on Hands",      enables = true,  threshold = 25, spellid = 48788 },
    { name = "Divine Shield",     enables = true,  threshold = 35, spellid = 642 },
    { name = "Hand of Protection",enables = true,  threshold = 40, spellid = 10278 },
    { name = "Hammer of Wrath",   enables = true,  threshold = 10, spellid = 10308 },
    { name = "Aura Mastery",      enables = true,  threshold = 65, spellid = 31821 },
    { name = "Divine Illumination",enables = true, threshold = 65, spellid = 31842 },
    { name = "Divine Favor",      enables = true,  threshold = 75, spellid = 20216 },
    { name = "Holy Shock",        enables = true,  threshold = 88, spellid = 48825 },
    { name = "Flash of Light",    enables = true,  threshold = 88, spellid = 48785 },
    { name = "Beacon of Light",   enables = true,  threshold = 0, spellid = 53563 },
    { name = "Sacred Shield",     enables = true,  threshold = 0, spellid = 53601 },
    { name = "Blessing of Kings", enables = true,  threshold = 0, spellid = 20217 },
    { name = "Hand of Freedom",   enables = true,  threshold = 0, spellid = 1044 },
    { name = "Crusader Aura",     enables = true,  threshold = 0, spellid = 32223 },
    { name = "Concentration Aura",enables = true,  threshold = 0, spellid = 19746 }
}

-- GUI top frame
local items = {
    { type = "title", text = "Holy Paladin PvP Profile" },
    { type = "separator" }
}

for _, spell in ipairs(spellList) do
    local item = {
        type = "entry",
        text = spell.name,
        enabled = spell.enables,
        key = spell.name
    }

    if spell.threshold > 0 then
        item.value = spell.threshold
        item.min = 0
        item.max = 100
        item.step = 1
    end

    table.insert(items, item)
end

-- GUI callback
local function GUICallback(key, item_type, value)
    for _, spell in ipairs(spellList) do
        if spell.name == key then
            if item_type == "enabled" then
                spell.enables = value
            elseif item_type == "value" then
                spell.threshold = value
            end
            break
        end
    end
end

-- Function OnLoad
local function OnLoad()
    ni.GUI.AddFrame("HolyPaladin", items)
end

-- Function OnUnload
local function OnUnLoad()
    ni.GUI.DestroyFrame("HolyPaladin")
end

-- Get spellid by spellname
local function getSpellIdByName(spellName)
    for _, spellData in ipairs(spellList) do
        if spellData.name == spellName then
            return spellData.spellid
        end
    end
    return nil
end

local function castSpellOnSelf(spell, threshold)
    local spellId = getSpellIdByName(spell)
    if not spellId then return end

    local spellName = GetSpellInfo(spellId)
    if spellName and self.buff(spellName) then
        return
    end

    if threshold == 0 or self.hp() <= threshold then
        self.stopcasting()
        self.cast(spellId, 'player')
    end
end

local function castSpellOnAlly(spell, threshold)
    local spellId = getSpellIdByName(spell)
    if not spellId then return end

    for i = 1, #ni.members do
        local ally = ni.members[i]
        if ally:valid(spellId, false, true) and ally:los() and ally:hp() <= threshold and (spellId ~= getSpellIdByName("Flash of Light") or not self.ismoving()) then
            local spellName = GetSpellInfo(spellId)
            if spellName and ally.buff(spellName) then
                return
            end

            if spellId == getSpellIdByName("Hand of Freedom") and hasAnyDebuff(ally, debuffHoF) and ally.ismoving() then
                self.cast(spellId, ally.guid)
            elseif spellId ~= getSpellIdByName("Hand of Freedom") then
                self.cast(spellId, ally.guid)
            end
        end
    end
end

-- Local Abilities
local abilities = {
    layOnHands = function() if spellList[1].enables then castSpellOnSelf("Lay on Hands", spellList[1].threshold) end end,
    divineShield = function() if spellList[2].enables then castSpellOnSelf("Divine Shield", spellList[2].threshold) end end,
    handOfProtection = function() if spellList[3].enables then castSpellOnAlly("Hand of Protection", spellList[3].threshold) end end,
    auraMastery = function() if spellList[5].enables then castSpellOnAlly("Aura Mastery", spellList[5].threshold) end end,
    divineIllumination = function() if spellList[6].enables then castSpellOnSelf("Divine Illumination", spellList[6].threshold) end end,
    divineFavor = function() if spellList[7].enables then castSpellOnSelf("Divine Favor", spellList[7].threshold) end end,
    holyShock = function() if spellList[8].enables then castSpellOnSelf("Holy Shock", spellList[8].threshold) end end,
    flashOfLight = function() if spellList[9].enables then castSpellOnSelf("Flash of Light", spellList[9].threshold) end end,
    beaconOfLight = function() if spellList[10].enables then castSpellOnSelf("Beacon of Light", 0); castBuffOnSelf("Beacon of Light") end end,
    sacredShield = function() if spellList[11].enables then castSpellOnSelf("Sacred Shield", 0); castBuffOnSelf("Sacred Shield") end end,
    blessingOfKings = function() if spellList[12].enables then castSpellOnSelf("Blessing of Kings", 0); castBuffOnSelf("Blessing of Kings") end end,
    handOfFreedom = function() if spellList[13].enables then castSpellOnAlly("Hand of Freedom") end end
}

-- Bootstrap
ni.bootstrap.profile("HolyPaladin", spellList, abilities, OnLoad, OnUnLoad)
