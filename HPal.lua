local queue = {
	"Pause",
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
	"Bauble of True Blood",
	"Holy Shock",
	"Flash of Light",
	"Cleanse",
	"Blessing of Kings",
}

local values = {
	["Divine ShieldThreshold"] = 35,
	["Lay on HandsThreshold"] = 35,
	["Divine ProtectionThreshold"] = 35,
	["Hand of ProtectionThreshold"] = 35,
	["Divine SacrificeThreshold"] = 50,
	["Hand of SacrificeThreshold"] = 65,
	["Use HealthstoneThreshold"] = 40,
	--["Sacred ShieldThreshold"] = 0,
	--["Beacon of LightThreshold"] = 0,
	["Aura MasteryThreshold"] = 65,
	["Divine FavorThreshold"] = 75,
	["Divine IlluminationThreshold"] = 65,
	["Hand of FreedomThreshold"] = 65,
	["Hammer of WrathThreshold"] = 20,
	--["Hammer of JusticeThreshold"] = 0,
	["Bauble of True BloodThreshold"] = 50,
	["Holy ShockThreshold"] = 85,
	["Flash of LightThreshold"] = 85,
	--["CleanseThreshold"] = 0,
	--["Blessing of KingsThreshold"] = 0,
}

local enables = {
	["Divine Shield"] = true,
	["Lay on Hands"] = true,
	["Divine Protection"] = true,
	["Hand of Protection"] = true,
	["Divine Sacrifice"] = true,
	["Hand of Sacrifice"] = true,
	["Use Healthstone"] = true,
	["Sacred Shield"] = true,
	["Beacon of Light"] = true,
	["Aura Mastery"] = true,
	["Divine Favor"] = true,
	["Divine Illumination"] = true,
	["Hand of Freedom"] = true,
	["Hammer of Wrath"] = true,
	["Hammer of Justice"] = true,
	["Bauble of True Blood"] = true,
	["Holy Shock"] = true,
	["Flash of Light"] = true,
	["Cleanse"] = true,
	["Blessing of Kings"] = true,
}

local HoFDebuff = {
	-- Root, Ensnared, Mod Decrease Speed
	["Chains of Ice"] = 45524,
	["Hamstring"] = 1715,
	["Crippling Poison"] = 3408,
	["Frostbolt"] = 59638,
	["Seal of Justice"] = 20164,
	["Cleave"] = 25809,
	["Slow"] = 31589,
	["Earthgrab Totem"] = 51585,
	["Ice Barrier"] = 50040,
	["Chilblains"] = 50041,
	["Blade Twisting"] = 31124,
	["Frost Nova"] = 122,
	["Frostfire Bolt"] = 44614,
	["Dazed"] = 1604,
	["Entangling Roots"] = 339,
	["Feral Charge - Cat"] = 45334,
	["Infected Wounds"] = 58179,
	["Typhoon"] = 61391,
	["Counterattack"] = 19306,
	["Entrapment"] = 19185,
	["Concussive Barrage"] = 35101,
	["Concussive Shot"] = 5116,
	["Wing Clip"] = 2974,
	["Glyph of Frost Nova"] = 61394,
	["Frostfire Orb"] = 54644,
	["Black Arrow"] = 50245,
	["T.N.T."] = 50271,
	["Venom Web Spray"] = 54706,
	["Web"] = 4167,
	["Freeze"] = 33395,
	["Shattered Barrier"] = 55080,
	["Blast Wave"] = 11113,
	["Chilled"] = 6136,
	["Cone of Cold"] = 120,
	["Frostbolt"] = 116,
	["Frostfire Bolt"] = 44614,
	["Slow"] = 31589,
	["Seal of Command"] = 20170,
	["Blade Flurry"] = 31125,
	["Crippling Poison II"] = 3409,
	["Deadly Throw"] = 26679,
	["Earth and Moon"] = 64695,
	["Freeze"] = 63685,
	["Frost Shock"] = 8056,
	["Frostbrand Attack"] = 8034,
	["Aftermath"] = 18118,
	["Curse of Exhaustion"] = 18223,
	["Binding Heal"] = 63311,
	["Healing Touch"] = 23694,
	["Piercing Howl"] = 12323,
	["Frost Grenade"] = 39965,
	["Frost Presence"] = 55536,
	["Ice Barrier"] = 13099,
	["Dazed"] = 29703
}


local function GUICallback(key, item_type, value)
    if item_type == "enabled" then
        local ability = key:gsub("Threshold", "")
        enables[ability] = value
    elseif item_type == "value" then
        values[key] = value
    end
end

-- GUI
local items = {
	settingsfile = "HPal.json",
    callback = GUICallback,
	{ type = "separator" },
    { type = "title", text = "|cffFFFF00Holy Paladin|r PVP Profile" },
	{ type = "separator" },
}

for _, ability in ipairs(queue) do
    if ability ~= "Pause" and "Cache" then
        table.insert(items, {
            type = "entry",
            text = ability,
            enabled = enables[ability],
            value = values[ability.."Threshold"],
            key = ability.."Threshold"
        })
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

