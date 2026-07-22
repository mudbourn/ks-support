# Full "new life" reset - runs whenever a player dies, or is purged to
# spectator while holding streak gear. Strips streak weapons/effects and
# resets EVERY score this pack tracks - kill streak, tier unlocks, ability
# cooldowns, in-progress crouch-casts, the adrenaline phase/timer, and the
# permanent adrenaline max-health scars themselves - so nothing (weapons,
# buffs, debuffs, cooldowns) carries over into the player's next life.

clear @s *[custom_data~{streak_item:1}]
clear @s *[custom_data~{streak_item:2}]
clear @s *[custom_data~{streak_item:3}]
clear @s *[custom_data~{streak_item:4}]

# clear (above) only strips what's still in this player's inventory. Any
# copy of their gear that the downed-state mod already dropped as a ground
# item entity is a separate thing entirely and clear can't touch it - left
# alone, streak_item_recall.mcfunction would find it a tick or two later and
# teleport it straight back, silently undoing this whole reset (and if this
# player earns a fresh kit in their next life, that orphaned copy is still
# out there to eventually get recalled ON TOP of the new one). Destroy it
# outright instead.
data modify storage killstreak:temp owner set from entity @s UUID
function killstreak:streak_item_purge_owned with storage killstreak:temp

effect clear @s minecraft:resistance
effect clear @s minecraft:speed
effect clear @s minecraft:slowness
effect clear @s minecraft:strength
effect clear @s minecraft:nausea
effect clear @s minecraft:fire_resistance

scoreboard players set @s streak 0
scoreboard players set @s graceTimer 0
scoreboard players set @s dropTimer 0
scoreboard players set @s receivedTier 0
scoreboard players set @s loadoutGranted 0
scoreboard players set @s artifactGranted 0
scoreboard players set @s tierHealCount 0

# Adrenaline Shot - phase/timer plus every stacked permanent scar modifier
scoreboard players set @s adrenalinePhase 0
scoreboard players set @s adrenalineTimer 0
function killstreak:adrenaline_reset
