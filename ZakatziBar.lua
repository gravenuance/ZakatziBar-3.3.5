local AddonName = ...

local debugging

local spells
local player_spells
-- Tracks the specs of other players based on spec spells
local special_spells
local specs_by_guid

-- Number of buttons to spawn per bar
local total
-- How many active buttons?
local length_hostile
local length_party
local length_player
-- Button bars
local hostile
local party
local player

-- Delay for more accurate tracking
local delay_start

-- Size of side of square
local size

-- How often OnUpdate runs
local updateInterval
local time_elapsed

--Player identifier
local playerGUID

--Bar locations
local player_x
local player_y
local party_x
local party_y
local hostile_x
local hostile_y


local function ZB_InitializeVariables()
    playerGUID = UnitGUID("player")
    player_x = -225
    player_y = -225
    party_x = -225
    party_y = -275
    hostile_x = -225
    hostile_y = -325
    debugging = false
    size = 45
    delay_start = 0
    updateInterval = 0.1
    time_elapsed = 0
    
    total = 15
    length_hostile = 1
    length_party = 1
    length_player = 1

    spells = {}
    -- Spells
    -- Warrior
    spells[46924] = {duration = 90} -- Bladestorm
    spells[5246] = {duration = 120} -- Intimidating Shout
    spells[20230] = {duration = 300} -- Retaliation
    spells[1719] = {duration = 300} -- Recklessness
    spells[2565] = {duration = {60,40}, hasOtherDuration=true} -- Shield Block
    spells[871] = {duration = 300} -- Shield Wall
    spells[23920] = {duration = 10} -- Spell Reflection
    spells[3411] = {duration = 30} -- Intervene
    spells[11578] = {duration = {20, 15}, hasOtherDuration=true} -- Charge
    spells[12328] = {duration = 30} -- Sweeping Strikes
    spells[18499] = {duration = 30} -- Berserker Rage
    spells[55694] = {duration = 180} -- Enraged Regeneration
    spells[20252] = {duration = {25, 30}, hasOtherDuration=true} -- Intercept
    spells[72] = {duration = 12} -- Shield Bash
    spells[64382] = {duration = 300} -- Shattering Throw
    spells[676] = {duration = {60, 40}, hasOtherDuration=true} -- Disarm
    spells[6552] = {duration = 10} -- Pummel
    spells[46968] = {duration = 20} -- Shockwave
    spells[12809] = {duration = 30, hasCastAndDamage = true} -- Concussion Blow
    spells[12976] = {duration = 180} -- Last Stand
    spells[60503] = {duration = 9, isAura = true} -- Taste for Blood
    -- Paladin
    spells[25771] = {duration = 120, isAura = true} -- Forbearance
    spells[54428] = {duration = 60} -- Divine Plea
    spells[48817] = {duration = 30} -- Holy Wrath
    spells[498] = {duration = 180} -- Divine Protection
    spells[64205] = {duration = 120} -- Divine Sacrifice
    spells[6940] = {duration = 120} -- Hand of Sacrifice
    spells[642] = {duration = 300} -- Divine Shield
    spells[10308] = {duration = {40, 60, 30}, hasOtherDuration=true} -- Hammer of Justice
    spells[1044] = {duration = 25} -- Hand of Freedom
    spells[31884] = {duration = 120} -- Avenging Wrath
    spells[10278] = {duration = 180} -- Hand of Protection
    spells[20066] = {duration = 60} -- Repentance
    spells[31821] = {duration = 120} -- Aura Mastery
    spells[31842] = {duration = 180} -- Divine Illumination
    spells[48801] = {duration = 15} -- Exorcism
    spells[20216] = {duration = 120} -- Divine Favor
    spells[48827] = {duration = 30} -- Avenger's Shield
    -- Rogue
    spells[8643] = {duration = 20} -- Kidney Shot
    spells[51722] = {duration = 60} -- Dismantle
    spells[1776] = {duration = 10} -- Gouge
    spells[1766] = {duration = 10} -- Kick
    spells[2094] = {duration = 120} -- Blind
    spells[31224] = {duration = 60} -- Cloak of Shadows
    spells[57934] = {duration = 180} -- Tricks of the Trade
    spells[51713] = {duration = 60} -- Shadowdance
    spells[51690] = {duration = 75} -- Killing Spree
    spells[13750] = {duration = 180} -- Adrenaline Rush
    spells[26669] = {duration = {180, 180, 120}, hasOtherDuration=true} -- Evasion
    spells[11305] = {duration = {180, 180, 120}, hasOtherDuration=true} -- Sprint
    spells[2094] = {duration = 120} -- Blind
    spells[26889] = {duration = 120} -- Vanish
    spells[14185] = {duration = {300, 480}, hasOtherDuration=true, related = {14177, 26889,11305,26669}} -- Preparation
    spells[14177] = {duration = 180} -- Cold Blood
    -- Priest
    spells[6346] = {duration = 180} -- Fear Ward
    spells[33206] = {duration = 144} -- Pain Suppression
    spells[10060] = {duration = 96} -- Power Infusion
    spells[48173] = {duration = 120} -- Desperate Prayer
    spells[64844] = {duration = 480} -- Divine Hymn
    spells[64904] = {duration = 360} -- Hymn of Hope
    spells[10890] = {duration = {27, 23}, hasOtherDuration=true} -- Psychic Scream
    spells[48158] = {duration = 12} -- SW: Death
    spells[15487] = {duration = 45} -- Silence
    spells[47585] = {duration = 75} -- Dispresion
    spells[64044] = {duration = 120} -- Psychic Horror
    spells[34433] = {duration = {300, 180}, hasOtherDuration=true} -- Shadowfiend
    spells[586] = {duration = {30, 15}, hasOtherDuration=true} -- Fade
    -- Death Knight
    spells[47476] = {duration = 120} -- Strangulate
    spells[45529] = {duration = 60} -- Blood Tap
    spells[48743] = {duration = 120} -- Death Pact
    spells[47568] = {duration = 300} -- Empower Rune Weapon
    spells[49039] = {duration = 120} -- Lichborne
    spells[47528] = {duration = 10} -- Mind Freeze
    spells[48792] = {duration = 120} -- Icebound Fortitude
    spells[48707] = {duration = 45} -- Anti-Magic Shell
    spells[51052] = {duration = 120} -- Anti-Magic Zone
    spells[49206] = {duration = 180} -- Summon Gargoyle
    spells[49560] = {duration = 25} -- Death Grip
    spells[49203] = {duration = 60} -- Hungering Cold
    spells[49796] = {duration = 120} -- Deathchill
    spells[51271] = {duration = 120} -- Unbreakable Armor
    --Mage
    spells[1953] = {duration = 15} -- Blink
    spells[2139] = {duration = 24} -- Counterspell
    spells[66] = {duration = {180, 180, 126}, hasOtherDuration=true} -- Invisibility
    spells[12051] = {duration = {240, 240, 120}, hasOtherDuration=true} -- Evocation
    spells[55342] = {duration = 180} -- Mirror Image
    spells[41425] = {duration = 30, isAura = true} -- Hypothermia
    spells[12042] = {duration = 84} -- Arcane Power
    spells[12043] = {duration = 84} -- Presence of Mind
    spells[42945] = {duration = 30} -- Blast Wave
    spells[42950] = {duration = 20, hasCastAndDamage = true} -- Dragon's Breath
    spells[28682] = {duration = 120} -- Combustion
    spells[11958] = {duration = 384, related = {44572,42917,42931,43039,12472,31687,45438}} -- COLD SNAP
    spells[44572] = {duration = 30} -- Deep Freeze
    spells[42917] = {duration = {25, 20, 20}, hasOtherDuration=true, hasCastAndDamage = true} -- Frost Nova
    spells[42931] = {duration = {10, 8, 8}, hasOtherDuration=true} -- Cone of Cold
    spells[43039] = {duration = 24} -- Ice Barrier
    spells[12472] = {duration = 144} -- Icy Veins
    spells[31687] = {duration = 144} -- Summon Water Elemental
    spells[45438] = {duration = {300, 240, 240}, hasOtherDuration=true} -- Ice Block
    -- Warlock
    spells[47860] = {duration = 120, hasCastAndDamage = true} -- Death Coil
    spells[17928] = {duration = 40} -- Howl of Terror
    spells[48020] = {duration = 30} -- Teleport
    spells[18708] = {duration = 180} -- Fel Domination
    spells[61290] = {duration = 15, hasCastAndDamage = true} -- Shadowflame
    spells[19647] = {duration = 24} -- Spell Lock
    spells[59172] = {duration = 12} -- Chaos Bolt
    spells[17962] = {duration = 10, hasCastAndDamage = true} -- Conflagrate
    spells[47847] = {duration = 20, hasCastAndDamage = true} -- Shadowfury
    spells[47827] = {duration = 15, hasCastAndDamage = true} -- Shadowburn
    -- Shaman
    spells[51514] = {duration = 45} -- Hex
    spells[57994] = {duration = {5.2, 5, 6}, hasOtherDuration=true} -- Windshear
    spells[51533] = {duration = 180} -- Feral Spirit
    spells[8177] = {duration = {15, 13.5, 11.5}, hasOtherDuration=true} -- Grounding Totem
    spells[32182] = {duration = 300} -- Heroism
    spells[2825] = {duration = 300} -- Bloodlust
    spells[30823] = {duration = 60} -- Shamanistic Rage
    spells[59159] = {duration = 35, hasCastAndDamage = true} -- Thunderstorm
    spells[16190] = {duration = 300} -- Mana Tide Totem
    spells[16188] = {duration = 120} -- Nature's Swiftness
    spells[55166] = {duration = 180} -- Nature's Force
    spells[16166] = {duration = 180} -- Elemental Mastery
    spells[55166] = {duration = 180} -- Tidal Force
    -- Druid
    spells[22812] = {duration = 60} -- Barkskin
    spells[29166] = {duration = 180} -- Innervate
    spells[53312] = {duration = 60} -- Nature's Grasp
    spells[22842] = {duration = 180} -- Frenzied Regeneration
    spells[17116] = {duration = 180} -- Nature's Swiftness
    spells[48447] = {duration = 480} -- Tranquility
    spells[8983] = {duration = 60} -- Bash
    spells[61336] = {duration = 180} -- Survival Instincts
    spells[16979] = {duration = 15} -- Feral Charge - Bear
    spells[50213] = {duration = 30} -- Tiger's Fury
    spells[33831] = {duration = 180} -- Force of Nature
    spells[53201] = {duration = 60} -- Starfall
    spells[18562] = {duration = 13} -- Swiftmend
    spells[50334] = {duration = 180} -- Berserk
    spells[53227] = {duration = 20} -- Typhoon
    spells[33357] = {duration = 144} -- Dash
    spells[5229] = {duration = 60} -- Enrage
    spells[69369] = {duration  = 8, isAura = true} -- Predator's Swiftness
    -- Hunter
    spells[34490] = {duration = 20, hasCastAndDamage = true} -- Silencing Shot
    spells[23989] = {duration = 180, related = {34490,3045,34026,53271,19263,781,14311,60202,19503,19574,34600}} -- Readiness
    spells[3045] = {duration = 300} -- Rapid Fire
    spells[34026] = {duration = 60} -- Kill Command
    spells[53271] = {duration = 60} -- Master's Call
    spells[19263] = {duration = 90} -- Deterrence
    spells[781] = {duration = {16, 20}, hasOtherDuration=true} -- Disengage
    spells[14311] = {duration = 28} -- Freezing Trap
    spells[60202] = {duration = 28} -- Freezing Arrow
    spells[19503] = {duration = 30, hasCastAndDamage = true} -- Scatter Shot
    spells[19574] = {duration = 70.2} -- Bestial Wrath
    spells[19577] = {duration = 42} -- Intimidation
    spells[34600] = {duration = 28} -- Snake Trap
    -- Trinket
    spells[71607] = {duration = 120} -- Release of Light
    -- End

    player_spells = {}
    --Player Spells
    player_spells[60503] = {duration = 9, isAura = true} -- Taste for Blood
    player_spells[1715] = {duration = 15, isAura = true} -- Hamstring
    player_spells[47486] = {duration = 10, isAura = true} -- Mortal Strike
    player_spells[47465] = {duration = 21, isAura = true} -- Rend
    player_spells[47436] = {duration = 360, isAura = true} -- Battle Shout
    player_spells[65156] = {duration = 10, isAura = true} -- Juggernaut
    player_spells[52437] = {duration = 9, isAura = true} -- Sudden Death
    player_spells[59578] = {duration = 14, isAura = true} -- Art of War
    player_spells[54149] = {duration = 14, isAura = true} -- Infusion of Light
    player_spells[64205] = {duration = 10, isAura = true} -- Divine Sacrifice
    player_spells[25771] = {duration = 120, isAura = true} -- Forbearance
    player_spells[31821] = {duration = 6, isAura = true} -- Aura Mastery
    player_spells[53601] = {duration = {60, 30}, hasOtherDuration = true, isAura = true} -- Sacred Shield
    player_spells[53563] = {duration = 60, isAura = true} -- Beacon of Light
    player_spells[54152] = {duration = 60, isAura = true} -- Judgements of the Pure
    player_spells[6940] = {duration = 12, isAura = true} -- Hand of Sacrifice
    player_spells[48801] = {duration = 15} -- Exorcism
    player_spells[20271] = {duration = 10} -- Judgement of Light
    player_spells[53407] = {duration = 10} -- Judgement of Justice
    player_spells[48817] = {duration = 30, hasCastAndDamage = true} -- Holy Wrath
    player_spells[10326] = {duration = 8} -- Turn Evil
    player_spells[48806] = {duration = 6, hasCastAndDamage = true} -- Hammer of Wrath
    player_spells[48819] = {duration = 8} -- Consecration
    --End

    specs_by_guid = {}
    special_spells = {}
    special_spells[48821] = 1 -- Holy Paladin
    special_spells[53563] = 1 -- Holy Paladin
    special_spells[53385] = 2 -- Retribution Paladin
    special_spells[35395] = 2 -- Retribution Paladin
    special_spells[20066] = 2 -- Retribution Paladin
    special_spells[48827] = 3 -- Protection Paladin
    special_spells[48952] = 3 -- Protection Paladin
    special_spells[53595] = 3 -- Protection Paladin
    special_spells[46924] = 1 -- Arms Warrior
    special_spells[47486] = 1 -- Arms Warrior
    special_spells[65156] = 1 -- Arms Warrior
    special_spells[12328] = 1 -- Arms Warrior
    special_spells[46968] = 2 -- Protection Warrior
    special_spells[47498] = 2 -- Protection Warrior
    special_spells[12809] = 2 -- Protection Warrior
    special_spells[48660] = 1 -- Subtlety Rogue
    special_spells[51713] = 1 -- Subtlety Rogue
    special_spells[36554] = 1 -- Subtlety Rogue
    special_spells[48666] = 2 -- Assassination Rogue
    special_spells[51690] = 3 -- Combat Rogue
    special_spells[13750] = 3 -- Combat Rogue
    special_spells[48638] = 3 -- Combat Rogue
    special_spells[47750] = 1 -- Discipline Priest
    special_spells[33206] = 1 -- Discipline Priest
    special_spells[10060] = 1 -- Discipline Priest
    special_spells[47585] = 2 -- Shadow Priest
    special_spells[64044] = 2 -- Shadow Priest
    special_spells[15487] = 2 -- Shadow Priest
    special_spells[15286] = 2 -- Shadow Priest
    special_spells[48160] = 2 -- Shadow Priest
    special_spells[15473] = 2 -- Shadow Priest
    special_spells[49206] = 1 -- Unholy DK
    special_spells[51052] = 1 -- Unholy DK
    special_spells[55271] = 1 -- Unholy DK
    special_spells[49222] = 1 -- Unholy DK
    special_spells[51328] = 1 -- Unholy DK
    special_spells[51052] = 1 -- Unholy DK
    special_spells[50536] = 1 -- Unholy DK
    special_spells[49796] = 2 -- Frost DK
    special_spells[49203] = 2 -- Frost DK
    special_spells[50436] = 2 -- Frost DK
    special_spells[55268] = 2 -- Frost DK
    special_spells[42945] = 1 -- Fire Mage
    special_spells[42950] = 1 -- Fire Mage
    special_spells[55360] = 1 -- Fire Mage
    special_spells[28682] = 1 -- Fire Mage
    special_spells[11958] = 2 -- Frost Mage
    special_spells[44572] = 2 -- Frost Mage
    special_spells[31687] = 2 -- Frost Mage
    special_spells[43039] = 2 -- Frost Mage
    special_spells[44781] = 3 -- Arcane Mage
    special_spells[31589] = 3 -- Arcane Mage
    special_spells[12042] = 3 -- Arcane Mage
    special_spells[12043] = 3 -- Arcane Mage
    special_spells[59164] = 1 -- Affliction Warlock
    special_spells[47843] = 1 -- Affliction Warlock
    special_spells[59172] = 2 -- Destruction Warlock
    special_spells[47827] = 2 -- Destruction Warlock
    special_spells[47847] = 2 -- Destruction Warlock
    special_spells[17962] = 2 -- Destruction Warlock
    special_spells[17116] = 1 -- Restoration Druid
    special_spells[18562] = 1 -- Restoration Druid
    special_spells[53251] = 1 -- Restoration Druid
    special_spells[34123] = 1 -- Restoration Druid
    special_spells[50334] = 2 -- Feral Druid
    special_spells[24932] = 2 -- Feral Druid
    special_spells[53201] = 3 -- Balance Druid
    special_spells[33831] = 3 -- Balance Druid
    special_spells[24858] = 3 -- Balance Druid
    special_spells[53227] = 3 -- Balance Druid
    special_spells[53209] = 1 -- Marksmanship Hunter
    special_spells[34490] = 1 -- Marksmanship Hunter
    special_spells[19506] = 1 -- Marksmanship Hunter
    special_spells[19574] = 2 -- Beastmastery Hunter
    special_spells[19577] = 2 -- Beastmastery Hunter
    special_spells[51533] = 1 -- Enhancement Shaman
    special_spells[30823] = 1 -- Enhancement Shaman
    special_spells[17364] = 1 -- Enhancement Shaman
    special_spells[60103] = 1 -- Enhancement Shaman
    special_spells[59159] = 2 -- Elemental Shaman
    special_spells[57722] = 2 -- Elemental Shaman
    special_spells[16166] = 2 -- Elemental Shaman
    special_spells[51886] = 3 -- Restoration Shaman
    special_spells[16190] = 3 -- Restoration Shaman
    special_spells[49284] = 3 -- Restoration Shaman
    special_spells[61301] = 3 -- Restoration Shaman
    special_spells[16188] = 3 -- Restoration Shaman
