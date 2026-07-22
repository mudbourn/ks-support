# Dirge — Zorion's Vengeance (Trident)
data modify storage killstreak:temp owner set from entity @s UUID
function killstreak:give_artifact_dirge_apply with storage killstreak:temp
playsound minecraft:item.trident.thunder master @s ~ ~ ~ 1 1 0.5
tellraw @a [{"text":"Zorion's Vengeance ","color":"dark_red","bold":true},{"text":"has chosen ","color":"gray"},{"selector":"@s","color":"yellow"},{"text":".","color":"gray"}]
