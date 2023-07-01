local wotlk = select(4, GetBuildInfo()) == 30300;

if wotlk then

local queue = {
	"Pause",
	"Divine Shield",
	"Hand of Protection",
	"Lay on Hands",
	"Divine Protection",
	"Divine Sacrifice",
	"Hand of Sacrifice",
	"Healthstone",
	"Aura Mastery",
	"Divine Illumination",
	"Hand of Freedom",
	"Hammer of Wrath",
	"Hammer of Justice",
	"Bauble of True Blood",
	"Divine Favor",
	"Holy Shock",
	"Flash of Light",
	"Cleanse",
	"Sacred Shield",
	"Beacon of Light",
	"Blessing of Kings",
}

local values = {
	["Divine ShieldThreshold"] = 35,
	["Lay on HandsThreshold"] = 35,
	["Divine ProtectionThreshold"] = 35,
	["Hand of ProtectionThreshold"] = 35,
	["Divine SacrificeThreshold"] = 75,
	["Hand of SacrificeThreshold"] = 75,
	["HealthstoneThreshold"] = 40,
	--["Sacred ShieldThreshold"] = 0,
	--["Beacon of LightThreshold"] = 0,
	["Aura MasteryThreshold"] = 65,
	["Divine IlluminationThreshold"] = 65,
	["Hand of FreedomThreshold"] = 65,
	["Hammer of WrathThreshold"] = 20,
	--["Hammer of JusticeThreshold"] = 0,
	["Bauble of True BloodThreshold"] = 50,
	["Divine FavorThreshold"] = 75,
	["Holy ShockThreshold"] = 85,
	["Flash of LightThreshold"] = 85,
	["CleanseThreshold"] = 65,
	--["Blessing of KingsThreshold"] = 0,
}

local enables = {
	["Divine Shield"] = true,
	["Lay on Hands"] = true,
	["Divine Protection"] = true,
	["Hand of Protection"] = true,
	["Divine Sacrifice"] = true,
	["Hand of Sacrifice"] = true,
	["Healthstone"] = true,
	["Sacred Shield"] = true,
	["Beacon of Light"] = true,
	["Aura Mastery"] = true,
	["Divine Illumination"] = true,
	["Hand of Freedom"] = true,
	["Hammer of Wrath"] = true,
	["Hammer of Justice"] = true,
	["Bauble of True Blood"] = true,
	["Divine Favor"] = true,
	["Holy Shock"] = true,
	["Flash of Light"] = true,
	["Cleanse"] = true,
	["Blessing of Kings"] = true,
}

local HoFDebuff = {
    "Chains of Ice",
    "Hamstring",
    "Crippling Poison",
    "Earthgrab Totem",
    "Ice Barrier",
    "Blade Twisting",
    "Frostfire Bolt",
    "Entangling Roots",
    "Infected Wounds",
    "Typhoon",
    "Counterattack",
    "Entrapment",
    "Concussive Barrage",
    "Concussive Shot",
    "Wing Clip",
    "Frostfire Orb",
    "Venom Web Spray",
    "Web",
    "Pin",
    "Freeze",
    "Chilled",
    "Cone of Cold",
    "Crippling Poison II",
    "Frost Shock",
    "Frostbrand Attack",
    "Aftermath",
    "Curse of Exhaustion",
    "Piercing Howl",
    "Demonic Breath",
    "Ice Trap"
}

-- Get spell or id number by name
local idName = setmetatable({}, {
    __index = function(_, type)
        return function(name)
            if not name then return end
            local link = type == "item" 
				and select(2, GetItemInfo(name)) or GetSpellLink(name)
            return link and tonumber(link:match(type..":(%d+)"))
        end
    end
})
-- Pre Calculate Spell IDs
local preCalcSpellId = {}
for spell in pairs(queue) do
    if spell ~= "Pause" then
        preCalcSpellId[spell] = idName.spell(spell)
    end
end

-- Function Usable Spells when under crowd control
local function UsableSilence(spellid, stutter)
	if tonumber(spellid) == nil then
		spellid = ni.spell.id(spellid)
	end
	local result = false;
	if spellid == nil or spellid == 0 then
		return false;
	end
	local spellName = GetSpellInfo(spellid);
	if not ni.player.isstunned()
	and not ni.player.issilenced()
	and ni.spell.available(spellid, stutter)
	and IsUsableSpell(spellName) then
		result = true;
	end
	return result;
end;

-- GUI
local items = {
	settingsfile = "HPal.json",
    callback = GUICallback,
	{ type = "separator" },
    { type = "title", text = "|cffFFFF00Holy Paladin|r PVP Profile" },
	{ type = "separator" },
}

for _, ability in ipairs(queue) do
    if ability ~= "Pause" then
        local spellId = idName.spell(ability)
        local spellIcon = spellId and ni.spell.icon(spellId) or ""
        table.insert(items, {
            type = "entry",
            text = spellIcon .. " " .. ability,
            enabled = enables[ability],
            value = values[ability .. "Threshold"],
            key = ability .. "Threshold"
        })
    end
