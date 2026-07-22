# T2 Artifact Dispatcher — weighted random selection
# Dirge weight=4, Soul Reaper weight=4, Mjolnir weight=2 (total=10)
execute store result score @s tempRoll run random value 1..10
execute if score @s tempRoll matches 1..4 run function killstreak:give_artifact_dirge
execute if score @s tempRoll matches 5..8 run function killstreak:give_artifact_soul_reaper
execute if score @s tempRoll matches 9..10 run function killstreak:give_artifact_mjolnir
