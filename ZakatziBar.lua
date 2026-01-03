local addonName, ZB    = ...

ZB                     = ZB or {}
_G[addonName]          = ZB

------------------------------------------------------------------------
-- State
------------------------------------------------------------------------

local squareSize       = 32
local totalIconsPerBar = 15

ZB.frame               = ZB.frame or CreateFrame("Frame", "ZakatziBarFrame", UIParent)
ZB.isDebug             = false
ZB.isDisabled          = false
ZB.trackAll            = true

ZB.updateInterval      = 0.1
ZB.elapsed             = 0

ZB.playerGUID          = UnitGUID("player")
_, ZB.playerClass      = UnitClass("player")

ZB.specByGUID          = ZB.specByGUID or {}

ZB.bars                = {
    player  = { x = -225, y = -225, icons = {}, length = 1 },
    party   = { x = -225, y = -275, icons = {}, length = 1 },
    hostile = { x = -225, y = -325, icons = {}, length = 1 },
}

------------------------------------------------------------------------
-- Spell Data (copied from old file)
------------------------------------------------------------------------

local spells           = {}
local playerSpells     = {}
local specialSpells    = {}

local function InitSpellData()
    -- Warrior
    spells[46924]        = { duration = 90, is_success = true }                                                                                                    -- Bladestorm
    spells[5246]         = { duration = 120, is_success = true }                                                                                                   -- Intimidating Shout
    spells[20230]        = { duration = 300, is_success = true }                                                                                                   -- Retaliation
    spells[1719]         = { duration = 300, is_success = true }                                                                                                   -- Recklessness
    spells[2565]         = { duration = { 60, 40 }, has_other_duration = true, is_success = true }                                                                 -- Shield Block
    spells[871]          = { duration = 300, is_success = true }                                                                                                   -- Shield Wall
    spells[23920]        = { duration = 10, is_success = true }                                                                                                    -- Spell Reflection
    spells[3411]         = { duration = 30, is_success = true }                                                                                                    -- Intervene
    spells[11578]        = { duration = { 20, 15 }, has_other_duration = true, is_success = true }                                                                 -- Charge
    spells[12328]        = { duration = 30, is_success = true }                                                                                                    -- Sweeping Strikes
    spells[18499]        = { duration = 30, is_success = true }                                                                                                    -- Berserker Rage
    spells[55694]        = { duration = 180, is_success = true }                                                                                                   -- Enraged Regeneration
    spells[20252]        = { duration = { 25, 30 }, has_other_duration = true, is_success = true }                                                                 -- Intercept
    spells[72]           = { duration = 12, is_success = true }                                                                                                    -- Shield Bash
    spells[64382]        = { duration = 300, is_success = true }                                                                                                   -- Shattering Throw
    spells[676]          = { duration = { 60, 40 }, has_other_duration = true, is_success = true }                                                                 -- Disarm
    spells[6552]         = { duration = 10, is_success = true }                                                                                                    -- Pummel
    spells[46968]        = { duration = 20, is_success = true }                                                                                                    -- Shockwave
    spells[12809]        = { duration = 30, is_success = true }                                                                                                    -- Concussion Blow
    spells[12976]        = { duration = 180, is_success = true }                                                                                                   -- Last Stand
    spells[60503]        = { duration = 9, is_aura = true }                                                                                                        -- Taste for Blood
    -- Paladin
    spells[25771]        = { duration = 120, is_aura = true }                                                                                                      -- Forbearance
    spells[54428]        = { duration = 60, is_success = true }                                                                                                    -- Divine Plea
    spells[48817]        = { duration = 30, is_success = true }                                                                                                    -- Holy Wrath
    spells[498]          = { duration = 180, is_success = true }                                                                                                   -- Divine Protection
    spells[64205]        = { duration = 120, is_success = true }                                                                                                   -- Divine Sacrifice
    spells[6940]         = { duration = 120, is_success = true }                                                                                                   -- Hand of Sacrifice
    spells[642]          = { duration = 300, is_success = true }                                                                                                   -- Divine Shield
    spells[10308]        = { duration = { 40, 60, 30 }, has_other_duration = true, is_success = true }                                                             -- Hammer of Justice
    spells[1044]         = { duration = 25, is_success = true }                                                                                                    -- Hand of Freedom
    spells[31884]        = { duration = 120, is_success = true }                                                                                                   -- Avenging Wrath
    spells[10278]        = { duration = 180, is_success = true }                                                                                                   -- Hand of Protection
    spells[20066]        = { duration = 60, is_success = true }                                                                                                    -- Repentance
    spells[31821]        = { duration = 120, is_success = true }                                                                                                   -- Aura Mastery
    spells[31842]        = { duration = 180, is_success = true }                                                                                                   -- Divine Illumination
    spells[48801]        = { duration = 15, is_success = true }                                                                                                    -- Exorcism
    spells[20216]        = { duration = 120, is_success = true }                                                                                                   -- Divine Favor
    spells[48827]        = { duration = 30, is_success = true }                                                                                                    -- Avenger's Shield
    -- Rogue
    spells[8643]         = { duration = 20, is_success = true }                                                                                                    -- Kidney Shot
    spells[51722]        = { duration = 60, is_success = true }                                                                                                    -- Dismantle
    spells[1776]         = { duration = 10, is_success = true }                                                                                                    -- Gouge
    spells[1766]         = { duration = 10, is_success = true }                                                                                                    -- Kick
    spells[2094]         = { duration = 120, is_success = true }                                                                                                   -- Blind
    spells[31224]        = { duration = 60, is_success = true }                                                                                                    -- Cloak of Shadows
    spells[57934]        = { duration = 180, is_success = true }                                                                                                   -- Tricks of the Trade
    spells[51713]        = { duration = 60, is_success = true }                                                                                                    -- Shadowdance
    spells[51690]        = { duration = 75, is_success = true }                                                                                                    -- Killing Spree
    spells[13750]        = { duration = 180, is_success = true }                                                                                                   -- Adrenaline Rush
    spells[26669]        = { duration = { 180, 180, 120 }, has_other_duration = true, is_success = true }                                                          -- Evasion
    spells[11305]        = { duration = { 180, 180, 120 }, has_other_duration = true, is_success = true }                                                          -- Sprint
    spells[2094]         = { duration = 120, is_success = true }                                                                                                   -- Blind
    spells[26889]        = { duration = 120, is_success = true }                                                                                                   -- Vanish
    spells[14185]        = { duration = { 300, 480 }, has_other_duration = true, related = { 1766, 51722, 14177, 26889, 11305, 26669, 36554 }, is_success = true } -- Preparation
    spells[14177]        = { duration = 180, is_success = true }                                                                                                   -- Cold Blood
    spells[36554]        = { duration = 30, is_success = true }                                                                                                    -- Shadowstep
    -- Priest
    spells[6346]         = { duration = 180, is_success = true }                                                                                                   -- Fear Ward
    spells[33206]        = { duration = 144, is_success = true }                                                                                                   -- Pain Suppression
    spells[10060]        = { duration = 96, is_success = true }                                                                                                    -- Power Infusion
    spells[48173]        = { duration = 120, is_success = true }                                                                                                   -- Desperate Prayer
    spells[64844]        = { duration = 480, is_success = true }                                                                                                   -- Divine Hymn
    spells[64904]        = { duration = 360, is_success = true }                                                                                                   -- Hymn of Hope
    spells[10890]        = { duration = { 27, 23 }, has_other_duration = true, is_success = true }                                                                 -- Psychic Scream
    spells[48158]        = { duration = 12, is_success = true }                                                                                                    -- SW: Death
    spells[15487]        = { duration = 45, is_success = true }                                                                                                    -- Silence
    spells[47585]        = { duration = 75, is_success = true }                                                                                                    -- Dispresion
    spells[64044]        = { duration = 120, is_success = true }                                                                                                   -- Psychic Horror
    spells[34433]        = { duration = { 300, 180 }, has_other_duration = true, is_success = true }                                                               -- Shadowfiend
    spells[586]          = { duration = { 30, 15 }, has_other_duration = true, is_success = true }                                                                 -- Fade
    -- Death Knight
    spells[47476]        = { duration = 120, is_success = true }                                                                                                   -- Strangulate
    spells[45529]        = { duration = 60, is_success = true }                                                                                                    -- Blood Tap
    spells[48743]        = { duration = 120, is_success = true }                                                                                                   -- Death Pact
    spells[47568]        = { duration = 300, is_success = true }                                                                                                   -- Empower Rune Weapon
    spells[49039]        = { duration = 120, is_success = true }                                                                                                   -- Lichborne
    spells[47528]        = { duration = 10, is_success = true }                                                                                                    -- Mind Freeze
    spells[48792]        = { duration = 120, is_success = true }                                                                                                   -- Icebound Fortitude
    spells[48707]        = { duration = 45, is_success = true }                                                                                                    -- Anti-Magic Shell
    spells[51052]        = { duration = 120, is_success = true }                                                                                                   -- Anti-Magic Zone
    spells[49206]        = { duration = 180, is_success = true }                                                                                                   -- Summon Gargoyle
    spells[49560]        = { duration = 25, is_success = true }                                                                                                    -- Death Grip
    spells[49203]        = { duration = 60, is_success = true }                                                                                                    -- Hungering Cold
    spells[49796]        = { duration = 120, is_success = true }                                                                                                   -- Deathchill
    spells[51271]        = { duration = 120, is_success = true }                                                                                                   -- Unbreakable Armor
    --Mage
    spells[1953]         = { duration = 15, is_success = true }                                                                                                    -- Blink
    spells[2139]         = { duration = 24, is_success = true }                                                                                                    -- Counterspell
    spells[66]           = { duration = { 180, 180, 126 }, has_other_duration = true, is_success = true }                                                          -- Invisibility
    spells[12051]        = { duration = { 240, 240, 120 }, has_other_duration = true, is_success = true }                                                          -- Evocation
    spells[55342]        = { duration = 180, is_success = true }                                                                                                   -- Mirror Image
    spells[41425]        = { duration = 30, is_aura = true }                                                                                                       -- Hypothermia
    spells[12042]        = { duration = 84, is_success = true }                                                                                                    -- Arcane Power
    spells[12043]        = { duration = 84, is_success = true }                                                                                                    -- Presence of Mind
    spells[42945]        = { duration = 30, is_success = true }                                                                                                    -- Blast Wave
    spells[42950]        = { duration = 20, is_success = true }                                                                                                    -- Dragon's Breath
    spells[28682]        = { duration = 120, is_success = true }                                                                                                   -- Combustion
    spells[11958]        = { duration = 384, related = { 44572, 42917, 42931, 43039, 12472, 31687, 45438 }, is_success = true }                                    -- COLD SNAP
    spells[44572]        = { duration = 30, is_success = true }                                                                                                    -- Deep Freeze
    spells[42917]        = { duration = { 25, 20, 20 }, has_other_duration = true, is_success = true }                                                             -- Frost Nova
    spells[42931]        = { duration = { 10, 8, 8 }, has_other_duration = true, is_success = true }                                                               -- Cone of Cold
    spells[43039]        = { duration = 24, is_success = true }                                                                                                    -- Ice Barrier
    spells[12472]        = { duration = 144, is_success = true }                                                                                                   -- Icy Veins
    spells[31687]        = { duration = 144, is_success = true }                                                                                                   -- Summon Water Elemental
    spells[45438]        = { duration = { 300, 240, 240 }, has_other_duration = true, is_success = true }                                                          -- Ice Block
    -- Warlock
    spells[47860]        = { duration = 120, is_success = true }                                                                                                   -- Death Coil
    spells[17928]        = { duration = 40, is_success = true }                                                                                                    -- Howl of Terror
    spells[48020]        = { duration = 30, is_success = true }                                                                                                    -- Teleport
    spells[18708]        = { duration = 180, is_success = true }                                                                                                   -- Fel Domination
    spells[61290]        = { duration = 15, is_success = true }                                                                                                    -- Shadowflame
    spells[19647]        = { duration = 24, is_success = true }                                                                                                    -- Spell Lock
    spells[59172]        = { duration = 12, is_success = true }                                                                                                    -- Chaos Bolt
    spells[17962]        = { duration = 10, is_success = true }                                                                                                    -- Conflagrate
    spells[47847]        = { duration = 20, is_success = true }                                                                                                    -- Shadowfury
    spells[47827]        = { duration = 15, is_success = true }                                                                                                    -- Shadowburn
    -- Shaman
    spells[51514]        = { duration = 45, is_success = true }                                                                                                    -- Hex
    spells[57994]        = { duration = { 5.2, 5, 6 }, has_other_duration = true, is_success = true }                                                              -- Windshear
    spells[51533]        = { duration = 180, is_success = true }                                                                                                   -- Feral Spirit
    spells[8177]         = { duration = { 15, 13.5, 11.5 }, has_other_duration = true, is_success = true }                                                         -- Grounding Totem
    spells[32182]        = { duration = 300, is_success = true }                                                                                                   -- Heroism
    spells[2825]         = { duration = 300, is_success = true }                                                                                                   -- Bloodlust
    spells[30823]        = { duration = 60, is_success = true }                                                                                                    -- Shamanistic Rage
    spells[59159]        = { duration = 35, is_success = true }                                                                                                    -- Thunderstorm
    spells[16190]        = { duration = 300, is_success = true }                                                                                                   -- Mana Tide Totem
    spells[16188]        = { duration = 120, is_success = true }                                                                                                   -- Nature's Swiftness
    spells[55166]        = { duration = 180, is_success = true }                                                                                                   -- Nature's Force
    spells[16166]        = { duration = 180, is_success = true }                                                                                                   -- Elemental Mastery
    spells[55166]        = { duration = 180, is_success = true }                                                                                                   -- Tidal Force
    -- Druid
    spells[22812]        = { duration = 60, is_success = true }                                                                                                    -- Barkskin
    spells[29166]        = { duration = 180, is_success = true }                                                                                                   -- Innervate
    spells[53312]        = { duration = 60, is_success = true }                                                                                                    -- Nature's Grasp
    spells[22842]        = { duration = 180, is_success = true }                                                                                                   -- Frenzied Regeneration
    spells[17116]        = { duration = 180, is_success = true }                                                                                                   -- Nature's Swiftness
    spells[48447]        = { duration = 480, is_success = true }                                                                                                   -- Tranquility
    spells[8983]         = { duration = 60, is_success = true }                                                                                                    -- Bash
    spells[61336]        = { duration = 180, is_success = true }                                                                                                   -- Survival Instincts
    spells[16979]        = { duration = 15, is_success = true }                                                                                                    -- Feral Charge - Bear
    spells[50213]        = { duration = 30, is_success = true }                                                                                                    -- Tiger's Fury
    spells[33831]        = { duration = 180, is_success = true }                                                                                                   -- Force of Nature
    spells[53201]        = { duration = 60, is_success = true }                                                                                                    -- Starfall
    spells[18562]        = { duration = 13, is_success = true }                                                                                                    -- Swiftmend
    spells[50334]        = { duration = 180, is_success = true }                                                                                                   -- Berserk
    spells[53227]        = { duration = 20, is_success = true }                                                                                                    -- Typhoon
    spells[33357]        = { duration = 144, is_success = true }                                                                                                   -- Dash
    spells[5229]         = { duration = 60, is_success = true }                                                                                                    -- Enrage
    spells[69369]        = { duration = 8, is_aura = true }                                                                                                        -- Predator's Swiftness
    -- Hunter
    spells[34490]        = { duration = 20, is_success = true }                                                                                                    -- Silencing Shot
    spells[23989]        = { duration = 180, related = { 34490, 3045, 34026, 53271, 19263, 781, 14311, 60202, 19503, 19574, 34600 }, is_success = true }           -- Readiness
    spells[3045]         = { duration = 300, is_success = true }                                                                                                   -- Rapid Fire
    spells[34026]        = { duration = 60, is_success = true }                                                                                                    -- Kill Command
    spells[53271]        = { duration = 60, is_success = true }                                                                                                    -- Master's Call
    spells[19263]        = { duration = 90, is_success = true }                                                                                                    -- Deterrence
    spells[781]          = { duration = { 16, 20 }, has_other_duration = true, is_success = true }                                                                 -- Disengage
    spells[14311]        = { duration = 28, is_success = true }                                                                                                    -- Freezing Trap
    spells[60202]        = { duration = 28, is_success = true }                                                                                                    -- Freezing Arrow
    spells[19503]        = { duration = 30, is_success = true }                                                                                                    -- Scatter Shot
    spells[19574]        = { duration = 70.2, is_success = true }                                                                                                  -- Bestial Wrath
    spells[19577]        = { duration = 42, is_success = true }                                                                                                    -- Intimidation
    spells[34600]        = { duration = 28, is_success = true }                                                                                                    -- Snake Trap
    -- Trinket
    spells[71607]        = { duration = 120, is_success = true }                                                                                                   -- Release of Light

    -- Player spells
    playerSpells[57823]  = {
        duration = 5,
        is_swing = true,
        swing_types = { "DODGE", "PARRY", "BLOCK" },
        class =
        "WARRIOR"
    }                                                                                           -- Revenge
    playerSpells[60503]  = { duration = 9, is_aura = true }                                     -- Taste for Blood
    playerSpells[1715]   = { duration = 15, is_aura = true }                                    -- Hamstring
    playerSpells[47486]  = { duration = 10, is_aura = true }                                    -- Mortal Strike
    playerSpells[47465]  = { duration = 21, is_aura = true }                                    -- Rend
    playerSpells[47436]  = { duration = 360, is_aura = true }                                   -- Battle Shout
    playerSpells[65156]  = { duration = 10, is_aura = true }                                    -- Juggernaut
    playerSpells[52437]  = { duration = 9, is_aura = true }                                     -- Sudden Death
    playerSpells[59578]  = { duration = 14, is_aura = true }                                    -- Art of War
    playerSpells[54149]  = { duration = 14, is_aura = true }                                    -- Infusion of Light
    playerSpells[64205]  = { duration = 10, is_aura = true }                                    -- Divine Sacrifice
    playerSpells[25771]  = { duration = 120, is_aura = true }                                   -- Forbearance
    playerSpells[31821]  = { duration = 6, is_aura = true }                                     -- Aura Mastery
    playerSpells[53601]  = { duration = { 60, 30 }, has_other_duration = true, is_aura = true } -- Sacred Shield
    playerSpells[53563]  = { duration = 60, is_aura = true }                                    -- Beacon of Light
    playerSpells[54152]  = { duration = 60, is_aura = true }                                    -- Judgements of the Pure
    playerSpells[6940]   = { duration = 12, is_aura = true }                                    -- Hand of Sacrifice
    playerSpells[48801]  = { duration = 15, is_success = true }                                 -- Exorcism
    playerSpells[20271]  = { duration = 10, is_success = true }                                 -- Judgement of Light
    playerSpells[53407]  = { duration = 10, is_success = true }                                 -- Judgement of Justice
    playerSpells[48817]  = { duration = 30, is_success = true }                                 -- Holy Wrath
    playerSpells[10326]  = { duration = 8, is_success = true }                                  -- Turn Evil
    playerSpells[48806]  = { duration = 6, is_success = true }                                  -- Hammer of Wrath
    playerSpells[48819]  = { duration = 8, is_success = true }                                  -- Consecration
    playerSpells[51713]  = { duration = 8, is_aura = true }                                     -- Shadowdance
    playerSpells[1766]   = { duration = 10, is_success = true }                                 -- Kick

    -- Spec detection
    specialSpells[48821] = 1 -- Holy Paladin
    specialSpells[53563] = 1 -- Holy Paladin
    specialSpells[53385] = 2 -- Retribution Paladin
    specialSpells[35395] = 2 -- Retribution Paladin
    specialSpells[20066] = 2 -- Retribution Paladin
    specialSpells[48827] = 3 -- Protection Paladin
    specialSpells[48952] = 3 -- Protection Paladin
    specialSpells[53595] = 3 -- Protection Paladin
    specialSpells[46924] = 1 -- Arms Warrior
    specialSpells[47486] = 1 -- Arms Warrior
    specialSpells[65156] = 1 -- Arms Warrior
    specialSpells[12328] = 1 -- Arms Warrior
    specialSpells[46968] = 2 -- Protection Warrior
    specialSpells[47498] = 2 -- Protection Warrior
    specialSpells[12809] = 2 -- Protection Warrior
    specialSpells[48660] = 1 -- Subtlety Rogue
    specialSpells[51713] = 1 -- Subtlety Rogue
    specialSpells[36554] = 1 -- Subtlety Rogue
    specialSpells[48666] = 2 -- Assassination Rogue
    specialSpells[51690] = 3 -- Combat Rogue
    specialSpells[13750] = 3 -- Combat Rogue
    specialSpells[48638] = 3 -- Combat Rogue
    specialSpells[47750] = 1 -- Discipline Priest
    specialSpells[33206] = 1 -- Discipline Priest
    specialSpells[10060] = 1 -- Discipline Priest
    specialSpells[47585] = 2 -- Shadow Priest
    specialSpells[64044] = 2 -- Shadow Priest
    specialSpells[15487] = 2 -- Shadow Priest
    specialSpells[15286] = 2 -- Shadow Priest
    specialSpells[48160] = 2 -- Shadow Priest
    specialSpells[15473] = 2 -- Shadow Priest
    specialSpells[49206] = 1 -- Unholy DK
    specialSpells[51052] = 1 -- Unholy DK
    specialSpells[55271] = 1 -- Unholy DK
    specialSpells[49222] = 1 -- Unholy DK
    specialSpells[51328] = 1 -- Unholy DK
    specialSpells[51052] = 1 -- Unholy DK
    specialSpells[50536] = 1 -- Unholy DK
    specialSpells[49796] = 2 -- Frost DK
    specialSpells[49203] = 2 -- Frost DK
    specialSpells[50436] = 2 -- Frost DK
    specialSpells[55268] = 2 -- Frost DK
    specialSpells[42945] = 1 -- Fire Mage
    specialSpells[42950] = 1 -- Fire Mage
    specialSpells[55360] = 1 -- Fire Mage
    specialSpells[28682] = 1 -- Fire Mage
    specialSpells[11958] = 2 -- Frost Mage
    specialSpells[44572] = 2 -- Frost Mage
    specialSpells[31687] = 2 -- Frost Mage
    specialSpells[43039] = 2 -- Frost Mage
    specialSpells[44781] = 3 -- Arcane Mage
    specialSpells[31589] = 3 -- Arcane Mage
    specialSpells[12042] = 3 -- Arcane Mage
    specialSpells[12043] = 3 -- Arcane Mage
    specialSpells[59164] = 1 -- Affliction Warlock
    specialSpells[47843] = 1 -- Affliction Warlock
    specialSpells[59172] = 2 -- Destruction Warlock
    specialSpells[47827] = 2 -- Destruction Warlock
    specialSpells[47847] = 2 -- Destruction Warlock
    specialSpells[17962] = 2 -- Destruction Warlock
    specialSpells[17116] = 1 -- Restoration Druid
    specialSpells[18562] = 1 -- Restoration Druid
    specialSpells[53251] = 1 -- Restoration Druid
    specialSpells[34123] = 1 -- Restoration Druid
    specialSpells[50334] = 2 -- Feral Druid
    specialSpells[24932] = 2 -- Feral Druid
    specialSpells[53201] = 3 -- Balance Druid
    specialSpells[33831] = 3 -- Balance Druid
    specialSpells[24858] = 3 -- Balance Druid
    specialSpells[53227] = 3 -- Balance Druid
    specialSpells[53209] = 1 -- Marksmanship Hunter
    specialSpells[34490] = 1 -- Marksmanship Hunter
    specialSpells[19506] = 1 -- Marksmanship Hunter
    specialSpells[19574] = 2 -- Beastmastery Hunter
    specialSpells[19577] = 2 -- Beastmastery Hunter
    specialSpells[51533] = 1 -- Enhancement Shaman
    specialSpells[30823] = 1 -- Enhancement Shaman
    specialSpells[17364] = 1 -- Enhancement Shaman
    specialSpells[60103] = 1 -- Enhancement Shaman
    specialSpells[59159] = 2 -- Elemental Shaman
    specialSpells[57722] = 2 -- Elemental Shaman
    specialSpells[16166] = 2 -- Elemental Shaman
    specialSpells[51886] = 3 -- Restoration Shaman
    specialSpells[16190] = 3 -- Restoration Shaman
    specialSpells[49284] = 3 -- Restoration Shaman
    specialSpells[61301] = 3 -- Restoration Shaman
    specialSpells[16188] = 3 -- Restoration Shaman
