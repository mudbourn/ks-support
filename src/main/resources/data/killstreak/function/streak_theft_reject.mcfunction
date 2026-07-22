# $(slot) is the offending equipment slot, passed in as a literal by
# streak_theft_check_apply.mcfunction. Still running "as" the holder.
$item replace entity @s $(slot) with air
playsound minecraft:entity.evoker.cast_spell master @s ~ ~ ~ 1 0.6
tellraw @s [{"text":"The artifact ","color":"dark_red"},{"text":"rejects","color":"dark_red","bold":true},{"text":" your grip and vanishes - it isn't yours to wield.","color":"gray"}]
