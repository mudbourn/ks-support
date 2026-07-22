# Med pool: uniform random 1-3
execute store result score @s tempRoll run random value 1..3
execute if score @s tempRoll matches 1 run function killstreak:med/grant_adrenaline_shot
execute if score @s tempRoll matches 2 run function killstreak:med/grant_healing_potion
execute if score @s tempRoll matches 3 run function killstreak:med/grant_golden_apple