end

------------------------------------------------------------------------
-- Helpers
------------------------------------------------------------------------

local bit_band = bit.band

local function IsMine(flags)
    return bit_band(flags, COMBATLOG_OBJECT_AFFILIATION_MINE) > 0
end

local function IsHostile(flags)
    return bit_band(flags, COMBATLOG_OBJECT_REACTION_HOSTILE) > 0
end

local function IsInParty(guid)
    for i = 1, 4 do
        if UnitGUID("party" .. i) == guid then
            return true
        end
    end
    return false
end

local function GetDurationFor(list, spellID, srcGUID)
    local info = list[spellID]
    if not info then return nil end

    local dur = info.duration
    if type(dur) == "table" then
        local spec = ZB.specByGUID[srcGUID]
        if spec and dur[spec] then
            return dur[spec]
        else
            return dur[1]
        end
    end
    return dur
end

local function FormatSeconds(sec)
    if not sec or sec <= 0 then return "" end
    return tostring(math.floor(sec + 0.5))
end

local function UpdateIconText(icon)
    local t = icon.cooldown or 0
    if t <= 0 then
        icon.text:SetText("")
        return
    end

    local fontSize = (t < 10) and 24 or 20
    local r, g, b = 1, 1, 0
    if t < 10 then
        r, g, b = 1, 0, 0
    end

    icon.text:SetFont(STANDARD_TEXT_FONT, fontSize, "OUTLINE")
    icon.text:SetTextColor(r, g, b, 1)

    if t > 60 then
        icon.text:SetText(string.format("%.0fm", math.floor(t / 60)))
    else
        icon.text:SetText(FormatSeconds(t))
    end