end

local function ZB_RemoveIcon(bar, length, id, aura, srcGUID)
    if aura then
        local i = 1
        local found = false
        while i < length do
            if bar[i].id == id and srcGUID == bar[i].srcGUID then
                id = i
                found = true
                break
            end
            i = i + 1
        end
        if not found then
            return length
        end  
    end  
    length = length - 1
    local i = id
    while i < length do
        bar[i].id = bar[i+1].id
        bar[i].srcGUID = bar[i+1].srcGUID
        bar[i].duration = bar[i+1].duration
        bar[i].start = bar[i+1].start
        bar[i].cooldown = bar[i+1].cooldown
        bar[i].texture:SetTexture(bar[i+1].texture:GetTexture())
        bar[i].text:SetText(bar[i+1].text:GetText())
        bar[i].cd:SetCooldown(bar[i].start,bar[i].duration)
        i = i + 1
    end
    bar[length]:Hide() 
    return length
end


local function ZB_UpdateText(bar, i)
    if (bar[i].cooldown > 60) then
        bar[i].text:SetText(string.format("%.0fm", floor(bar[i].cooldown/60)))
    elseif (bar[i].cooldown >= 10) then
        bar[i].text:SetText(string.format(" %.0f", floor(bar[i].cooldown)))
    else
        bar[i].text:SetText(string.format("  %.0f", floor(bar[i].cooldown)))
    end
