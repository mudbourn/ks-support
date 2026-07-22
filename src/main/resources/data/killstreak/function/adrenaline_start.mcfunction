# Fires the instant Resistance V (from the Adrenaline Shot specifically, not
# any other Resistance source) lands on a player - revoke immediately so it
# can fire again on the next dose, then start the 15-second phase-1 timer.
advancement revoke @s only killstreak:adrenaline_shot_taken

# Only actually (re)start the chain if one isn't already running (phase 0 =
# idle). Without this gate, drinking - or being splashed by - another
# Adrenaline Shot while phase 1 or phase 2 is still in progress would reset
# adrenalinePhase back to 1 and adrenalineTimer back to 300, restarting the
# whole 15s buff + 5min slowness sequence from scratch. That let the chain
# keep re-triggering itself indefinitely instead of running once and being
# done; now a dose taken mid-chain still grants its own instant Resistance/
# Speed from the potion itself, but no longer disturbs the timer already
# counting down toward the one-time slowness debuff.
execute if score @s adrenalinePhase matches 0 run scoreboard players set @s adrenalinePhase 1
execute if score @s adrenalinePhase matches 0 run scoreboard players set @s adrenalineTimer 300
