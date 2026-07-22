# Removes every stacked "adrenaline_scar_N" max-health attribute modifier this
# life accumulated (N from 1 up to adrenalineScars) so none of them carry into
# the player's next life, then resets the scar counter itself back to 0.
scoreboard players operation @s adrenalineResetCounter = @s adrenalineScars
function killstreak:adrenaline_reset_loop
scoreboard players set @s adrenalineScars 0
