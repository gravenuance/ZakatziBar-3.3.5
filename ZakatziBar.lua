local debugging

local spells_list
local player_spells_list
-- Tracks the specs of other players based on spec spells
local special_spells_list
local specs_by_GUID_list

-- Number of buttons to spawn per bar
local total_buttons
-- How many active buttons?
local length_of_hostile_bar
local length_of_party_bar
local length_of_player_bar
-- Button bars
local hostile_bar
local party_bar
local player_bar

-- Delay for more accurate tracking
local count_delay_from_start

-- Size of side of square
local square_size

-- How often OnUpdate runs
local update_interval
local total_time_elapsed

--Player identifier
local player_guid

--Bar locations
local player_bar_x
local player_bar_y
local party_bar_x
local party_bar_y
local hostile_bar_x
local hostile_bar_y

local are_bars_being_cleared

local is_disabled


local function zb_initialize_variables()
    player_guid = UnitGUID("player")
    local _, class_name = UnitClass("player")
    print(class_name)
    player_bar_x = -225
    player_bar_y = -225
    party_bar_x = -225
    party_bar_y = -275
    hostile_bar_x = -225
    hostile_bar_y = -325
    debugging = false
    are_bars_being_cleared = false
    square_size = 45
    count_delay_from_start = 0
    update_interval = 0.1
    total_time_elapsed = 0
    
    total_buttons = 15
    length_of_hostile_bar = 1
    length_of_party_bar = 1
    length_of_player_bar = 1

    spells_list = {}
    -- Spells
    -- Warrior
    spells_list[46924] = {duration = 90, is_success = true} -- Bladestorm
    spells_list[5246] = {duration = 120, is_success = true} -- Intimidating Shout
    spells_list[20230] = {duration = 300, is_success = true} -- Retaliation
    spells_list[1719] = {duration = 300, is_success = true} -- Recklessness
    spells_list[2565] = {duration = {60,40}, has_other_duration=true, is_success = true} -- Shield Block
    spells_list[871] = {duration = 300, is_success = true} -- Shield Wall
    spells_list[23920] = {duration = 10, is_success = true} -- Spell Reflection
    spells_list[3411] = {duration = 30, is_success = true} -- Intervene
    spells_list[11578] = {duration = {20, 15}, has_other_duration=true, is_success = true} -- Charge
    spells_list[12328] = {duration = 30, is_success = true} -- Sweeping Strikes
    spells_list[18499] = {duration = 30, is_success = true} -- Berserker Rage
    spells_list[55694] = {duration = 180, is_success = true} -- Enraged Regeneration
    spells_list[20252] = {duration = {25, 30}, has_other_duration=true, is_success = true} -- Intercept
    spells_list[72] = {duration = 12, is_success = true} -- Shield Bash
    spells_list[64382] = {duration = 300, is_success = true} -- Shattering Throw
    spells_list[676] = {duration = {60, 40}, has_other_duration=true, is_success = true} -- Disarm
    spells_list[6552] = {duration = 10, is_success = true} -- Pummel
    spells_list[46968] = {duration = 20, is_success = true} -- Shockwave
    spells_list[12809] = {duration = 30, is_success = true} -- Concussion Blow
    spells_list[12976] = {duration = 180, is_success = true} -- Last Stand
    spells_list[60503] = {duration = 9, is_aura = true} -- Taste for Blood
    -- Paladin
    spells_list[25771] = {duration = 120, is_aura = true} -- Forbearance
    spells_list[54428] = {duration = 60, is_success = true} -- Divine Plea
    spells_list[48817] = {duration = 30, is_success = true} -- Holy Wrath
    spells_list[498] = {duration = 180, is_success = true} -- Divine Protection
    spells_list[64205] = {duration = 120, is_success = true} -- Divine Sacrifice
    spells_list[6940] = {duration = 120, is_success = true} -- Hand of Sacrifice
    spells_list[642] = {duration = 300, is_success = true} -- Divine Shield
    spells_list[10308] = {duration = {40, 60, 30}, has_other_duration=true, is_success = true} -- Hammer of Justice
    spells_list[1044] = {duration = 25, is_success = true} -- Hand of Freedom
    spells_list[31884] = {duration = 120, is_success = true} -- Avenging Wrath
    spells_list[10278] = {duration = 180, is_success = true} -- Hand of Protection
    spells_list[20066] = {duration = 60, is_success = true} -- Repentance
    spells_list[31821] = {duration = 120, is_success = true} -- Aura Mastery
    spells_list[31842] = {duration = 180, is_success = true} -- Divine Illumination
    spells_list[48801] = {duration = 15, is_success = true} -- Exorcism
    spells_list[20216] = {duration = 120, is_success = true} -- Divine Favor
    spells_list[48827] = {duration = 30, is_success = true} -- Avenger's Shield
    -- Rogue
    spells_list[8643] = {duration = 20, is_success = true} -- Kidney Shot
    spells_list[51722] = {duration = 60, is_success = true} -- Dismantle
    spells_list[1776] = {duration = 10, is_success = true} -- Gouge
    spells_list[1766] = {duration = 10, is_success = true} -- Kick
    spells_list[2094] = {duration = 120, is_success = true} -- Blind
    spells_list[31224] = {duration = 60, is_success = true} -- Cloak of Shadows
    spells_list[57934] = {duration = 180, is_success = true} -- Tricks of the Trade
    spells_list[51713] = {duration = 60, is_success = true} -- Shadowdance
    spells_list[51690] = {duration = 75, is_success = true} -- Killing Spree
    spells_list[13750] = {duration = 180, is_success = true} -- Adrenaline Rush
    spells_list[26669] = {duration = {180, 180, 120}, has_other_duration=true, is_success = true} -- Evasion
    spells_list[11305] = {duration = {180, 180, 120}, has_other_duration=true, is_success = true} -- Sprint
    spells_list[2094] = {duration = 120, is_success = true} -- Blind
    spells_list[26889] = {duration = 120, is_success = true} -- Vanish
    spells_list[14185] = {duration = {300, 480}, has_other_duration=true, related = {14177, 26889,11305,26669}, is_success = true} -- Preparation
    spells_list[14177] = {duration = 180, is_success = true} -- Cold Blood
    -- Priest
    spells_list[6346] = {duration = 180, is_success = true} -- Fear Ward
    spells_list[33206] = {duration = 144, is_success = true} -- Pain Suppression
    spells_list[10060] = {duration = 96, is_success = true} -- Power Infusion
    spells_list[48173] = {duration = 120, is_success = true} -- Desperate Prayer
    spells_list[64844] = {duration = 480, is_success = true} -- Divine Hymn
    spells_list[64904] = {duration = 360, is_success = true} -- Hymn of Hope
    spells_list[10890] = {duration = {27, 23}, has_other_duration=true, is_success = true} -- Psychic Scream
    spells_list[48158] = {duration = 12, is_success = true} -- SW: Death
    spells_list[15487] = {duration = 45, is_success = true} -- Silence
    spells_list[47585] = {duration = 75, is_success = true} -- Dispresion
    spells_list[64044] = {duration = 120, is_success = true} -- Psychic Horror
    spells_list[34433] = {duration = {300, 180}, has_other_duration=true, is_success = true} -- Shadowfiend
    spells_list[586] = {duration = {30, 15}, has_other_duration=true, is_success = true} -- Fade
    -- Death Knight
    spells_list[47476] = {duration = 120, is_success = true} -- Strangulate
    spells_list[45529] = {duration = 60, is_success = true} -- Blood Tap
    spells_list[48743] = {duration = 120, is_success = true} -- Death Pact
    spells_list[47568] = {duration = 300, is_success = true} -- Empower Rune Weapon
    spells_list[49039] = {duration = 120, is_success = true} -- Lichborne
    spells_list[47528] = {duration = 10, is_success = true} -- Mind Freeze
    spells_list[48792] = {duration = 120, is_success = true} -- Icebound Fortitude
    spells_list[48707] = {duration = 45, is_success = true} -- Anti-Magic Shell
    spells_list[51052] = {duration = 120, is_success = true} -- Anti-Magic Zone
    spells_list[49206] = {duration = 180, is_success = true} -- Summon Gargoyle
    spells_list[49560] = {duration = 25, is_success = true} -- Death Grip
    spells_list[49203] = {duration = 60, is_success = true} -- Hungering Cold
    spells_list[49796] = {duration = 120, is_success = true} -- Deathchill
    spells_list[51271] = {duration = 120, is_success = true} -- Unbreakable Armor
    --Mage
    spells_list[1953] = {duration = 15, is_success = true} -- Blink
    spells_list[2139] = {duration = 24, is_success = true} -- Counterspell
    spells_list[66] = {duration = {180, 180, 126}, has_other_duration=true, is_success = true} -- Invisibility
    spells_list[12051] = {duration = {240, 240, 120}, has_other_duration=true, is_success = true} -- Evocation
    spells_list[55342] = {duration = 180, is_success = true} -- Mirror Image
    spells_list[41425] = {duration = 30, is_aura = true} -- Hypothermia
    spells_list[12042] = {duration = 84, is_success = true} -- Arcane Power
    spells_list[12043] = {duration = 84, is_success = true} -- Presence of Mind
    spells_list[42945] = {duration = 30, is_success = true} -- Blast Wave
    spells_list[42950] = {duration = 20, is_success = true} -- Dragon's Breath
    spells_list[28682] = {duration = 120, is_success = true} -- Combustion
    spells_list[11958] = {duration = 384, related = {44572,42917,42931,43039,12472,31687,45438}, is_success = true} -- COLD SNAP
    spells_list[44572] = {duration = 30, is_success = true} -- Deep Freeze
    spells_list[42917] = {duration = {25, 20, 20}, has_other_duration=true, is_success = true} -- Frost Nova
    spells_list[42931] = {duration = {10, 8, 8}, has_other_duration=true, is_success = true} -- Cone of Cold
    spells_list[43039] = {duration = 24, is_success = true} -- Ice Barrier
    spells_list[12472] = {duration = 144, is_success = true} -- Icy Veins
    spells_list[31687] = {duration = 144, is_success = true} -- Summon Water Elemental
    spells_list[45438] = {duration = {300, 240, 240}, has_other_duration=true, is_success = true} -- Ice Block
    -- Warlock
    spells_list[47860] = {duration = 120, is_success = true} -- Death Coil
    spells_list[17928] = {duration = 40, is_success = true} -- Howl of Terror
    spells_list[48020] = {duration = 30, is_success = true} -- Teleport
    spells_list[18708] = {duration = 180, is_success = true} -- Fel Domination
    spells_list[61290] = {duration = 15, is_success = true} -- Shadowflame
    spells_list[19647] = {duration = 24, is_success = true} -- Spell Lock
    spells_list[59172] = {duration = 12, is_success = true} -- Chaos Bolt
    spells_list[17962] = {duration = 10, is_success = true} -- Conflagrate
    spells_list[47847] = {duration = 20, is_success = true} -- Shadowfury
    spells_list[47827] = {duration = 15, is_success = true} -- Shadowburn
    -- Shaman
    spells_list[51514] = {duration = 45, is_success = true} -- Hex
    spells_list[57994] = {duration = {5.2, 5, 6}, has_other_duration=true, is_success = true} -- Windshear
    spells_list[51533] = {duration = 180, is_success = true} -- Feral Spirit
    spells_list[8177] = {duration = {15, 13.5, 11.5}, has_other_duration=true, is_success = true} -- Grounding Totem
    spells_list[32182] = {duration = 300, is_success = true} -- Heroism
    spells_list[2825] = {duration = 300, is_success = true} -- Bloodlust
    spells_list[30823] = {duration = 60, is_success = true} -- Shamanistic Rage
    spells_list[59159] = {duration = 35, is_success = true} -- Thunderstorm
    spells_list[16190] = {duration = 300, is_success = true} -- Mana Tide Totem
    spells_list[16188] = {duration = 120, is_success = true} -- Nature's Swiftness
    spells_list[55166] = {duration = 180, is_success = true} -- Nature's Force
    spells_list[16166] = {duration = 180, is_success = true} -- Elemental Mastery
    spells_list[55166] = {duration = 180, is_success = true} -- Tidal Force
    -- Druid
    spells_list[22812] = {duration = 60, is_success = true} -- Barkskin
    spells_list[29166] = {duration = 180, is_success = true} -- Innervate
    spells_list[53312] = {duration = 60, is_success = true} -- Nature's Grasp
    spells_list[22842] = {duration = 180, is_success = true} -- Frenzied Regeneration
    spells_list[17116] = {duration = 180, is_success = true} -- Nature's Swiftness
    spells_list[48447] = {duration = 480, is_success = true} -- Tranquility
    spells_list[8983] = {duration = 60, is_success = true} -- Bash
    spells_list[61336] = {duration = 180, is_success = true} -- Survival Instincts
    spells_list[16979] = {duration = 15, is_success = true} -- Feral Charge - Bear
    spells_list[50213] = {duration = 30, is_success = true} -- Tiger's Fury
    spells_list[33831] = {duration = 180, is_success = true} -- Force of Nature
    spells_list[53201] = {duration = 60, is_success = true} -- Starfall
    spells_list[18562] = {duration = 13, is_success = true} -- Swiftmend
    spells_list[50334] = {duration = 180, is_success = true} -- Berserk
    spells_list[53227] = {duration = 20, is_success = true} -- Typhoon
    spells_list[33357] = {duration = 144, is_success = true} -- Dash
    spells_list[5229] = {duration = 60, is_success = true} -- Enrage
    spells_list[69369] = {duration  = 8, is_aura = true} -- Predator's Swiftness
    -- Hunter
    spells_list[34490] = {duration = 20, is_success = true} -- Silencing Shot
    spells_list[23989] = {duration = 180, related = {34490,3045,34026,53271,19263,781,14311,60202,19503,19574,34600}, is_success = true} -- Readiness
    spells_list[3045] = {duration = 300, is_success = true} -- Rapid Fire
    spells_list[34026] = {duration = 60, is_success = true} -- Kill Command
    spells_list[53271] = {duration = 60, is_success = true} -- Master's Call
    spells_list[19263] = {duration = 90, is_success = true} -- Deterrence
    spells_list[781] = {duration = {16, 20}, has_other_duration=true, is_success = true} -- Disengage
    spells_list[14311] = {duration = 28, is_success = true} -- Freezing Trap
    spells_list[60202] = {duration = 28, is_success = true} -- Freezing Arrow
    spells_list[19503] = {duration = 30, is_success = true} -- Scatter Shot
    spells_list[19574] = {duration = 70.2, is_success = true} -- Bestial Wrath
    spells_list[19577] = {duration = 42, is_success = true} -- Intimidation
    spells_list[34600] = {duration = 28, is_success = true} -- Snake Trap
    -- Trinket
    spells_list[71607] = {duration = 120, is_success = true} -- Release of Light
    -- End

    player_spells_list = {}
    --Player Spells
    player_spells_list[57823] = {duration = 5, isSwing = true}
    player_spells_list[60503] = {duration = 9, is_aura = true} -- Taste for Blood
    player_spells_list[1715] = {duration = 15, is_aura = true} -- Hamstring
    player_spells_list[47486] = {duration = 10, is_aura = true} -- Mortal Strike
    player_spells_list[47465] = {duration = 21, is_aura = true} -- Rend
    player_spells_list[47436] = {duration = 360, is_aura = true} -- Battle Shout
    player_spells_list[65156] = {duration = 10, is_aura = true} -- Juggernaut
    player_spells_list[52437] = {duration = 9, is_aura = true} -- Sudden Death
    player_spells_list[59578] = {duration = 14, is_aura = true} -- Art of War
    player_spells_list[54149] = {duration = 14, is_aura = true} -- Infusion of Light
    player_spells_list[64205] = {duration = 10, is_aura = true} -- Divine Sacrifice
    player_spells_list[25771] = {duration = 120, is_aura = true} -- Forbearance
    player_spells_list[31821] = {duration = 6, is_aura = true} -- Aura Mastery
    player_spells_list[53601] = {duration = {60, 30}, has_other_duration = true, is_aura = true} -- Sacred Shield
    player_spells_list[53563] = {duration = 60, is_aura = true} -- Beacon of Light
    player_spells_list[54152] = {duration = 60, is_aura = true} -- Judgements of the Pure
    player_spells_list[6940] = {duration = 12, is_aura = true} -- Hand of Sacrifice
    player_spells_list[48801] = {duration = 15, is_success = true} -- Exorcism
    player_spells_list[20271] = {duration = 10, is_success = true} -- Judgement of Light
    player_spells_list[53407] = {duration = 10, is_success = true} -- Judgement of Justice
    player_spells_list[48817] = {duration = 30, is_success = true} -- Holy Wrath
    player_spells_list[10326] = {duration = 8, is_success = true} -- Turn Evil
    player_spells_list[48806] = {duration = 6, is_success = true} -- Hammer of Wrath
    player_spells_list[48819] = {duration = 8, is_success = true} -- Consecration
    --End

    specs_by_GUID_list = {}
    special_spells_list = {}
    special_spells_list[48821] = 1 -- Holy Paladin
    special_spells_list[53563] = 1 -- Holy Paladin
    special_spells_list[53385] = 2 -- Retribution Paladin
    special_spells_list[35395] = 2 -- Retribution Paladin
    special_spells_list[20066] = 2 -- Retribution Paladin
    special_spells_list[48827] = 3 -- Protection Paladin
    special_spells_list[48952] = 3 -- Protection Paladin
    special_spells_list[53595] = 3 -- Protection Paladin
    special_spells_list[46924] = 1 -- Arms Warrior
    special_spells_list[47486] = 1 -- Arms Warrior
    special_spells_list[65156] = 1 -- Arms Warrior
    special_spells_list[12328] = 1 -- Arms Warrior
    special_spells_list[46968] = 2 -- Protection Warrior
    special_spells_list[47498] = 2 -- Protection Warrior
    special_spells_list[12809] = 2 -- Protection Warrior
    special_spells_list[48660] = 1 -- Subtlety Rogue
    special_spells_list[51713] = 1 -- Subtlety Rogue
    special_spells_list[36554] = 1 -- Subtlety Rogue
    special_spells_list[48666] = 2 -- Assassination Rogue
    special_spells_list[51690] = 3 -- Combat Rogue
    special_spells_list[13750] = 3 -- Combat Rogue
    special_spells_list[48638] = 3 -- Combat Rogue
    special_spells_list[47750] = 1 -- Discipline Priest
    special_spells_list[33206] = 1 -- Discipline Priest
    special_spells_list[10060] = 1 -- Discipline Priest
    special_spells_list[47585] = 2 -- Shadow Priest
    special_spells_list[64044] = 2 -- Shadow Priest
    special_spells_list[15487] = 2 -- Shadow Priest
    special_spells_list[15286] = 2 -- Shadow Priest
    special_spells_list[48160] = 2 -- Shadow Priest
    special_spells_list[15473] = 2 -- Shadow Priest
    special_spells_list[49206] = 1 -- Unholy DK
    special_spells_list[51052] = 1 -- Unholy DK
    special_spells_list[55271] = 1 -- Unholy DK
    special_spells_list[49222] = 1 -- Unholy DK
    special_spells_list[51328] = 1 -- Unholy DK
    special_spells_list[51052] = 1 -- Unholy DK
    special_spells_list[50536] = 1 -- Unholy DK
    special_spells_list[49796] = 2 -- Frost DK
    special_spells_list[49203] = 2 -- Frost DK
    special_spells_list[50436] = 2 -- Frost DK
    special_spells_list[55268] = 2 -- Frost DK
    special_spells_list[42945] = 1 -- Fire Mage
    special_spells_list[42950] = 1 -- Fire Mage
    special_spells_list[55360] = 1 -- Fire Mage
    special_spells_list[28682] = 1 -- Fire Mage
    special_spells_list[11958] = 2 -- Frost Mage
    special_spells_list[44572] = 2 -- Frost Mage
    special_spells_list[31687] = 2 -- Frost Mage
    special_spells_list[43039] = 2 -- Frost Mage
    special_spells_list[44781] = 3 -- Arcane Mage
    special_spells_list[31589] = 3 -- Arcane Mage
    special_spells_list[12042] = 3 -- Arcane Mage
    special_spells_list[12043] = 3 -- Arcane Mage
    special_spells_list[59164] = 1 -- Affliction Warlock
    special_spells_list[47843] = 1 -- Affliction Warlock
    special_spells_list[59172] = 2 -- Destruction Warlock
    special_spells_list[47827] = 2 -- Destruction Warlock
    special_spells_list[47847] = 2 -- Destruction Warlock
    special_spells_list[17962] = 2 -- Destruction Warlock
    special_spells_list[17116] = 1 -- Restoration Druid
    special_spells_list[18562] = 1 -- Restoration Druid
    special_spells_list[53251] = 1 -- Restoration Druid
    special_spells_list[34123] = 1 -- Restoration Druid
    special_spells_list[50334] = 2 -- Feral Druid
    special_spells_list[24932] = 2 -- Feral Druid
    special_spells_list[53201] = 3 -- Balance Druid
    special_spells_list[33831] = 3 -- Balance Druid
    special_spells_list[24858] = 3 -- Balance Druid
    special_spells_list[53227] = 3 -- Balance Druid
    special_spells_list[53209] = 1 -- Marksmanship Hunter
    special_spells_list[34490] = 1 -- Marksmanship Hunter
    special_spells_list[19506] = 1 -- Marksmanship Hunter
    special_spells_list[19574] = 2 -- Beastmastery Hunter
    special_spells_list[19577] = 2 -- Beastmastery Hunter
    special_spells_list[51533] = 1 -- Enhancement Shaman
    special_spells_list[30823] = 1 -- Enhancement Shaman
    special_spells_list[17364] = 1 -- Enhancement Shaman
    special_spells_list[60103] = 1 -- Enhancement Shaman
    special_spells_list[59159] = 2 -- Elemental Shaman
    special_spells_list[57722] = 2 -- Elemental Shaman
    special_spells_list[16166] = 2 -- Elemental Shaman
    special_spells_list[51886] = 3 -- Restoration Shaman
    special_spells_list[16190] = 3 -- Restoration Shaman
    special_spells_list[49284] = 3 -- Restoration Shaman
    special_spells_list[61301] = 3 -- Restoration Shaman
    special_spells_list[16188] = 3 -- Restoration Shaman
