# Running "as" the owning player, positioned at them. Grab the item we
# tagged back in streak_item_recall_apply.mcfunction, drop its pickup delay
# to 0, and teleport it directly onto the player - vanilla pickup handles
# the actual "into their inventory" part next tick, so the item keeps every
# bit of its original NBT (name, enchants, durability, everything) intact.
execute as @e[tag=streakRecallItem,limit=1,sort=nearest] run data merge entity @s {PickupDelay:0s,Age:0s}
execute as @e[tag=streakRecallItem,limit=1,sort=nearest] run tp @s ~ ~ ~
tellraw @s [{"text":"Your streak artifact ","color":"gray"},{"text":"returned","color":"gold"},{"text":" to you.","color":"gray"}]
