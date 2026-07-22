# Run every tick (see tick.mcfunction section 8b). The new downed-state mod
# drops a player's held/worn items as ground item entities when they go
# down, and lets other players loot them from the corpse/ground - this finds
# any streak item lying around and sends it straight back to its owner
# instead of leaving it lootable.
execute as @e[type=item,nbt={Item:{components:{"minecraft:custom_data":{streak_item:1}}}}] at @s run function killstreak:streak_item_recall_apply
execute as @e[type=item,nbt={Item:{components:{"minecraft:custom_data":{streak_item:2}}}}] at @s run function killstreak:streak_item_recall_apply
execute as @e[type=item,nbt={Item:{components:{"minecraft:custom_data":{streak_item:3}}}}] at @s run function killstreak:streak_item_recall_apply
execute as @e[type=item,nbt={Item:{components:{"minecraft:custom_data":{streak_item:4}}}}] at @s run function killstreak:streak_item_recall_apply