end

local function zb_remove_icon(bar, length, id, is_aura, src_guid)
    if is_aura then
        local index = 1
        local found = false
        while index < length do
            if bar[index].id == id and src_guid == bar[index].srcGUID then
                id = index
                found = true
                break
            end
            index = index + 1
        end
        if not found then
            return length
        end  
    end  
    length = length - 1
    local index = id
    while index < length do
        bar[index].id = bar[index+1].id
        bar[index].srcGUID = bar[index+1].srcGUID
        bar[index].duration = bar[index+1].duration
        bar[index].start = bar[index+1].start
        bar[index].cooldown = bar[index+1].cooldown
        bar[index].texture:SetTexture(bar[index+1].texture:GetTexture())
        bar[index].text:SetText(bar[index+1].text:GetText())
        bar[index].cd:SetCooldown(bar[index].start,bar[index].duration)
        index = index + 1
    end
    bar[length]:Hide()
    bar[length].texture:Hide()
    bar[length].text:SetText("") 
    bar[length].cd:Hide()
    return length
end


local function zb_update_text(bar, index)
    if (bar[index].cooldown > 60) then
        bar[index].text:SetText(string.format("%.0fm", floor(bar[index].cooldown/60)))
    elseif (bar[index].cooldown >= 10) then
        bar[index].text:SetText(string.format(" %.0f", floor(bar[index].cooldown)))
    else
        bar[index].text:SetText(string.format("  %.0f", floor(bar[index].cooldown)))
    end
