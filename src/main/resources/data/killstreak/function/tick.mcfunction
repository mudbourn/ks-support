# ====================================================================
# 1. STREAK BOARD VISIBILITY & PER-PLAYER SCORE INIT
# ====================================================================
# Only show the sidebar at all once someone actually has a streak going
execute if entity @a[scores={streak=1..}] run scoreboard objectives setdisplay sidebar streakDisplay
execute unless entity @a[scores={streak=1..}] run scoreboard objectives setdisplay sidebar

# Initialize receivedTier to 0 for any player who doesn't have a score yet,
# otherwise the "receivedTier=0" checks below never match and rewards never fire
scoreboard players add @a receivedTier 0

# Initialize lastDeaths to 0 for any player who doesn't have a score yet.
# BUGFIX: without this, "if score @s deaths > @s lastDeaths" can never be true
# for a player whose lastDeaths score has never been set (comparisons against a
# score that doesn't exist always fail), so the death-reset block below would
# never fire for them - meaning once they'd claimed both streak items, dying
# would never clear their streak/receivedTier and they'd be stuck unable to
# earn either reward ever again.
scoreboard players add @a lastDeaths 0


# ====================================================================
# 2. DETECT KILLS AND ADD SCALED POINTS
# ====================================================================

# STANDARD PLAYER KILLS (Holding standard Diamond/Netherite weapon - not the custom ones)
execute as @a[scores={killedPlayer=1..}] unless data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players add @s streak 100
execute as @a[scores={killedPlayer=1..}] unless data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players set @s graceTimer 400
execute as @a[scores={killedPlayer=1..}] unless data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players set @s dropTimer 160

# STANDARD MOB KILLS - worth a quarter of a standard player kill (100 / 4 = 25)
execute as @a[scores={killedMob=1..}] unless data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players add @s streak 25
execute as @a[scores={killedMob=1..}] unless data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players set @s graceTimer 400
execute as @a[scores={killedMob=1..}] unless data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players set @s dropTimer 160

# STREAK ITEM KILLS (holding any streak weapon) - standard scoring
execute as @a[scores={killedPlayer=1..}] if data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players add @s streak 100
execute as @a[scores={killedPlayer=1..}] if data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players set @s graceTimer 400
execute as @a[scores={killedPlayer=1..}] if data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players set @s dropTimer 160

execute as @a[scores={killedMob=1..}] if data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players add @s streak 25
execute as @a[scores={killedMob=1..}] if data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players set @s graceTimer 400
execute as @a[scores={killedMob=1..}] if data entity @s SelectedItem.components."minecraft:custom_data".streak_item run scoreboard players set @s dropTimer 160


# Clean the trigger flags for the next tick
scoreboard players set @a killedPlayer 0
scoreboard players set @a killedMob 0


# ====================================================================
# 3. THE TIME DECAY SYSTEM
# ====================================================================

# Count down the 20-second grace window (400 game ticks)
execute as @a[scores={graceTimer=1..}] run scoreboard players remove @s graceTimer 1

# If the grace window closes, tick down the 8-second decay drop timer (160 game ticks)
execute as @a[scores={graceTimer=0,streak=1..}] run scoreboard players remove @s dropTimer 1

# Once the 8 seconds run out, subtract 100 points (1 standard kill value) and loop the decay timer
execute as @a[scores={dropTimer=..0,graceTimer=0,streak=1..}] run scoreboard players remove @s streak 100
execute as @a[scores={dropTimer=..0,graceTimer=0,streak=1..}] run scoreboard players set @s dropTimer 160

# Failsafe: Block the system from plunging the score into negatives
execute as @a[scores={streak=..-1}] run scoreboard players set @s streak 0

# Sync the human-readable kill count (raw streak is internally scaled x100 per kill).
# Reset * first: scoreboard entries persist for offline players forever
# otherwise (there's no selector that can target a disconnected player to
# clean up just their entry), so every tick this wipes EVERY tracked holder -
# online or offline - then immediately repopulates it from only @a (currently
# online players). A player who disconnects simply stops getting rebuilt the
# next tick, so their name drops out of the sidebar within a tick of leaving.
scoreboard players reset * streakDisplay
scoreboard players operation @a streakDisplay = @a streak
scoreboard players operation @a streakDisplay /= #100 const


# ====================================================================
# 4. REWARD BOUNDARIES
# ====================================================================

