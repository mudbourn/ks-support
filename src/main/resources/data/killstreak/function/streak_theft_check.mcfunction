# Run "as" a player every tick (see tick.mcfunction section 8b). Looting a
# downed player's streak gear with the new looting mod hands it to whoever
# picked it up - this rejects it from anyone but the original recipient.
data modify storage killstreak:temp owner set from entity @s UUID
function killstreak:streak_theft_check_apply with storage killstreak:temp