end

local function ZB_UpdateCooldowns(bar, length)
    if length > 1 then
        local i = 1
        local get_time = GetTime()
        while i < length do
            bar[i].cooldown = bar[i].start + bar[i].duration - get_time
            if bar[i].cooldown <= 0 then
                    length = ZB_RemoveIcon(bar, length, i, false)
            else 
                ZB_UpdateText(bar, i)
            end
            i = i + 1
        end
    end
    return length
end

local function ZB_OnUpdate(self, elapsed)
    time_elapsed = time_elapsed + elapsed;
    if time_elapsed >= updateInterval then
        length_player = ZB_UpdateCooldowns(player, length_player)
        length_hostile = ZB_UpdateCooldowns(hostile, length_hostile)
        length_party = ZB_UpdateCooldowns(party, length_party)
        if length_player == 1 and length_hostile == 1 and length_party == 1 then 
            ZB_Frame:SetScript("OnUpdate",nil)
        end
        time_elapsed = 0
    end
end

local function ZB_AddIcon(bar, length, id, list, refresh, srcGUID)
    local _duration = 0;
    if list[id].hasOtherDuration then
        if specs_by_guid[srcGUID] then
            if (list[id].duration[specs_by_guid[srcGUID]]) then
                _duration = list[id].duration[specs_by_guid[srcGUID]]
            end
        else
            _duration = list[id].duration[1]
        end
    else
        _duration = list[id].duration
    end
    local get_time = GetTime()
    if refresh then
        local i = 1
        while i < length do
            if bar[i].id == id and srcGUID == bar[i].srcGUID then
                bar[i].start = get_time*2-delay_start
                bar[i].duration = _duration
                bar[i].cooldown = bar[i].start + bar[i].duration - get_time
                bar[i].cd:SetCooldown(bar[i].start,bar[i].duration)
                ZB_UpdateText(bar, i)
                return length
            end
            i = i + 1
        end
    end
    if length < total then
        bar[length].srcGUID = srcGUID
        bar[length].duration = _duration

        bar[length].start = get_time*2-delay_start
        bar[length].cooldown = bar[length].start + bar[length].duration - get_time
        ZB_UpdateText(bar, length)

        bar[length].id = id

        local _,_,icon = GetSpellInfo(id)
        bar[length].texture:SetTexture(icon)
        bar[length].cd:SetCooldown(bar[length].start,bar[length].duration)

        bar[length]:Show()

        ZB_Frame:SetScript("OnUpdate", ZB_OnUpdate)
        return length + 1
    end
    return length
