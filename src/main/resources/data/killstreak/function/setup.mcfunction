# Run once at startup to create tracking scores
scoreboard objectives add streak dummy
scoreboard objectives add killedMob totalKillCount
scoreboard objectives add killedPlayer playerKillCount
scoreboard objectives add graceTimer dummy
scoreboard objectives add dropTimer dummy
scoreboard objectives add deaths deathCount
scoreboard objectives add receivedTier dummy
scoreboard objectives add lastDeaths dummy

# Display-only objective: shows streak/100 (real kill count) instead of the internal scaled score
scoreboard objectives add streakDisplay dummy
# "modify" (rather than relying on "add"'s display-name argument) so the name gets
# fixed even on a world where this objective was already created before this update
scoreboard objectives modify streakDisplay displayname "Streak"

scoreboard objectives add const dummy
scoreboard players set #100 const 100
scoreboard players set #2 const 2
scoreboard players set #10 const 10
scoreboard players set #20 const 20
scoreboard players set #5 const 5

# Scratch score for weighted random selection (artifact, med, bomb rolls)
scoreboard objectives add tempRoll dummy
# Once-guards for tier grants (prevent tick-loop spam; reset on death)
scoreboard objectives add loadoutGranted dummy
scoreboard objectives add artifactGranted dummy

# ====================================================================
# Tier-up heal pulse tracking
# ====================================================================
scoreboard objectives add tierHealCount dummy
scoreboard objectives add tierHealParity dummy
scoreboard objectives add spectatorFallen dummy
# Recomputed every tick right before the death/spectator cleanup - 1 if the
# player is currently carrying any streak item anywhere (see tick.mcfunction
# section 7), used to gate the "lost your streak gear" message so it only
# fires when there's actually something to lose.
scoreboard objectives add hasStreakGear dummy

# ====================================================================
# Adrenaline Shot chained-effect tracking
# ====================================================================
# phase 1 = Resistance V/Speed II window (15s), phase 2 = Slowness I window
# (5 minutes, one-time - see adrenaline_start.mcfunction)
scoreboard objectives add adrenalinePhase dummy
scoreboard objectives add adrenalineTimer dummy
# Lifetime counter - used only to generate a unique attribute-modifier id per
# dose, so repeated hits stack (each dose permanently costs another heart)
# rather than the second dose silently failing to add a duplicate modifier id
scoreboard objectives add adrenalineScars dummy
# Scratch scores used to fetch the player's health BEFORE the permanent max-health
# debuff is applied, so it can be clamped/restored afterward instead of being
# left to whatever the engine does with a health value that now exceeds the
# (lowered) max - both scaled x10 to avoid float precision issues.
# adrenalineMaxHealthTemp holds the PRE-debuff max health (used for the safety
# floor check below); adrenalineMaxHealthNew holds the POST-debuff max health
# (used for the clamp) - kept as separate scores so the floor check doesn't
# get clobbered by the post-debuff refetch.
scoreboard objectives add adrenalineHealthTemp dummy
scoreboard objectives add adrenalineMaxHealthTemp dummy
scoreboard objectives add adrenalineMaxHealthNew dummy
# Counts down while removing each stacked adrenaline_scar_N attribute modifier
# on death/reset (see adrenaline_reset.mcfunction) - a fresh life should carry
# NONE of this life's permanent max-health loss forward
scoreboard objectives add adrenalineResetCounter dummy

# ====================================================================
# Recall retry/give-up tracking for dropped streak items (see
# streak_item_recall_apply.mcfunction) - lives on the dropped item entity
# itself, not on any player, so these hold per-item state rather than the
# usual per-player state everything else on this list does.
scoreboard objectives add streakRecallWait dummy
scoreboard objectives add streakRecallTries dummy
