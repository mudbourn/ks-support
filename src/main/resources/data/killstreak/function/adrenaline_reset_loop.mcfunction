# Removes one modifier per call and counts adrenalineResetCounter down to 0 -
# the same "generated id per dose" trick as adding them, just run in reverse.
execute if score @s adrenalineResetCounter matches 1.. run execute store result storage killstreak:adrenaline reset.count int 1 run scoreboard players get @s adrenalineResetCounter
execute if score @s adrenalineResetCounter matches 1.. run function killstreak:adrenaline_reset_remove with storage killstreak:adrenaline reset
execute if score @s adrenalineResetCounter matches 1.. run scoreboard players remove @s adrenalineResetCounter 1
execute if score @s adrenalineResetCounter matches 1.. run function killstreak:adrenaline_reset_loop