end

local function zb_update_cooldowns(bar, length)
    if length > 1 then
        local index = 1
        local get_time = GetTime()
        while index < length do
            bar[index].cooldown = bar[index].start + bar[index].duration - get_time
            if bar[index].cooldown <= 0 then
                    length = zb_remove_icon(bar, length, index, false)
                    index = index - 1
            else 
                zb_update_text(bar, index)
            end
            index = index + 1
        end
    end
    return length
end

local function zb_on_update(self, elapsed)
    total_time_elapsed = total_time_elapsed + elapsed;
    if total_time_elapsed >= update_interval then
        if length_of_player_bar == 1 and length_of_hostile_bar == 1 and length_of_party_bar == 1 then
            zb_frame:SetScript("OnUpdate",nil)
            return
        end
        length_of_player_bar = zb_update_cooldowns(player_bar, length_of_player_bar)
        length_of_hostile_bar = zb_update_cooldowns(hostile_bar, length_of_hostile_bar)
        length_of_party_bar = zb_update_cooldowns(party_bar, length_of_party_bar)
        total_time_elapsed = 0
    end
end

local function zb_add_icon(bar, length, id, list, refresh, src_guid)
    local duration = 0;
    if list[id].has_other_duration then
        if specs_by_GUID_list[src_guid] then
            if (list[id].duration[specs_by_GUID_list[src_guid]]) then
                duration = list[id].duration[specs_by_GUID_list[src_guid]]
            end
        else
            duration = list[id].duration[1]
        end
    else
        duration = list[id].duration
    end
    local get_time = GetTime()
    if refresh then
        local index = 1
        while index < length do
            if bar[index].id == id and src_guid == bar[index].srcGUID then
                bar[index].start = get_time*2-count_delay_from_start
                bar[index].duration = duration
                bar[index].cooldown = bar[index].start + bar[index].duration - get_time
                bar[index].cd:SetCooldown(bar[index].start,bar[index].duration)
                zb_update_text(bar, index)
                return length
            end
            index = index + 1
        end
    end
    if length < total_buttons then
        bar[length].srcGUID = src_guid
        bar[length].duration = duration

        bar[length].start = get_time*2-count_delay_from_start
        bar[length].cooldown = bar[length].start + bar[length].duration - get_time
        

        bar[length].id = id

        local _,_,icon = GetSpellInfo(id)
        bar[length].texture:SetTexture(icon)
        bar[length].cd:SetCooldown(bar[length].start,bar[length].duration)

        bar[length]:Show()
        bar[length].texture:Show()
        bar[length].cd:Show()
        zb_update_text(bar, length)

        zb_frame:SetScript("OnUpdate", zb_on_update)
        return length + 1
    end
    return length
