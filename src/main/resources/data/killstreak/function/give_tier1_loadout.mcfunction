# T1 Loadout grant — runs as the receiving player
# Stamps UUID for streak_owner, rolls gun via weighted random, then med + bomb
data modify storage killstreak:temp owner set from entity @s UUID

# Roll weighted gun (Common x6, Uncommon x4, Rare x2, Very Rare x1 — total 90)
execute store result score @s tempRoll run random value 1..90

execute if score @s tempRoll matches 1..6 run function killstreak:gun/grant_combat_pistol
execute if score @s tempRoll matches 7..12 run function killstreak:gun/grant_semi_auto_pistol
execute if score @s tempRoll matches 13..18 run function killstreak:gun/grant_revolver
execute if score @s tempRoll matches 19..24 run function killstreak:gun/grant_custom_smg
execute if score @s tempRoll matches 25..30 run function killstreak:gun/grant_phantom_smg
execute if score @s tempRoll matches 31..34 run function killstreak:gun/grant_assault_rifle
execute if score @s tempRoll matches 35..38 run function killstreak:gun/grant_combat_rifle
execute if score @s tempRoll matches 39..42 run function killstreak:gun/grant_service_rifle
execute if score @s tempRoll matches 43..46 run function killstreak:gun/grant_semi_auto_rifle
execute if score @s tempRoll matches 47..50 run function killstreak:gun/grant_burst_rifle
execute if score @s tempRoll matches 51..54 run function killstreak:gun/grant_infantry_rifle
execute if score @s tempRoll matches 55..58 run function killstreak:gun/grant_pump_shotgun
execute if score @s tempRoll matches 59..62 run function killstreak:gun/grant_repeating_shotgun
execute if score @s tempRoll matches 63..66 run function killstreak:gun/grant_double_barrel_shotgun
execute if score @s tempRoll matches 67..68 run function killstreak:gun/grant_bolt_action_rifle
execute if score @s tempRoll matches 69..70 run function killstreak:gun/grant_subsonic_rifle
execute if score @s tempRoll matches 71..72 run function killstreak:gun/grant_supersonic_shotgun
execute if score @s tempRoll matches 73..74 run function killstreak:gun/grant_waterpipe_shotgun
execute if score @s tempRoll matches 75..76 run function killstreak:gun/grant_blossom_rifle
execute if score @s tempRoll matches 77..78 run function killstreak:gun/grant_holy_shotgun
execute if score @s tempRoll matches 79..80 run function killstreak:gun/grant_light_machine_gun
execute if score @s tempRoll matches 81..82 run function killstreak:gun/grant_flare_gun
execute if score @s tempRoll matches 83 run function killstreak:gun/grant_rocket_launcher
execute if score @s tempRoll matches 84 run function killstreak:gun/grant_grenade_launcher
execute if score @s tempRoll matches 85 run function killstreak:gun/grant_hypersonic_cannon
execute if score @s tempRoll matches 86 run function killstreak:gun/grant_typhoonee
execute if score @s tempRoll matches 87 run function killstreak:gun/grant_minigun
execute if score @s tempRoll matches 88 run function killstreak:gun/grant_flamethrower
execute if score @s tempRoll matches 89 run function killstreak:gun/grant_hollenfire_mk2
execute if score @s tempRoll matches 90 run function killstreak:gun/grant_soulhunter_mk2

# Roll med (1 of 3)
function killstreak:give_tier1_loadout_med

# Roll bomb (1 of 2)
function killstreak:give_tier1_loadout_bomb

# Announce
playsound minecraft:ui.toast.challenge_complete master @a ~ ~ ~ 1 1 0.5
tellraw @a [{"text":"A ","color":"gray"},{"text":"Loadout","color":"gold","bold":true},{"text":" has been delivered to ","color":"gray"},{"selector":"@s","color":"yellow"},{"text":" for their 8 kill streak!","color":"gray"}]