end

local function ZB_EventType(combatEvent, bar, length, id, line, srcGUID, dstGUID)
    delay_start = GetTime()
    if line[id].isAura then
        if combatEvent == "SPELL_AURA_APPLIED" and length < total then
            return ZB_AddIcon(bar, length, id, line, false, srcGUID)
        elseif combatEvent == "SPELL_AURA_REMOVED" then
            return ZB_RemoveIcon(bar, length, id, true, srcGUID)
        elseif combatEvent == "SPELL_AURA_REFRESH" then
            return ZB_AddIcon(bar, length, id, line, true, srcGUID)
        end
    else
        if combatEvent == "SPELL_DAMAGE" and not line[id].hasCastAndDamage and length < total then
            return ZB_AddIcon(bar, length, id, line, false, srcGUID)
        elseif combatEvent == "SPELL_CAST_SUCCESS" and length < total then
            return ZB_AddIcon(bar, length, id, line, false, srcGUID)
        end
    end
    return length
end

local function ZB_CombatLog(timestamp, combatEvent, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, id, name)
    if debugging and (srcGUID == (playerGUID or UnitGUID("target") or dstGUID == (playerGUID or UnitGUID("target")))) then
        print(id)
        print(name)
        print(combatEvent)
    end
    if special_spells[id] then
        specs_by_guid[srcGUID] = special_spells[id]
    end
    if id == 14185 or id == 23989 or id == 11958 then
        if bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
            for related_id in pairs(spells[id].related) do
                length_hostile = ZB_RemoveIcon(hostile, length_hostile, related_id, true, srcGUID)
            end
        elseif bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 then
            for related_id in pairs(spells[id].related) do
                length_party = ZB_RemoveIcon(party, length_party, related_id, true, srcGUID)
            end
        end
    end
    if srcGUID == playerGUID then
        if player_spells[id] then 
            if bit.band(dstFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 then
                length_party = ZB_EventType(combatEvent, party, length_party, id, player_spells, srcGUID, dstGUID)
            else
                length_player = ZB_EventType(combatEvent, player, length_player, id, player_spells, srcGUID, dstGUID)
            end
        end
    elseif spells[id] then  
        if bit.band(srcFlags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
            length_hostile = ZB_EventType(combatEvent, hostile, length_hostile, id, spells, srcGUID, dstGUID)
        elseif bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 then
            length_party = ZB_EventType(combatEvent, party, length_party, id, spells, srcGUID, dstGUID)
        end
    end
end

local function ZB_InitializeBars(bar, bar_x, bar_y)
    bar = CreateFrame("Frame",nil,UIParent)
    bar:SetWidth(size*4)
    bar:SetHeight(size)
    bar:SetClampedToScreen(true)
    bar:SetPoint("CENTER", UIParent, "CENTER", bar_x, bar_y)
    local location
    local btn
    local i = 1
    while i < total do
        location = size * i + 5 * i
        btn = CreateFrame("Frame",nil,bar)
        btn:SetWidth(size)
        btn:SetHeight(size)
        btn:SetPoint("CENTER",bar,"CENTER",location,0)
        btn:SetFrameStrata("LOW")
        
        local cd = CreateFrame("Cooldown",nil,btn)
        cd.noomnicc = true
        cd.noCooldownCount = true
        cd:SetAllPoints(true)
        cd:SetFrameStrata("MEDIUM")
        
        local texture = btn:CreateTexture(nil,"BACKGROUND")
        texture:SetAllPoints(true)
        texture:SetTexCoord(0.07,0.9,0.07,0.90) 
    
        local text = cd:CreateFontString(nil,"ARTWORK")
        text:SetFont(STANDARD_TEXT_FONT,20,"OUTLINE")
        text:SetTextColor(1,1,0,1)
        text:SetPoint("LEFT",btn,"LEFT",2,0)
        btn.texture = texture
        btn.text = text
        btn.cd = cd
        bar[i] = btn 
        i = i + 1
    end   
    return bar
end

local function ZB_ClearPlayers()
    for character in pairs (specs_by_guid) do
        specs_by_guid[character] = nil
    end
end


local function ZB_ResetAll(bar, length)
    if length > 1 then       
        local i = 1
        while length > 1 do
            length = ZB_RemoveIcon(bar, length, 1, false)
        end        
    end
    return length
end

local function ZB_EnteringWorld()
    length_player = ZB_ResetAll(player, length_player)
    length_hostile = ZB_ResetAll(hostile, length_hostile)
    length_party = ZB_ResetAll(party, length_party)
    ZB_ClearPlayers()
end

local function ZB_Commands(msg)
    if msg == "debug" then
        debugging = not debugging
        if debugging then
            print("Debugging on.")
        else 
            print("Debugging off.")
        end
    elseif msg == "clear" then
        ZB_EnteringWorld()
    else
        print("You can only 'clear' and 'debug'.")
    end
end

local function ZB_OnLoad(self)
    if(self.AddonName == AddonName) then
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        ZB_InitializeVariables()
        player = ZB_InitializeBars(player, player_x, player_y)
        party = ZB_InitializeBars(party, party_x, party_y)
        hostile = ZB_InitializeBars(hostile, hostile_x, hostile_y)
        SlashCmdList["ZAKATZIBAR"] = ZB_Commands
        SLASH_ZAKATZIBAR1 = "/zb"
    end
end

local eventhandler = {
    ["ADDON_LOADED"] = function(self) ZB_OnLoad(self) end,
    ["PLAYER_ENTERING_WORLD"] = function(self) ZB_EnteringWorld(self) end,
    ["COMBAT_LOG_EVENT_UNFILTERED"] = function(self,...) ZB_CombatLog(...) end,
}

local function ZB_OnEvent(self,event,...)
	eventhandler[event](self,...)
end


if not ZB_Frame then
    CreateFrame("Frame","ZB_Frame",UIParent)
    ZB_Frame.AddonName = AddonName
end
ZB_Frame:SetScript("OnEvent",ZB_OnEvent)
ZB_Frame:RegisterEvent("ADDON_LOADED")
