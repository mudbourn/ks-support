# Running "as" the dropped item entity, "at" its own position.

# Throttle to one attempt per second (20 ticks) rather than every single
# tick, so "5 tries" plays out over a sensible ~5 seconds instead of a
# quarter-second - long enough for a normal disconnect/respawn hiccup to
# resolve itself, but not indefinite if the owner genuinely can't receive it
# back (e.g. this item is fighting a downed state that blocks pickups
# entirely).
execute if score @s streakRecallWait matches 1.. run scoreboard players remove @s streakRecallWait 1
execute if score @s streakRecallWait matches 1.. run return 0

# Already failed 5 times in a row - give up on this owner for good instead
# of trying forever.
execute if score @s streakRecallTries matches 5.. run function killstreak:streak_item_recall_giveup
execute if score @s streakRecallTries matches 5.. run return 0

# This tick is a real attempt.
scoreboard players set @s streakRecallWait 20
scoreboard players add @s streakRecallTries 1

# Tag itself so the later teleport step (once we've located the owner) can
# find this exact item again after switching execution context to "as" the
# player.
tag @s add streakRecallItem

# Owner is normally baked in as streak_owner at grant time (see
# give_tier1_roll1_apply.mcfunction etc.) - fall back to whoever physically
# dropped it (vanilla's Thrower tag) on the off chance an older/untagged
# item is still floating around.
data remove storage killstreak:temp owner
data modify storage killstreak:temp owner set from entity @s Item.components."minecraft:custom_data".streak_owner
execute unless data storage killstreak:temp owner run data modify storage killstreak:temp owner set from entity @s Thrower

execute if data storage killstreak:temp owner run function killstreak:streak_item_recall_return with storage killstreak:temp

tag @s remove streakRecallItem