end

------------------------------------------------------------------------
-- Bar / Icon creation
------------------------------------------------------------------------

function ZB:CreateBar(key)
    local cfg = self.bars[key]
    local bar = CreateFrame("Frame", nil, UIParent)
    bar:SetSize(squareSize * 4, squareSize)
    bar:SetPoint("CENTER", UIParent, "CENTER", cfg.x, cfg.y)
    bar:SetClampedToScreen(true)
    bar.icons  = {}
    cfg.frame  = bar
    cfg.length = 1

    for i = 1, totalIconsPerBar do
        local icon = CreateFrame("Frame", nil, bar)
        icon:SetSize(squareSize, squareSize)
        icon:SetPoint("LEFT", bar, "LEFT", (i - 1) * (squareSize + 5), 0)
        icon:SetFrameStrata("MEDIUM")

        -- Black border background
        local border = icon:CreateTexture(nil, "BACKGROUND")
        border:SetPoint("TOPLEFT", icon, "TOPLEFT", -1, 1)
        border:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
        border:SetTexture(0, 0, 0, 1) -- r, g, b, a in 0–1 on 3.3.5
        icon.border = border

        local tex = icon:CreateTexture(nil, "ARTWORK")
        tex:SetAllPoints()
        tex:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon.texture = tex

        local cd = CreateFrame("Cooldown", nil, icon, "CooldownFrameTemplate")
        cd:SetAllPoints()
        cd:SetFrameStrata("HIGH")
        cd.noomnicc = true
        cd.noCooldownCount = true

        local text = cd:CreateFontString(nil, "ARTWORK")
        text:SetPoint("CENTER", icon, "CENTER", 0, -2)
        text:SetFont(STANDARD_TEXT_FONT, 20, "OUTLINE")
        text:SetTextColor(1, 1, 0, 1)

        local ag = icon:CreateAnimationGroup()
        local fadeOut = ag:CreateAnimation("Alpha")
        fadeOut:SetDuration(0.5)
        fadeOut:SetChange(-1)
        fadeOut:SetOrder(1)
        local fadeIn = ag:CreateAnimation("Alpha")
        fadeIn:SetDuration(0.5)
        fadeIn:SetChange(1)
        fadeIn:SetOrder(2)
        ag:SetLooping("REPEAT")

        icon.texture   = tex
        icon.cd        = cd
        icon.text      = text
        icon.flasher   = ag
        icon.isPlaying = false

        icon:Hide()
        bar.icons[i] = icon
    end