end

local function GUICallback(key, item_type, value)
    if item_type == "enabled" then
        local ability = key:gsub("Threshold", "")
        enables[ability] = value
    elseif item_type == "value" then
        values[key] = value
    end
end

local abilities = {
    -- Pause
    ["Pause"] = function()
        if IsMounted()
            or UnitInVehicle("player")
            or UnitIsDeadOrGhost("player")
            or UnitChannelInfo("player")
            or UnitCastingInfo("player")
            or ni.player.islooting()
        then
            return true
        end
    end,

    -- Divine Shield
    ["Divine Shield"] = function()
        if enables["Divine Shield"] 
		then
            if UsableSilence(idName.spell("Divine Shield")) 
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
        end
        return false
    end,

	-- Hand of Protection
    ["Hand of Protection"] = function()
        if enables["Hand of Protection"] 
		then
            if UsableSilence(idName.spell("Hand of Protection")) 
				and UnitAffectingCombat("player")
			then
                local lowMember = ni.members.inrangebelow("player", 30, values["Hand of ProtectionThreshold"])[1]
                if lowMember 
                    and lowMember:valid("Hand of Protection", false, true) 
                    and not ni.unit.debuff(lowMember.guid, "Forbearance")
                then
                    ni.spell.cast("Hand of Protection", lowMember.guid)
                    print("Hand of Protection", lowMember.name)
                    return true
                end
            end
        end
        return false
    end,
	
    -- Lay on Hands
    ["Lay on Hands"] = function()
        if enables["Lay on Hands"] then
            local inArena = select(2, IsInInstance()) == "arena"
            if inArena 
			then
                return false
            end
            if UsableSilence(idName.spell("Lay on Hands")) 
				and UnitAffectingCombat("player")
			then
                local lowMember = ni.members.inrangebelow("player", 40, values["Lay on HandsThreshold"])[1]
                if lowMember 
                    and lowMember:valid("Lay on Hands", false, true) 
                    and not ni.unit.debuff(lowMember.guid, "Forbearance")
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
		then
            if UsableSilence(idName.spell("Divine Protection")) 
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
        end
        return false
    end,

    -- Divine Sacrifice
    ["Divine Sacrifice"] = function()
        if enables["Divine Sacrifice"] 
		then
            if UsableSilence(idName.spell("Divine Sacrifice"))
                and UnitAffectingCombat("player")
            then
                local lowMember = ni.members.inrangebelow("player", 30, values["Divine SacrificeThreshold"])[1]
                if lowMember 
                    and lowMember:valid("Divine Sacrifice", false, true) 
                then
                    ni.spell.cast("Divine Sacrifice", "player")
                    print("Divine Sacrifice", lowMember.name)
                    return true
                end
            end
        end
        return false
    end,

    -- Hand of Sacrifice
    ["Hand of Sacrifice"] = function()
        if enables["Hand of Sacrifice"] 
		then
            if UsableSilence(idName.spell("Hand of Sacrifice"))
                and UnitAffectingCombat("player")
            then
                local lowMember = ni.members.inrangebelow("player", 30, values["Hand of SacrificeThreshold"])[1]
                if lowMember 
                    and lowMember:valid("Hand of Sacrifice", false, true) 
                    and lowMember.guid ~= UnitGUID("player")
					and not ni.unit.buff("player", "Hand of Freedom")
					and not ni.unit.debuff("player", "Forbearance")
                then
                    ni.spell.cast("Hand of Sacrifice", lowMember.guid)
                    print("Hand of Sacrifice", lowMember.name)
                    return true
                end
            end
        end
        return false
    end,

    -- Healthstone
    ["Healthstone"] = function()
        if enables["Healthstone"] 
		then
            if ni.unit.hp("player") <= values["HealthstoneThreshold"] 
			then
                if ni.player.hasitem(idName.item("Fel Healthstone"))
                    and UnitAffectingCombat("player")
                then
                    ni.player.useitem("Fel Healthstone")
                    print("Healthstone")
                    return true
                end
            end
        end
        return false
    end,

    -- Aura Mastery
    ["Aura Mastery"] = function()
        if enables["Aura Mastery"] then
            if UsableSilence(idName.spell("Aura Mastery")) 
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
        end
        return false
    end,

    -- Divine Illumination
    ["Divine Illumination"] = function()
        if enables["Divine Illumination"] 
		then
            if UsableSilence(idName.spell("Divine Illumination")) 
				and UnitAffectingCombat("player")
			then
                if ni.unit.power("player") <= values["Divine IlluminationThreshold"] 
                then
                    ni.spell.cast("Divine Illumination", "player")
                    print("Divine Illumination")
                    return true
                end
            end
        end
        return false
    end,

    -- Hammer of Wrath
    ["Hammer of Wrath"] = function()
        if enables["Hammer of Wrath"] 
		then
            if UsableSilence(idName.spell("Hammer of Wrath")) 
			then
                local enemies = ni.unit.enemiesinrange("player", 30)
                for i = 1, #enemies do
                    local target = enemies[i].guid
                    if ni.unit.hp(target) <= values["Hammer of WrathThreshold"]
                        and ni.spell.valid(target, "Hammer of Wrath", false, true)
                    then
                        ni.player.lookat(target)
                        ni.spell.cast("Hammer of Wrath", target)
                        print("Hammer of Wrath")
                        return true
                    end
                end
            end
        end
        return false
    end,

    -- Hand of Freedom
    ["Hand of Freedom"] = function()
        if enables["Hand of Freedom"] 
		then
            if UsableSilence(idName.spell("Hand of Freedom")) 
			then
                for i = 1, #ni.members.sort() do
                    local member = ni.members[i]
                    local hasHoFDebuff = false
                    for debuffName, debuffId in pairs(HoFDebuff) do
                        if member:debuff(debuffId) 
						then
                            hasHoFDebuff = true
                            break
                        end
                    end
                    if member:valid("Hand of Freedom", false, true) 
                        and member:combat() 
                        and hasHoFDebuff
                    then
                        ni.spell.cast("Hand of Freedom", member.unit)
                        print("Hand of Freedom", member.name)
                        return true
                    end
                end
            end
        end
        return false
    end,

    -- Hammer of Justice
    ["Hammer of Justice"] = function()
        if enables["Hammer of Justice"] 
		then 
            if UsableSilence(idName.spell("Hammer of Justice"))
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
        end
        return false
    end,

    -- Bauble of True Blood (Trinket)
    ["Bauble of True Blood"] = function()
		if enables["Bauble of True Blood"] 
		then
			if ni.player.hasitemequipped(idName.item("Bauble of True Blood")) 
				and ni.player.itemcd(idName.item("Bauble of True Blood")) == 0
				and UnitAffectingCombat("player")
			then
				local lowMember = ni.members.inrangebelow("player", 40, values["Bauble of True BloodThreshold"])[1]
				if lowMember 
					and lowMember:los() 
				then
					ni.player.useitem(idName.item("Bauble of True Blood"), lowMember.guid)
					print("Bauble of True Blood", lowMember.name)
					return true
				end
			end
		end
		return false
	end,

	-- Divine Favor
    ["Divine Favor"] = function()
		if enables["Divine Favor"] 
		then
			if UsableSilence(idName.spell("Divine Favor")) 
			then
				local lowMember = ni.members.inrangebelow("player", 40, values["Divine FavorThreshold"])[1]
				if lowMember 
					and lowMember:valid("Holy Shock", false, true)
					and ni.spell.available("Divine Favor")
				then
					ni.spell.cast("Divine Favor", "player")
					print("Divine Favor")
					ni.spell.cast("Holy Shock", lowMember.guid)
					print("Holy Shock")
					return true
				end
			end
		end
		return false
	end,

	
    -- Holy Shock
    ["Holy Shock"] = function()
        if enables["Holy Shock"] 
		then
            if UsableSilence(idName.spell("Holy Shock")) 
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
        end
        return false
    end,

    -- Flash of Light
    ["Flash of Light"] = function()
        if enables["Flash of Light"] 
		then
            if (not ni.player.movingfor(0.1) or ni.unit.buff("player", "Infusion of Light"))
				and UsableSilence(idName.spell("Flash of Light"))				
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
        if enables["Cleanse"] then
            if UsableSilence(idName.spell("Cleanse")) 
			then
                if ni.unit.power("player") > values["CleanseThreshold"]
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
                else
                    ni.spell.stopcasting()
                end
            end
        end
        return false
    end,

	-- Sacred Shield
    ["Sacred Shield"] = function()
        if enables["Sacred Shield"] 
		then
            if UsableSilence(idName.spell("Sacred Shield")) 
			then
                if not ni.unit.buff("player", "Sacred Shield")
                    and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection"))
                then
                    ni.spell.cast("Sacred Shield", "player")
                    print("Sacred Shield")
                    return true
                end
            end
        end
        return false
    end,

    -- Beacon of Light
    ["Beacon of Light"] = function()
        if enables["Beacon of Light"] 
		then
            if UsableSilence(idName.spell("Beacon of Light")) 
			then
                if not ni.unit.buff("player", "Beacon of Light")
                    and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection"))
                then
                    ni.spell.cast("Beacon of Light", "player")
                    print("Beacon of Light")
                    return true
                end
            end
        end
        return false
    end,
	
    -- Blessing of Kings
    ["Blessing of Kings"] = function()
        if enables["Blessing of Kings"]
            and ni.spell.available("Blessing of Kings")
			and not UnitAffectingCombat("player")
        then
            local hasGreaterBlessing = ni.unit.buff("player", "Greater Blessing of Kings")
            local hasBlessing = ni.unit.buff("player", "Blessing of Kings")

            if not hasBlessing and not hasGreaterBlessing 
			then
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

else ni.bootstrap.profile("HPal", {"Error"}, {["Error"] = function() ni.vars.profiles.enabled = false; if not wotlk then ni.frames.floatingtext:message("Profile for 3.3.5a") end end}) end