-- Ability functions
local abilities = {
    -- Pause
	["Pause"] = function()
		if IsMounted()
			or UnitInVehicle("player")
			or UnitIsDeadOrGhost("player")
			or UnitChannelInfo("player")
			or UnitCastingInfo("player")
			or ni.player.islooting()
			or ni.unit.debuff("player", "Polymorph")
			or ni.unit.debuff("player", "Cyclone")
			or ni.unit.debuff("player", "Fear")
			or ni.unit.debuff("player", "Blind")
		then
			return true
		end
	end,

	-- Divine Shield
	["Divine Shield"] = function()
		if enables["Divine Shield"]
			and ni.unit.hp("player") <= values["Divine ShieldThreshold"]
			and not ni.unit.debuff("player", "Forbearance")
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
	["Lay on Hands"] = function()
		if enables["Lay on Hands"] then
			local inArena = select(2, IsInInstance()) == "arena"
			if inArena then
				return false
			end
			if ni.spell.available("Lay on Hands") and UnitAffectingCombat("player") then
				for i = 1, #ni.members.sort() do
					if ni.members[i]:hp() <= values["Lay on HandsThreshold"]
						and not ni.members[i]:debuff("Forbearance")
						and ni.members[i]:valid("Lay on Hands", false, true)
					then
						if UnitCastingInfo("player") or UnitChannelInfo("player") then
							ni.spell.stopcasting()
						end
						ni.spell.cast("Lay on Hands", ni.members[i].guid)
						print("Lay on Hands", ni.members[i].name)
						return true
					end
				end
			end
		end
		return false
	end,

	-- Divine Protection
	["Divine Protection"] = function()
		if enables["Divine Protection"]
			and ni.unit.hp("player") <= values["Divine ProtectionThreshold"]
			and not ni.unit.debuff("player", "Forbearance")
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
	["Hand of Protection"] = function()
		if enables["Hand of Protection"] and ni.spell.available("Hand of Protection") then
			for i = 1, #ni.members.sort() do
				if ni.members[i]:hp() <= values["Hand of ProtectionThreshold"]
					and not ni.members[i]:debuff("Forbearance")
					and ni.members[i]:valid("Hand of Protection", false, true)
					and ni.members[i]:combat()
				then
					if UnitCastingInfo("player") or UnitChannelInfo("player") then
						ni.spell.stopcasting()
					end
					ni.spell.cast("Hand of Protection", ni.members[i].guid)
					print("Hand of Protection", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Divine Sacrifice
	["Divine Sacrifice"] = function()
		if enables["Divine Sacrifice"] and ni.spell.available("Divine Sacrifice") and UnitAffectingCombat("player") then
			for i = 1, #ni.members.sort() do
				local member = ni.members[i]
				if member.unit ~= "player"
					and member:hp() <= values["Divine SacrificeThreshold"]
					and member:combat()
				then
					ni.spell.cast("Divine Sacrifice")
					print("Divine Sacrifice cast to protect ", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Hand of Sacrifice
	["Hand of Sacrifice"] = function()
		if enables["Hand of Sacrifice"] and ni.spell.available("Hand of Sacrifice") then
			for i = 1, #ni.members.sort() do
				local member = ni.members[i]
				if member.unit ~= "player"
					and member:hp() <= values["Hand of SacrificeThreshold"]
					and member:valid("Hand of Sacrifice")
					and member:combat()
				then
					ni.spell.cast("Hand of Sacrifice", member.guid)
					print("Hand of Sacrifice cast on ", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Use Healthstone
	["Use Healthstone"] = function()
		local itemName = "Fel Healthstone"
		local itemId = GetItemIdByName(itemName)
		if enables["Use Healthstone"]
			and ni.unit.hp("player") <= values["Use HealthstoneThreshold"]
			and ni.player.hasitem(itemId)
			and UnitAffectingCombat("player")
		then
			ni.player.useitem(itemId)
			print("Healthstone")
			return true
		end
		return false
	end,

	-- Sacred Shield
	["Sacred Shield"] = function()
		if enables["Sacred Shield"]
			and not ni.unit.buff("player", "Sacred Shield")
			and ni.spell.available("Sacred Shield")
			and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection"))
		then
			ni.spell.cast("Sacred Shield", "player")
			print("Sacred Shield")
			return true
		end
		return false
	end,

	-- Beacon of Light
	["Beacon of Light"] = function()
		if enables["Beacon of Light"]
			and not ni.unit.buff("player", "Beacon of Light")
			and ni.spell.available("Beacon of Light")
			and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection"))
		then
			ni.spell.cast("Beacon of Light", "player")
			print("Beacon of Light")
			return true
		end
		return false
	end,

	-- Aura Mastery
	["Aura Mastery"] = function()
		if enables["Aura Mastery"]
			and ni.unit.hp("player") <= values["Aura MasteryThreshold"]
			and ni.unit.buff("player", "Concentration Aura")
			and ni.spell.available("Aura Mastery")
			and UnitAffectingCombat("player")
			and not (ni.unit.buff("player", "Divine Shield") or ni.unit.buff("player", "Hand of Protection"))
		then
			ni.spell.cast("Aura Mastery", "player")
			print("Aura Mastery")
			return true
		end
		return false
	end,

	-- Divine Favor
	["Divine Favor"] = function()
		if enables["Divine Favor"] then
			if ni.unit.hp("player") <= values["Divine FavorThreshold"]
				and ni.spell.available("Divine Favor")
				and ni.spell.available("Holy Shock")
				and UnitAffectingCombat("player")
			then
				ni.spell.cast("Divine Favor", "player")
				print("Divine Favor")
				for i = 1, #ni.members.sort() do
					if ni.members[i]:valid("Holy Shock", false, true)
					then
						ni.spell.cast("Holy Shock", ni.members[i].guid)
						print("Holy Shock")
						return true
					end
				end
			end
		end
		return false
	end,

	-- Divine Illumination
	["Divine Illumination"] = function()
		if enables["Divine Illumination"]
			and ni.unit.power("player") <= values["Divine IlluminationThreshold"]
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
	["Hammer of Wrath"] = function()
		if enables["Hammer of Wrath"] then
			local enemies = ni.unit.enemiesinrange("player", 30)
			for i = 1, #enemies do
				local target = enemies[i].guid
				if ni.unit.hp(target) <= values["Hammer of WrathThreshold"]
					and ni.spell.available("Hammer of Wrath")
					and ni.spell.valid(target, "Hammer of Wrath", false, true)
				then
					ni.player.lookat(target)
					ni.spell.cast("Hammer of Wrath", target)
					print("Hammer of Wrath", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Hand of Freedom
	["Hand of Freedom"] = function()
		if enables["Hand of Freedom"] then
			for i = 1, #ni.members.sort() do
				local member = ni.members[i]
				local hasHoFDebuff = false
				for debuffName, debuffId in pairs(HoFDebuff) do
					if member:debuff(debuffId) then
						hasHoFDebuff = true
						break
					end
				end
				if member:combat()
					and (ni.healing.candispel(member.guid) or hasHoFDebuff)
					and ni.spell.available("Hand of Freedom")
					and member:valid("Hand of Freedom", false, true)
				then
					ni.spell.cast("Hand of Freedom", member.guid)
					print("Hand of Freedom", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Hammer of Justice
	["Hammer of Justice"] = function()
		if enables["Hammer of Justice"] then
			local enemies = ni.unit.enemiesinrange("player", 10)
			for i = 1, #enemies do
				local target = enemies[i].guid
				if (ni.unit.iscasting(target) or ni.unit.ischanneling(target))
					and ni.spell.available("Hammer of Justice")
					and ni.spell.valid(target, "Hammer of Justice")
				then
					ni.spell.cast("Hammer of Justice", target)
					print("Hammer of Justice", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Bauble of True Blood (Trinket)
	["Bauble of True Blood"] = function()
		local itemName = "Bauble of True Blood"
		local itemId = GetItemIdByName(itemName)
		if enables["Bauble of True Blood"]
			and ni.player.hasitemequipped(itemId)
		then
			local membersInRange = ni.members.inrange("player", 40)
			for i = 1, #membersInRange do
				local member = membersInRange[i]
				if member:hp() <= values["Bauble of True BloodThreshold"]
					and ni.player.itemcd(itemId) == 0
					and member:combat()
					and member:los()
				then
					ni.player.useitem(itemId, member.guid)
					print("Bauble of True Blood", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Holy Shock
	["Holy Shock"] = function()
		if enables["Holy Shock"]
			and ni.spell.available("Holy Shock")
		then
			for i = 1, #ni.members.sort() do
				if ni.members[i]:hp() <= values["Holy ShockThreshold"]
					and ni.members[i]:valid("Holy Shock", false, true)
				then
					ni.spell.cast("Holy Shock", ni.members[i].guid)
					print("Holy Shock", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Flash of Light
	["Flash of Light"] = function()
		if enables["Flash of Light"]
			and ni.spell.available("Flash of Light")
		then
			local isMoving = ni.player.movingfor(0.1)
			local hasInfusionOfLight = ni.unit.buff("player", "Infusion of Light")
			for i = 1, #ni.members.sort() do
				if (not isMoving or hasInfusionOfLight)
					and ni.members[i]:hp() <= values["Flash of LightThreshold"]
					and ni.members[i]:valid("Flash of Light", false, true)
				then
					ni.spell.cast("Flash of Light", ni.members[i].guid)
					print("Flash of Light", ni.members[i].name)
					return true
				end
			end
		end
		return false
	end,

	-- Cleanse
	["Cleanse"] = function()
		if enables["Cleanse"]
			and ni.spell.available("Cleanse")
		then
			for i = 1, #ni.members.sort() do
				if ni.healing.candispel(ni.members[i].guid)
					and ni.members[i]:valid("Cleanse", false, true)
				then
					ni.spell.cast("Cleanse", ni.members[i].guid)
					print("Cleanse", ni.members[i].name)
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
		then
			local hasGreaterBlessing = ni.unit.buff("player", "Greater Blessing of Kings")
			local hasBlessing = ni.unit.buff("player", "Blessing of Kings")

			if not hasBlessing and not hasGreaterBlessing then
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