end

local function RemoveIcon(barCfg, index)
    local bar    = barCfg.frame
    local icons  = bar.icons
    local length = barCfg.length

    if index >= length then return end

    for i = index, length - 2 do
        local src      = icons[i + 1]
        local dst      = icons[i]

        dst.id         = src.id
        dst.srcGUID    = src.srcGUID
        dst.dstGUID    = src.dstGUID
        dst.duration   = src.duration
        dst.startTime  = src.startTime
        dst.cooldown   = src.cooldown
        dst.hasCharges = src.hasCharges

        dst.texture:SetTexture(src.texture:GetTexture())
        dst.cd:SetCooldown(dst.startTime, dst.duration)
        dst.text:SetText(src.text:GetText())
    end

    local last = icons[length - 1]
    last:Hide()
    last.flasher:Stop()
    last.isPlaying = false
    last.text:SetText("")
    last.id         = nil
    last.srcGUID    = nil
    last.dstGUID    = nil
    last.duration   = nil
    last.startTime  = nil
    last.cooldown   = nil
    last.hasCharges = nil

    barCfg.length   = length - 1
end

local function OnUpdate(elapsed)
    ZB.elapsed = ZB.elapsed + elapsed
    if ZB.elapsed < ZB.updateInterval then return end
    ZB.elapsed = 0

    local active = (ZB.bars.player.length - 1) +
        (ZB.bars.party.length - 1) +
        (ZB.bars.hostile.length - 1)

    if active == 0 then
        ZB.frame:SetScript("OnUpdate", nil)
        return
    end

    ZB:UpdateBar(ZB.bars.player, playerSpells)
    ZB:UpdateBar(ZB.bars.hostile, spells)
    ZB:UpdateBar(ZB.bars.party, spells)
