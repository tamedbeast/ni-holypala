local queue = {
    "Divine Shield",
    "Lay on Hands",
    "Divine Protection",
    "Hand of Protection",
    "Divine Sacrifice",
    "Hand of Sacrifice",
    "Use Healthstone",
    "Sacred Shield",
    "Beacon of Light",
    "Aura Mastery",
    "Divine Favor",
    "Divine Illumination",
    "Hand of Freedom",
    "Hammer of Wrath",
    "Hammer of Justice",
    "Holy Shock",
    "Flash of Light",
    "Cleanse",
    "Greater Blessing of Kings",
    "Blessing of Kings",
}

local values = {
    ["Divine ShieldThreshold"] = 40,
    ["Hand of ProtectionThreshold"] = 40,
    ["Lay on HandsThreshold"] = 40,
    ["Divine ProtectionThreshold"] = 40,
    ["Divine SacrificeThreshold"] = 50,
    ["Hand of SacrificeThreshold"] = 65,
    ["Use HealthstoneThreshold"] = 20,
    ["Hammer of WrathThreshold"] = 20,
    --["Hammer of JusticeThreshold] = 0,
    ["Aura MasteryThreshold"] = 65,
    ["Divine FavorThreshold"] = 75,
    ["Divine IlluminationThreshold"] = 65,
    --["Hand of FreedomThreshold"] = 0,
    ["Hand of FreedomThreshold"] = 65,
    ["Holy ShockThreshold"] = 88,
    ["Flash of LightThreshold"] = 88,
    ["CleanseThreshold"] = 65,
    --["Sacred Shield"] = 0,
    --["Beacon of Light"] = 0,
    --["Greater Blessing of Kings"] = 0,
    --["Blessing of Kings"] = 0,
}

local HoFDebuff = {
    "Earthgrab Totem",
	"Hamstring",
    "Enhance Nova",
    "Frost Nova",
    "Frostbite",
    "Freeze",
    "Nature's Grasp",
    "Entangling Roots",
    "Hamstring",
    "Desecration",
    "Frost Trap",
    "Frostbolt (Max Rank)",
    "Frostbolt (Rank 1)",
    "Cone of Cold",
    "Frostfire Bolt",
    "Mirror Image",
    "Chilled",
    "Slow",
    "Frost Shock",
    "Earthbind Totem",
    "Shadowflame",
    "Conflagration",
    "Feral Disease",
    "Crippling Poison",
    "Chains of Ice"
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
    enables[ability] = true
end
for _, ability in ipairs(queue) do
    table.insert(items, {
        type = "entry",
        text = ability,
        value = values[ability.."Threshold"],
        min = 0,
        max = 100,
        step = 1,
        key = ability.."Threshold",
        enabled = enables[ability],
        enabledkey = ability
    })
end

-- Function to check if the player is eligible to cast a spell
local function ucheck()
    return not IsMounted() and
        not UnitInVehicle("player") and
        not UnitIsDeadOrGhost("player") and
        not UnitChannelInfo("player") and
        not UnitCastingInfo("player") and
        not ni.unit.isstunned("player") and
        not ni.unit.issilenced("player") and
        not ni.unit.ispacified("player") and
        not ni.unit.isdisarmed("player") and
        not ni.unit.isfleeing("player") and
        not ni.unit.ispossessed("player") and
        not ni.unit.debuff("player", "Polymorph") and
		not ni.unit.debuff("player", "Cyclone") and
		not ni.unit.debuff("player", "Fear") and
		not ni.unit.debuff("player", "Blind")
end

-- Function to find the group member with the lowest health
local function LowestHP()
    local lowestMember = nil
    local lowestHP = 100
    for i = 1, #ni.members do
        local member = ni.members[i]
        if member:hp() < lowestHP then
            lowestHP = member:hp()
            lowestMember = member
        end
    end
    return lowestMember
end


-- Ability functions
local abilities = {
    -- Divine Shield
    -- Casts Divine Shield on the player if their health is below the threshold.
    ["Divine Shield"] = function()
        if enables["Divine Shield"] 
			and ni.unit.hp("player") <= values["Divine ShieldThreshold"] 
            and not ni.unit.debuff("player", "Forbearance") 
            and ucheck() 
            and ni.spell.available("Divine Shield") 
            and UnitAffectingCombat("player") 
        then
            if UnitCastingInfo("player") or UnitChannelInfo("player") then
                ni.spell.stopcasting()
            end
            ni.spell.cast("Divine Shield", "player")
            print("Divine Shield")
            return true
        end
        return false
    end,
	
	-- Lay on Hands
	-- Casts Lay on Hands on any group member if their health is below the threshold.    
	["Lay on Hands"] = function()
		if enables["Lay on Hands"] then
			local lowestMember = LowestHP()
			if lowestMember and lowestMember:hp() <= values["Lay on HandsThreshold"]
				and not lowestMember:debuff("Forbearance") 
				and ucheck() 
				and ni.spell.available("Lay on Hands") 
				and lowestMember:valid("Lay on Hands", false, true)
				and UnitAffectingCombat("player")
			then
				if UnitCastingInfo("player") or UnitChannelInfo("player") then
					ni.spell.stopcasting()
				end
				ni.spell.cast("Lay on Hands", lowestMember.guid)
				print("Lay on Hands", lowestMember.name)
				return true
			end
		end
		return false
	end,

    -- Divine Protection
    -- Casts Divine Protection on the player if their health is below the threshold.
    ["Divine Protection"] = function()
        if enables["Divine Protection"] 
			and ni.unit.hp("player") <= values["Divine ProtectionThreshold"] 
            and not ni.unit.debuff("player", "Forbearance") 
            and ucheck() 
            and ni.spell.available("Divine Protection") 
            and UnitAffectingCombat("player") 
        then
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
	-- Casts "Hand of Protection" on the group member with the lowest health if certain conditions are met.
	["Hand of Protection"] = function()
		if enables["Hand of Protection"] then
			local lowestMember = LowestHP()
			if lowestMember 
				and lowestMember:hp() <= values["Hand of ProtectionThreshold"] 
				and not lowestMember:debuff("Forbearance") 
				and ucheck() 
				and ni.spell.available("Hand of Protection") 
				and lowestMember:combat() 
			then
				if UnitCastingInfo("player") or UnitChannelInfo("player") then
					ni.spell.stopcasting()
				end
				ni.spell.cast("Hand of Protection", lowestMember.guid)
				print("Hand of Protection", lowestMember.name)
				return true
			end
		end
		return false
	end,

    -- Divine Sacrifice
	-- Casts Divine Sacrifice on any group member if their health is below the threshold and the player has line of sight to them.
	["Divine Sacrifice"] = function()
		if enables["Divine Sacrifice"] and #ni.members > 1 then
			for i = 1, #ni.members do
				if ni.members.inrangebelow("player", 30, values["Divine SacrificeThreshold"])
					and ucheck() 
					and ni.spell.available("Divine Sacrifice") 
					and ni.members[i]:valid("Divine Sacrifice") 
					and ni.members[i]:combat() 
				then
					ni.spell.cast("Divine Sacrifice", ni.members[i].guid)
					print("Divine Sacrifice")
					return true
				end
			end
		end
		return false
	end,

	-- Hand of Sacrifice
	-- Casts "Hand of Sacrifice" on the group member with the lowest health if certain conditions are met.
	["Hand of Sacrifice"] = function()
		if enables["Hand of Sacrifice"] then
			local lowestMember = LowestHP()
			if lowestMember 
				and lowestMember.unit ~= "player" 
				and lowestMember:hp() <= values["Hand of SacrificeThreshold"] 
				and not lowestMember:debuff("Forbearance") 
				and ucheck() 
				and ni.spell.available("Hand of Sacrifice") 
				and lowestMember:combat() 
				and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection")) 
			then
				ni.spell.cast("Hand of Sacrifice", lowestMember.guid)
				print("Hand of Sacrifice cast on ", lowestMember.name)
				return true
			end
		end
		return false
	end,

    -- Use Healthstone
    -- Uses a Healthstone if the player's health is below 20% and passes the ucheck conditions.
    ["Use Healthstone"] = function()
        if enables["Use Healthstone"] 
			and ni.unit.hp("player") <= values["Use HealthstoneThreshold"]
            and ni.player.hasitem("Fel Healthstone") 
            and ucheck() 
            and UnitAffectingCombat("player") 
        then
            ni.player.useitem("Fel Healthstone")
            print("Healthstone")
            return true
        end
        return false
    end,
	
    -- Sacred Shield
    -- Casts Sacred Shield on the player if they do not already have the Sacred Shield buff.
    ["Sacred Shield"] = function()
        if enables["Sacred Shield"] 
			and not ni.unit.buff("player", "Sacred Shield") 
            and ucheck()
            and ni.spell.available("Sacred Shield") 
        then
            ni.spell.cast("Sacred Shield", "player")
            print("Sacred Shield")
            return true
        end
        return false
    end,

    -- Beacon of Light
    -- Casts Beacon of Light on the player if they do not already have the Beacon of Light buff.
    ["Beacon of Light"] = function()
        if enables["Beacon of Light"] 
			and not ni.unit.buff("player", "Beacon of Light") 
            and ucheck()
            and ni.spell.available("Beacon of Light") 
        then
            ni.spell.cast("Beacon of Light", "player")
            print("Beacon of Light")
            return true
        end
        return false
    end,
	
    -- Aura Mastery
    -- Casts Aura Mastery if the player's health is below the threshold.
    ["Aura Mastery"] = function()
        if enables["Aura Mastery"] 
			and ni.unit.hp("player") <= values["Aura MasteryThreshold"] 
            and ni.unit.buff("player", "Concentration Aura") 
            and ucheck() 
            and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection")) 
            and ni.spell.available("Aura Mastery") 
            and UnitAffectingCombat("player") 
        then
            ni.spell.cast("Aura Mastery", "player")
            print("Aura Mastery")
            return true
        end
        return false
    end,

	-- Divine Favor
	-- Casts Divine Favor if player's health is below the threshold.
	["Divine Favor"] = function()
		if enables["Divine Favor"] then
			if ni.unit.hp("player") <= values["Divine FavorThreshold"] 
				and ucheck() 
				and ni.spell.available("Divine Favor") 
				and UnitAffectingCombat("player") 
			then
				ni.spell.cast("Divine Favor", "player")
				print("Divine Favor")
				return true
			end
		end
		return false
	end,
	
    -- Divine Illumination
    -- Casts Divine Illumination if the player's mana is below the threshold.
    ["Divine Illumination"] = function()
        if enables["Divine Illumination"] 
			and ni.unit.power("player") <= values["Divine IlluminationThreshold"] 
            and ucheck() 
            and ni.spell.available("Divine Illumination") 
            and UnitAffectingCombat("player") 
        then
            ni.spell.cast("Divine Illumination", "player")
            print("Divine Illumination")
            return true
        end
        return false
    end,

    -- Hammer of Wrath
    -- Casts on an enemy target within 30 yards if their health is below the threshold and the spell is available.
    ["Hammer of Wrath"] = function()
        if enables["Hammer of Wrath"] then
            local enemies = ni.unit.enemiesinrange("player", 30)
            for i = 1, #enemies do
                local target = enemies[i].guid
                if ni.unit.hp(target) <= values["Hammer of WrathThreshold"] 
                    and ucheck() 
                    and ni.spell.available("Hammer of Wrath") 
                    and ni.spell.valid(target, "Hammer of Wrath", false, true) 
                then
                    ni.player.lookat(target)
                    ni.spell.cast("Hammer of Wrath", target)
                    print("Hammer of Wrath")
                    return true
                end
            end
        end
        return false
    end,
	
	-- Hand of Freedom
	-- Casts Hand of Freedom on any group member in combat if they have a Snare, Root, or Stun debuff and the player has line of sight to them.
	["Hand of Freedom"] = function()
		if enables["Hand of Freedom"] then
			for i = 1, #ni.members do
				if ni.members[i]:combat() 
					and ni.healing.candispel(ni.members[i].guid) 
					and ucheck() 
					and ni.spell.available("Hand of Freedom") 
					and ni.members[i]:valid("Hand of Freedom", false, true) 
				then
					-- Check each debuff in the HoFDebuff list
					for _, debuffName in ipairs(HoFDebuff) do
						if ni.members[i]:debuff(debuffName) or ni.members[i]:debufftype("Rooted") or ni.members[i]:debufftype("Ensnared") then
							ni.spell.cast("Hand of Freedom", ni.members[i].guid)
							print("Hand of Freedom")
							return true
						end
					end
				end
			end
		end
		return false
	end,


    -- Hammer of Justice
    -- Casts on an enemy target within 10 yards if they are casting or channeling, and the spell is available.
    ["Hammer of Justice"] = function()
        if enables["Hammer of Justice"] then
            local enemies = ni.unit.enemiesinrange("player", 10)
            for i = 1, #enemies do
                local target = enemies[i].guid
                if (ni.unit.iscasting(target) or ni.unit.ischanneling(target)) 
                    and ucheck() 
                    and ni.spell.available("Hammer of Justice") 
                    and ni.spell.valid(target, "Hammer of Justice") 
                then
                    ni.spell.cast("Hammer of Justice", target)
                    print("Hammer of Justice")
                    return true
                end
            end
        end
        return false
    end,

    -- Holy Shock
    -- Casts Holy Shock on any group member if their health is below the threshold and the player has line of sight to them.
	["Holy Shock"] = function()
		if enables["Holy Shock"] then
			local lowestMember = LowestHP()
			if lowestMember and lowestMember:hp() <= values["Holy ShockThreshold"]
				and lowestMember:range(40)
				and ucheck() 
				and ni.spell.available("Holy Shock") 
				and lowestMember:valid("Holy Shock", false, true) 
			then
				ni.spell.cast("Holy Shock", lowestMember.guid)
				print("Holy Shock")
				return true
			end
		end
		return false
	end,

	-- Flash of Light
	-- Casts Flash of Light on any group member if the player is not moving for 0.1 seconds or has the Infusion of Light buff, and the group member's health is below the threshold.
	["Flash of Light"] = function()
		if enables["Flash of Light"] then
			local lowestMember = LowestHP()
			if lowestMember and lowestMember:hp() <= values["Flash of LightThreshold"] 
				and (not ni.player.movingfor(0.1) or ni.unit.buff("player", "Infusion of Light")) 
				and ucheck() 
				and ni.spell.available("Flash of Light") 
				and lowestMember:valid("Flash of Light", false, true) 
			then
				ni.spell.cast("Flash of Light", lowestMember.guid)
				print("Flash of Light")
				return true
			end
		end
		return false
	end,


    -- Cleanse
	-- Casts Cleanse on the group member with the lowest health if they have a debuff that can be cleansed.
	["Cleanse"] = function()
		if enables["Cleanse"] then
			local lowestMember = LowestHP()
			if lowestMember 
				and ni.healing.candispel(lowestMember.guid) 
				and ni.unit.power("player") >= values["CleanseThreshold"] 
				and ucheck() 
				and ni.spell.available("Cleanse") 
				and lowestMember:valid("Cleanse", false, true) 
			then
				ni.spell.cast("Cleanse", lowestMember.guid)
				print("Cleanse cast on ", lowestMember.name)
				return true
			end
		end
		return false
	end,

	-- Blessing of Kings
	-- Casts Blessing of Kings on self if not present, or Greater Blessing of Kings on group members if Preparation buff is active.
	["Blessing of Kings"] = function()
		if enables["Blessing of Kings"] then
			local hasGreaterBlessing = ni.unit.buff("player", "Greater Blessing of Kings")
			local hasBlessing = ni.unit.buff("player", "Blessing of Kings")
			local hasPreparation = ni.unit.buff("player", 44521) -- Preparation buff
			if not hasBlessing and not hasGreaterBlessing and ucheck("player", "Blessing of Kings") and ni.spell.available("Blessing of Kings") then
				ni.spell.cast("Blessing of Kings", "player")
				print("Blessing of Kings")
				return true
			elseif hasPreparation and ucheck("player", "Greater Blessing of Kings") and ni.spell.available("Greater Blessing of Kings") then
				-- Cast Greater Blessing of Kings to everyone nearby
				for i = 1, #ni.members do
					if ni.members[i]:range(30) and ni.members[i]:valid("Greater Blessing of Kings", false, true) then
						local memberHasGreaterBlessing = ni.unit.buff(ni.members[i].guid, "Greater Blessing of Kings")
						if not memberHasGreaterBlessing then
							ni.spell.cast("Greater Blessing of Kings", ni.members[i].guid)
							print("Greater Blessing of Kings cast on ", ni.members[i].name)
						end
					end
				end
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
