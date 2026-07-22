# Bomb pool: uniform random 1-2
execute store result score @s tempRoll run random value 1..2
execute if score @s tempRoll matches 1 run function killstreak:bomb/grant_smoke_grenade
execute if score @s tempRoll matches 2 run function killstreak:bomb/grant_stun_grenade