end

local function AddOrRefreshIcon(barCfg, spellID, list, srcGUID, dstGUID)
    local bar    = barCfg.frame
    local icons  = bar.icons
    local now    = GetTime()
    local length = barCfg.length
    local data   = list[spellID]
    if not data then return end

    -- refresh
    for i = 1, length - 1 do
        local icon = icons[i]
        if icon.id == spellID and icon.srcGUID == srcGUID and
            (not dstGUID or icon.dstGUID == dstGUID or icon.dstGUID == nil) then
            if data.has_charges and icon.hasCharges and icon.hasCharges > 0 then
                icon.hasCharges = icon.hasCharges - 1
            else
                icon.duration  = GetDurationFor(list, spellID, srcGUID)
                icon.startTime = now
                icon.cooldown  = icon.duration
                icon.cd:SetCooldown(icon.startTime, icon.duration)
            end

            icon.flasher:Play()
            icon.isPlaying = true
            UpdateIconText(icon)
            return
        end
    end

    -- new
    if length > totalIconsPerBar then return end

    local icon      = icons[length]
    icon.id         = spellID
    icon.srcGUID    = srcGUID
    icon.dstGUID    = dstGUID
    icon.duration   = GetDurationFor(list, spellID, srcGUID)
    icon.startTime  = now
    icon.cooldown   = icon.duration
    icon.hasCharges = data.has_charges and (data.has_charges - 1) or nil

    local _, _, tex = GetSpellInfo(spellID)
    icon.texture:SetTexture(tex or "")
    icon.cd:SetCooldown(icon.startTime, icon.duration)

    icon:Show()
    icon.flasher:Play()
    icon.isPlaying = true
    UpdateIconText(icon)

    barCfg.length = length + 1
    ZB.frame:SetScript("OnUpdate", function(_, elapsed) OnUpdate(elapsed) end)