# TIER 1 MILESTONE (800 Points / 8 Kills) - Loadout grant
# Loadout = 1 random gun + 1 med + 1 bomb (all contract-bound, purged on death)
# receivedTier tracks highest tier EARNED (0→1→2); loadoutGranted is the once-guard
# so the loadout fires exactly once per life (receivedTier=1 persists across the
# whole life; loadoutGranted prevents the grant from repeating every tick).
execute as @a[scores={streak=800..,receivedTier=0}] run scoreboard players set @s receivedTier 1
execute as @a[scores={streak=800..,receivedTier=1,loadoutGranted=0}] run function killstreak:give_tier1_loadout
execute as @a[scores={streak=800..,receivedTier=1,loadoutGranted=0}] run scoreboard players set @s loadoutGranted 1
execute as @a[scores={streak=800..,receivedTier=1,loadoutGranted=0}] run scoreboard players set @s tierHealCount 60

# TIER 2 MILESTONE (1200 Points / 12 Kills) - Artifact grant
# Artifact = 1 random artifact weapon (Dirge / Mjolnir / Soul Reaper)
# Once-guard: artifactGranted prevents the grant from repeating every tick.
execute as @a[scores={streak=1200..,receivedTier=1}] run scoreboard players set @s receivedTier 2
execute as @a[scores={streak=1200..,receivedTier=2,artifactGranted=0}] run function killstreak:give_artifact
execute as @a[scores={streak=1200..,receivedTier=2,artifactGranted=0}] run scoreboard players set @s artifactGranted 1
execute as @a[scores={streak=1200..,receivedTier=2,artifactGranted=0}] run effect give @s minecraft:resistance infinite 2 true
execute as @a[scores={streak=1200..,receivedTier=2,artifactGranted=0}] run effect give @s minecraft:speed infinite 0 true
execute as @a[scores={streak=1200..,receivedTier=2,artifactGranted=0}] run effect give @s minecraft:fire_resistance infinite 0 true
execute as @a[scores={streak=1200..,receivedTier=2,artifactGranted=0}] run playsound minecraft:entity.ender_dragon.growl master @a ~ ~ ~ 1 0.7 0.5
execute as @a[scores={streak=1200..,receivedTier=2,artifactGranted=0}] run tellraw @a [{"text":"A ","color":"gray"},{"text":"Legendary Artifact","color":"aqua","bold":true},{"text":" has chosen ","color":"gray"},{"selector":"@s","color":"yellow"},{"text":". May mercy be with you all.","color":"gray"}]
execute as @a[scores={streak=1200..,receivedTier=2,artifactGranted=0}] run scoreboard players set @s tierHealCount 60


# ====================================================================
# 5. ADRENALINE SHOT CHAINED EFFECT
# ====================================================================
# Phase 1 (Resistance V + Speed II, started by the effects_changed advancement)
# counts down for 15s, then automatically starts phase 2 (Slowness I, one-time
# 5 minutes - see adrenaline_start.mcfunction for why it's guarded against
# restarting mid-chain). When phase 2 finishes, permanently remove 1 heart of
# max health and reset.
execute as @a[scores={adrenalineTimer=1..}] run scoreboard players remove @s adrenalineTimer 1

execute as @a[scores={adrenalinePhase=1,adrenalineTimer=..0}] run effect give @s minecraft:slowness 300 0 true
execute as @a[scores={adrenalinePhase=1,adrenalineTimer=..0}] run scoreboard players set @s adrenalineTimer 6000
execute as @a[scores={adrenalinePhase=1,adrenalineTimer=..0}] run scoreboard players set @s adrenalinePhase 2

# Fetch CURRENT health and max health first (both x10), before touching
# anything. Fetching max health isn't just about avoiding a health/max desync -
# servers using Origins (or similar) mods can already start players well under
# vanilla's 20 max health, so this fetched value doubles as a safety-floor
# check below rather than assuming everyone has a 20-health baseline.
execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0}] store result score @s adrenalineHealthTemp run data get entity @s Health 10
execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0}] store result score @s adrenalineMaxHealthTemp run attribute @s minecraft:max_health get 10

# Safety floor: only actually apply the scar if doing so won't take the player
# below 2.0 max health (one heart) - i.e. their CURRENT max health (just
# fetched) must be at least 4.0 (40 in x10 scale). This matters most for a
# player on a reduced-max-health origin, who could otherwise get walked down
# to (or below) 0 max health - and killed outright - by a handful of stacked
# doses that a vanilla-health player would shrug off.
execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0,adrenalineMaxHealthTemp=40..}] run scoreboard players add @s adrenalineScars 1
execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0,adrenalineMaxHealthTemp=40..}] run execute store result storage killstreak:adrenaline scar.count int 1 run scoreboard players get @s adrenalineScars
execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0,adrenalineMaxHealthTemp=40..}] run function killstreak:adrenaline_scar with storage killstreak:adrenaline scar

