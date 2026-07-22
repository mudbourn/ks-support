# $(owner) is the item's stamped owner UUID. Still "as"/"at" the item entity
# here - if a player's own UUID data matches it, hop into their context and
# bring the item to them. If the owner isn't online, or is currently in
# spectator (i.e. mid life_reset, or hasn't respawned yet), the item is left
# alone rather than handed back - it'll get swept up by
# streak_item_purge_owned.mcfunction on the next life_reset if it's still
# sitting there once they're back.
$execute as @a[gamemode=!spectator] if data entity @s {UUID:$(owner)} at @s run function killstreak:streak_item_recall_teleport