end

------------------------------------------------------------------------
-- Cooldown updates
------------------------------------------------------------------------

function ZB:UpdateBar(barCfg, list)
    local bar = barCfg.frame
    if not bar then return end

    local icons = bar.icons
    local now   = GetTime()
    local i     = 1

    while i < barCfg.length do
        local icon = icons[i]
        icon.cooldown = icon.startTime + icon.duration - now

        if icon.cooldown <= 0 then
            local data = list[icon.id]
            if data and data.has_charges and icon.hasCharges < data.has_charges then
                icon.hasCharges = icon.hasCharges + 1
                icon.duration   = GetDurationFor(list, icon.id, icon.srcGUID)
                icon.startTime  = now
                icon.cooldown   = icon.duration
                icon.cd:SetCooldown(icon.startTime, icon.duration)
                UpdateIconText(icon)
                i = i + 1
            else
                RemoveIcon(barCfg, i)
            end
        else
            UpdateIconText(icon)
            if now - icon.startTime >= 1.9 and icon.isPlaying then
                icon.isPlaying = false
                icon.flasher:Stop()
            end
            i = i + 1
        end
    end
end

------------------------------------------------------------------------
-- Combat log handling
------------------------------------------------------------------------

local function HandleSpecDetection(spellID, srcGUID)
    local spec = specialSpells[spellID]
    if spec then
        ZB.specByGUID[srcGUID] = spec
    end