# Re-fetch max health (now lowered) into its OWN score - kept separate from
# adrenalineMaxHealthTemp so the floor check above isn't clobbered by this
# post-debuff value - then clamp the health fetched earlier and restore it
execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0,adrenalineMaxHealthTemp=40..}] store result score @s adrenalineMaxHealthNew run attribute @s minecraft:max_health get 10
execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0,adrenalineMaxHealthTemp=40..}] if score @s adrenalineHealthTemp > @s adrenalineMaxHealthNew run scoreboard players operation @s adrenalineHealthTemp = @s adrenalineMaxHealthNew
execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0,adrenalineMaxHealthTemp=40..}] store result entity @s Health float 0.1 run scoreboard players get @s adrenalineHealthTemp

execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0,adrenalineMaxHealthTemp=40..}] run tellraw @s [{"text":"[ADRENALINE] ","color":"dark_red","bold":true},{"text":"The crash costs you a heart, permanently.","color":"gray"}]
execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0,adrenalineMaxHealthTemp=..39}] run tellraw @s [{"text":"[ADRENALINE] ","color":"dark_red","bold":true},{"text":"Your body can't take any more - this crash passes without further cost.","color":"gray"}]

execute as @a[scores={adrenalinePhase=2,adrenalineTimer=..0}] run scoreboard players set @s adrenalinePhase 0


# ====================================================================
# 6. TIER-UP HEAL PULSE (set health to 20 every 100ms for 3 seconds)
# ====================================================================
execute as @a[scores={tierHealCount=1..}] run scoreboard players remove @s tierHealCount 1
scoreboard players operation @a tierHealParity = @a tierHealCount
scoreboard players operation @a tierHealParity %= #2 const
execute as @a[scores={tierHealParity=1}] at @s run data merge entity @s {Health:20.0f}


# ====================================================================
# 7. DOWNED STATE & EXTRA SPECTATOR PURGE CLEANUP
# ====================================================================
# Both paths below (falling to spectator while geared up, and an actual death)
# funnel into the same killstreak:life_reset function so a new life never
# inherits ANY of the previous one's weapons, buffs, debuffs, or cooldowns -
# including the permanent adrenaline max-health scars, which otherwise persist
# on the player's NBT indefinitely (Minecraft attribute modifiers don't clear
# on death by default).

# Figure out (BEFORE life_reset strips everything below) whether this player
# is actually carrying any streak item right now - checking the whole
# Inventory list catches it in any slot (held, worn, or just sitting in the
# inventory), not only the handful of equipped slots streak_theft_check
# cares about. receivedTier is NOT what we want here: it only remembers
# whether a tier was EVER granted this life, so it stays "true" even after
# every streak item has already been lost (theft-reject, a failed recall
# giving up, etc) - gating on it made the "lost your streak gear" message
# fire on a later death even when the player genuinely has nothing to lose.
scoreboard players set @a hasStreakGear 0
execute as @a if data entity @s Inventory[{components:{"minecraft:custom_data":{streak_item:1}}}] run scoreboard players set @s hasStreakGear 1
execute as @a if data entity @s Inventory[{components:{"minecraft:custom_data":{streak_item:2}}}] run scoreboard players set @s hasStreakGear 1
execute as @a if data entity @s Inventory[{components:{"minecraft:custom_data":{streak_item:3}}}] run scoreboard players set @s hasStreakGear 1
execute as @a if data entity @s Inventory[{components:{"minecraft:custom_data":{streak_item:4}}}] run scoreboard players set @s hasStreakGear 1

execute as @a[gamemode=spectator] unless score @s spectatorFallen matches 1 if score @s hasStreakGear matches 1 run tellraw @a [{"selector":"@s","color":"yellow"},{"text":" has fallen, and lost their streak gear.","color":"gray"}]
execute as @a[gamemode=spectator] run scoreboard players set @s spectatorFallen 1
execute as @a[gamemode=!spectator] run scoreboard players set @s spectatorFallen 0
execute as @a[gamemode=spectator] run function killstreak:life_reset

execute as @a if score @s deaths > @s lastDeaths if score @s hasStreakGear matches 1 run tellraw @a [{"selector":"@s","color":"yellow"},{"text":" has fallen, and lost their streak gear.","color":"gray"}]
execute as @a if score @s deaths > @s lastDeaths run function killstreak:life_reset
execute as @a if score @s deaths > @s lastDeaths run scoreboard players operation @s lastDeaths = @s deaths


# ====================================================================
# 8. STREAK ITEM ANTI-THEFT / ANTI-DROP SAFEGUARDS
# ====================================================================
# The downed-state mod drops a player's held/worn items on the ground when
# they go down, and lets other players loot the corpse/ground for them.
# Streak items are earned, not lootable, so:
#  - streak_item_recall.mcfunction sweeps up any dropped streak item and
#    teleports it straight back into its owner's hands.
#  - streak_theft_check.mcfunction covers the gap in between (or anything
#    the recall missed) by destroying a streak item outright the moment it's
#    found equipped by anyone but its original owner.
function killstreak:streak_item_recall
execute as @a run function killstreak:streak_theft_check
