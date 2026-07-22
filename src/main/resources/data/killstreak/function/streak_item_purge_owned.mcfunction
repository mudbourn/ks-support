# $(owner) is the resetting player's UUID (see life_reset.mcfunction). Kills
# every dropped item anywhere that's stamped as belonging to them, streak
# tier doesn't matter here - a full life reset means ALL of it goes, not
# just whatever's still equipped.
$kill @e[type=item,nbt={Item:{components:{"minecraft:custom_data":{streak_owner:$(owner)}}}}]