end

local function RemoveBySpell(barCfg, spellID, srcGUID)
    local bar   = barCfg.frame
    local icons = bar.icons
    local i     = 1

    while i < barCfg.length do
        local icon = icons[i]
        if icon.id == spellID and icon.srcGUID == srcGUID then
            RemoveIcon(barCfg, i)
        else
            i = i + 1
        end
    end
end

local function HandleResetSpells(spellID, srcGUID, srcFlags)
    if spellID ~= 14185 and spellID ~= 23989 and spellID ~= 11958 then
        return
    end
    local data = spells[spellID]
    if not data or not data.related then return end

    if IsHostile(srcFlags) then
        for relatedID in pairs(data.related) do
            RemoveBySpell(ZB.bars.hostile, relatedID, srcGUID)
        end
    elseif IsInParty(srcGUID) then
        for relatedID in pairs(data.related) do
            RemoveBySpell(ZB.bars.party, relatedID, srcGUID)
        end
    end
end

local function HandlePlayerSpell(subEvent, spellID, srcGUID, dstGUID)
    local info = playerSpells[spellID]
    if not info then return end
    local targetBar = IsInParty(dstGUID) and ZB.bars.party or ZB.bars.player
    if info.is_aura then
        if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
            AddOrRefreshIcon(targetBar, spellID, playerSpells, srcGUID, dstGUID)
        elseif subEvent == "SPELL_AURA_REMOVED" then
            RemoveBySpell(targetBar, spellID, srcGUID)
        end
    elseif subEvent == "SPELL_CAST_SUCCESS" and info.is_success then
        AddOrRefreshIcon(targetBar, spellID, playerSpells, srcGUID, dstGUID)
    end
end

