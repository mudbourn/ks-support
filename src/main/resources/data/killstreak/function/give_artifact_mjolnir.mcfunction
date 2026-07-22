# Mjolnir — Thor's Recognition (Mace)
data modify storage killstreak:temp owner set from entity @s UUID
function killstreak:give_artifact_mjolnir_apply with storage killstreak:temp
playsound minecraft:entity.lightning_bolt.thunder master @s ~ ~ ~ 1 0.7 0.5
tellraw @a [{"text":"Thor's Recognition ","color":"aqua","bold":true},{"text":"has chosen ","color":"gray"},{"selector":"@s","color":"yellow"},{"text":".","color":"gray"}]