end

local function zb_event_type(combat_event, bar, length, id, line, src_guid)
    count_delay_from_start = GetTime()
    if line[id].is_aura then
        if combat_event == "SPELL_AURA_APPLIED" then
            return zb_add_icon(bar, length, id, line, false, src_guid)
        elseif combat_event == "SPELL_AURA_REMOVED" then
            return zb_remove_icon(bar, length, id, true, src_guid)
        elseif combat_event == "SPELL_AURA_REFRESH" then
            return zb_add_icon(bar, length, id, line, true, src_guid)
        end
    else
        if combat_event == "SPELL_DAMAGE" and line[id].isDamage then
            return zb_add_icon(bar, length, id, line, false, src_guid)
        elseif combat_event == "SPELL_CAST_SUCCESS" and line[id].is_success then
            return zb_add_icon(bar, length, id, line, false, src_guid)
        elseif (combat_event == "SWING_MISSED" and line[id].isSwing) then
            return zb_add_icon(bar, length, id, line, false, src_guid)
        end
    end
    return length
end

local function zb_combat_log(timestamp, combat_event, src_guid, src_name, src_flags, dst_guid, dst_name, dst_flags, id, name)
    if debugging and (src_guid == (player_guid or UnitGUID("target") or dst_guid == (player_guid or UnitGUID("target")))) then
        print(id)
        print(name)
        print(combat_event)
    end
    if are_bars_being_cleared and is_disabled then
        return
    end
    if special_spells_list[id] then
        specs_by_GUID_list[src_guid] = special_spells_list[id]
    end
    if id == 14185 or id == 23989 or id == 11958 then
        if bit.band(src_flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
            for related_id in pairs(spells_list[id].related) do
                length_of_hostile_bar = zb_remove_icon(hostile_bar, length_of_hostile_bar, related_id, true, src_guid)
            end
        elseif bit.band(src_flags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 then
            for related_id in pairs(spells_list[id].related) do
                length_of_party_bar = zb_remove_icon(party_bar, length_of_party_bar, related_id, true, src_guid)
            end
        end
    end
    if src_guid == player_guid then
        if player_spells_list[id] then 
            if bit.band(dst_flags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 then
                length_of_party_bar = zb_event_type(combat_event, party_bar, length_of_party_bar, id, player_spells_list, src_guid)
            else
                length_of_player_bar = zb_event_type(combat_event, player_bar, length_of_player_bar, id, player_spells_list, src_guid)
            end
        elseif combat_event == "SWING_MISSED" and not id == "MISS" then
            for swing_id in pairs(player_spells_list) do
                if player_spells_list[swing_id].isSwing then
                    length_of_player_bar = zb_event_type(combat_event, player_bar, length_of_player_bar, swing_id, player_spells_list, player_guid)
                end
            end
        end
    elseif spells_list[id] then  
        if bit.band(src_flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0 then
            length_of_hostile_bar = zb_event_type(combat_event, hostile_bar, length_of_hostile_bar, id, spells_list, src_guid)
        elseif bit.band(src_flags, COMBATLOG_OBJECT_AFFILIATION_PARTY) > 0 then
            length_of_party_bar = zb_event_type(combat_event, party_bar, length_of_party_bar, id, spells_list, src_guid)
        end
    end
end

local function zb_initialize_bar(bar, bar_x, bar_y)
    bar = CreateFrame("Frame",nil,UIParent)
    bar:SetWidth(square_size*4)
    bar:SetHeight(square_size)
    bar:SetClampedToScreen(true)
    bar:SetPoint("CENTER", UIParent, "CENTER", bar_x, bar_y)
    local location
    local button
    local cooldown
    local texture
    local text
    local index = 1
    while index < total_buttons do
        location = square_size * index + 5 * index
        button = CreateFrame("Frame",nil,bar)
        button:SetWidth(square_size)
        button:SetHeight(square_size)
        button:SetPoint("CENTER",bar,"CENTER",location,0)
        button:SetFrameStrata("LOW")
        
        cooldown = CreateFrame("Cooldown",nil,button)
        cooldown.noomnicc = true
        cooldown.noCooldownCount = true
        cooldown:SetAllPoints(true)
        cooldown:SetFrameStrata("MEDIUM")
        
        texture = button:CreateTexture(nil,"BACKGROUND")
        texture:SetAllPoints(true)
        texture:SetTexCoord(0.07,0.9,0.07,0.90) 
    
        text = cooldown:CreateFontString(nil,"ARTWORK")
        text:SetFont(STANDARD_TEXT_FONT,20,"OUTLINE")
        text:SetTextColor(1,1,0,1)
        text:SetPoint("LEFT",button,"LEFT",2,0)
        button.texture = texture
        button.text = text
        button.cd = cooldown
        bar[index] = button 
        index = index + 1
    end   
    return bar
end

local function zb_clear_spec_list()
    for character in pairs (specs_by_GUID_list) do
        specs_by_GUID_list[character] = nil
    end
end


local function zb_reset_all(bar, length)
    while length > 1 do
        length = zb_remove_icon(bar, length, 1, false)
    end        
    return length
end

local function zb_entering_world()
    are_bars_being_cleared = true
    length_of_player_bar = zb_reset_all(player_bar, length_of_player_bar)
    length_of_hostile_bar = zb_reset_all(hostile_bar, length_of_hostile_bar)
    length_of_party_bar = zb_reset_all(party_bar, length_of_party_bar)
    zb_clear_spec_list()
    are_bars_being_cleared = false
end

local function zb_commands(sub_string)
    if sub_string == "debug" then
        debugging = not debugging
        if debugging then
            print("Debugging on.")
        else 
            print("Debugging off.")
        end
    elseif sub_string == "clear" then
        zb_entering_world()
    elseif sub_string == "disable" then
        is_disabled = not is_disabled
    else
        print("You can only 'clear' and 'debug'.")
    end
end

local function zb_on_load(self)
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        zb_initialize_variables()
        player_bar = zb_initialize_bar(player_bar, player_bar_x, player_bar_y)
        party_bar = zb_initialize_bar(party_bar, party_bar_x, party_bar_y)
        hostile_bar = zb_initialize_bar(hostile_bar, hostile_bar_x, hostile_bar_y)
        SlashCmdList["ZAKATZIBAR"] = zb_commands
        SLASH_ZAKATZIBAR1 = "/zb"
end

local eventhandler = {
    ["PLAYER_LOGIN"] = function(self) zb_on_load(self) end,
    ["PLAYER_ENTERING_WORLD"] = function(self) zb_entering_world(self) end,
    ["COMBAT_LOG_EVENT_UNFILTERED"] = function(self,...) zb_combat_log(...) end,
}

local function ZB_OnEvent(self,event,...)
	eventhandler[event](self,...)
end

if not zb_frame then 
    CreateFrame("Frame","zb_frame",UIParent)
end
zb_frame:SetScript("OnEvent",ZB_OnEvent)
zb_frame:RegisterEvent("PLAYER_LOGIN")