local function HandleOtherSpell(subEvent, spellID, srcGUID, srcFlags, dstGUID)
    local info = spells[spellID]
    if not info then return end

    local barCfg
    if IsHostile(srcFlags) then
        barCfg = ZB.bars.hostile
    elseif IsInParty(srcGUID) then
        barCfg = ZB.bars.party
    end
    if not barCfg then return end

    if info.is_aura then
        if subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" then
            AddOrRefreshIcon(barCfg, spellID, spells, srcGUID, dstGUID)
        elseif subEvent == "SPELL_AURA_REMOVED" then
            RemoveBySpell(barCfg, spellID, srcGUID)
        end
    elseif subEvent == "SPELL_CAST_SUCCESS" and info.is_success then
        AddOrRefreshIcon(barCfg, spellID, spells, srcGUID, dstGUID)
    elseif subEvent == "SPELL_DAMAGE" and info.isDamage then
        AddOrRefreshIcon(barCfg, spellID, spells, srcGUID, dstGUID)
    end
end

local function PrunePartyIcons()
    local barCfg = ZB.bars.party
    local bar    = barCfg.frame
    if not bar then return end

    local icons = bar.icons
    local i     = 1

    while i < barCfg.length do
        local icon  = icons[i]
        local src   = icon.srcGUID
        local dst   = icon.dstGUID

        local srcOk = (not src) or IsInParty(src)
        local dstOk = (not dst) or IsInParty(dst)

        -- if either GUID is explicitly non-party and not nil, drop the icon
        if (src and not srcOk) or (dst and not dstOk) then
            RemoveIcon(barCfg, i)
        else
            i = i + 1
        end
    end
end
local function OnCombatLog(...)
    local _, subEvent, _, srcName, srcGUID, srcFlags,
    dstName, dstGUID, spellID, spellName, _ = ...
    if ZB.isDebug and srcGUID == (ZB.playerGUID or UnitGUID("target")) then
        print(spellID, spellName, subEvent)
    end

    if ZB.isDisabled or (not ZB.trackAll and srcGUID == (ZB.playerGUID or UnitGUID("target"))) then
        return
    end

    if spellID and specialSpells[spellID] then
        HandleSpecDetection(spellID, srcGUID)
    end

    HandleResetSpells(spellID, srcGUID, srcFlags)

    if IsMine(srcFlags) then
        HandlePlayerSpell(subEvent, spellID, srcGUID, dstGUID)
    elseif spells[spellID] then
        HandleOtherSpell(subEvent, spellID, srcGUID, srcFlags, dstGUID)
    end
end

------------------------------------------------------------------------
-- Commands and events
------------------------------------------------------------------------

-- when starting OnUpdate
ZB.frame:SetScript("OnUpdate", function(_, elapsed)
    OnUpdate(elapsed)
end)

local function ClearAll()
    for _, key in ipairs({ "player", "party", "hostile" }) do
        local cfg = ZB.bars[key]
        while cfg.length > 1 do
            RemoveIcon(cfg, 1)
        end
    end
    wipe(ZB.specByGUID)
end
local function cprint(msg, arg1)
    if arg1 == nil then
        arg1 = ""
    else
        arg1 = " " .. tostring(arg1)
    end
    DEFAULT_CHAT_FRAME:AddMessage("|cFF66CCFF" .. tostring(msg) .. arg1 .. "|r")
end

local function OnSlash(msg)
    msg = msg and msg:lower() or ""
    if msg == "debug" then
        ZB.isDebug = not ZB.isDebug
        cprint("ZakatziBar debug:", ZB.isDebug and "ON" or "OFF")
    elseif msg == "clear" then
        ClearAll()
        cprint("ZakatziBar: cleared bars.")
    elseif msg == "disable" then
        ZB.isDisabled = not ZB.isDisabled
        cprint("ZakatziBar:", ZB.isDisabled and "DISABLED" or "ENABLED")
    elseif msg == "all" then
        ZB.trackAll = not ZB.trackAll
        cprint("ZakatziBar: trackAll =", ZB.trackAll and "ON" or "OFF")
    else
        cprint("ZakatziBar commands:")
        cprint("/zb debug   - toggle debug prints")
        cprint("/zb clear   - clear all bars")
        cprint("/zb disable - toggle tracking")
        cprint("/zb all     - toggle tracking all sources vs others only")
    end
end

local function OnEvent(self, event, ...)
    if event == "PLAYER_LOGIN" then
        cprint("ZakatziBar loaded. Type /zb for commands.")
        InitSpellData()
        for key in pairs(ZB.bars) do
            ZB:CreateBar(key)
        end
        SLASH_ZAKATZIBAR1 = "/zb"
        SlashCmdList.ZAKATZIBAR = OnSlash
    elseif event == "PLAYER_ENTERING_WORLD" then
        ClearAll()
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        OnCombatLog(...)
    elseif event == "PARTY_MEMBERS_CHANGED" then
        PrunePartyIcons()
    end
end

ZB.frame:SetScript("OnEvent", OnEvent)
ZB.frame:RegisterEvent("PLAYER_LOGIN")
ZB.frame:RegisterEvent("PLAYER_ENTERING_WORLD")
ZB.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
ZB.frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
