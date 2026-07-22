# Soul Reaper — Asrael's Curse (Scythe)
data modify storage killstreak:temp owner set from entity @s UUID
function killstreak:give_artifact_soul_reaper_apply with storage killstreak:temp
playsound minecraft:entity.wither.ambient master @s ~ ~ ~ 1 0.7 0.5
tellraw @a [{"text":"Asrael's Curse ","color":"gold","bold":true},{"text":"has chosen ","color":"gray"},{"selector":"@s","color":"yellow"},{"text":".","color":"gray"}]
