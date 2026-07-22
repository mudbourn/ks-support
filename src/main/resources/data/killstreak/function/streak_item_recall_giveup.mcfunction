# Still "as"/"at" the dropped item entity. killstreak:temp's "owner" value is
# whatever it was left at by the last successful lookup (up to 20 ticks ago),
# which is exactly what we want to notify.
function killstreak:streak_item_recall_giveup_notify with storage killstreak:temp
kill @s
