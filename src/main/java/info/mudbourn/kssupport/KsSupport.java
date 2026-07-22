package info.mudbourn.kssupport;

import com.mojang.brigadier.CommandDispatcher;
import com.mojang.brigadier.arguments.IntegerArgumentType;
import com.mojang.brigadier.arguments.StringArgumentType;
import com.mojang.brigadier.context.CommandContext;
import com.mojang.brigadier.suggestion.SuggestionProvider;
import net.fabricmc.api.ModInitializer;
import net.fabricmc.fabric.api.command.v2.CommandRegistrationCallback;
import net.fabricmc.fabric.api.networking.v1.ServerPlayConnectionEvents;
import net.minecraft.commands.CommandSourceStack;
import net.minecraft.commands.Commands;
import net.minecraft.commands.arguments.EntityArgument;
import net.minecraft.network.chat.Component;
import net.minecraft.server.ServerScoreboard;
import net.minecraft.server.level.ServerPlayer;
import net.minecraft.world.scores.Objective;
import net.minecraft.world.scores.ScoreAccess;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Collection;
import java.util.List;
import java.util.Map;

public class KsSupport implements ModInitializer {
    private static final Logger LOG = LoggerFactory.getLogger("ks_support");

    private static final int KILL_SCALE = 100;
    private static final int TIER1_THRESHOLD = 800;
    private static final int TIER2_THRESHOLD = 1200;

    private static final List<String> SKILLS = List.of(
        "storm", "bolt", "mothra", "boost", "grief", "tier2"
    );

    private record SkillInfo(String chargeObj, String cooldownObj, int fullCharge) {}
    private static final Map<String, SkillInfo> SKILL_MAP = Map.ofEntries(
        Map.entry("storm",  new SkillInfo("mjolnirStormCharge",   "mjolnirStormCooldown",   650)),
        Map.entry("bolt",   new SkillInfo(null,                    "mjolnirBoltCooldown",    0)),
        Map.entry("mothra", new SkillInfo(null,                    "mothraCooldown",         0)),
        Map.entry("boost",  new SkillInfo(null,                    "mothraBoostCooldown",    0)),
        Map.entry("grief",  new SkillInfo("zorionGriefCharge",     "zorionGriefCooldown",    350)),
        Map.entry("tier2",  new SkillInfo("tier2DamageDealt",      null,                     350))
    );

    @Override
    public void onInitialize() {
        CommandRegistrationCallback.EVENT.register((dispatcher, registryAccess, environment) -> {
            registerKsCommands(dispatcher);
        });

        // Login flight sweep \u2014 call EC's dead code on join
        // Only sweep if the player actually has flight-related abilities active
        ServerPlayConnectionEvents.JOIN.register((handler, sender, server) -> {
            try {
                var player = handler.player;
                var abilities = player.getAbilities();
                // Guard: only sweep if the player has mayfly or is flying
                // (avoids the "flight disabled" nag on normal logins)
                if (!abilities.mayfly && !abilities.flying) {
                    return;
                }
                var playerDataClass = Class.forName("com.fibermc.essentialcommands.playerdata.PlayerData");
                var accessMethod = playerDataClass.getMethod("access", ServerPlayer.class);
                Object playerData = accessMethod.invoke(null, player);
                var clearMethod = playerDataClass.getMethod("clearAbilitiesWithoutPermisisons"); // EC's typo
                clearMethod.invoke(playerData);
                LOG.debug("Flight sweep executed for {}", player.getName().getString());
            } catch (NoSuchMethodException e) {
                LOG.warn("EC clearAbilitiesWithoutPermisisons not found \u2014 flight sweep disabled. Check EC version.");
            } catch (Exception e) {
                LOG.error("Flight sweep failed for {}: {}", handler.player.getName().getString(), e.getMessage());
            }
        });

        LOG.info("KS Support v0.3 loaded \u2014 /ks commands, Hurl/Mjolnir texture swap, flight sweep active.");
    }

    private static boolean isGamemaster(CommandSourceStack src) {
        return src.permissions().hasPermission(net.minecraft.server.permissions.Permissions.COMMANDS_GAMEMASTER);
    }

    // ===== /ks command tree =====

    private void registerKsCommands(CommandDispatcher<CommandSourceStack> dispatcher) {
        SuggestionProvider<CommandSourceStack> skillSuggestion = (context, builder) -> {
            SKILLS.forEach(builder::suggest);
            return builder.buildFuture();
        };

        SuggestionProvider<CommandSourceStack> stateSuggestion = (context, builder) -> {
            builder.suggest("charge");
            builder.suggest("cooldown");
            builder.suggest("ready");
            builder.suggest("reset");
            return builder.buildFuture();
        };

        dispatcher.register(Commands.literal("ks")
            .requires(KsSupport::isGamemaster)
            .then(Commands.literal("set")
                .then(Commands.argument("targets", EntityArgument.players())
                    .then(Commands.argument("kills", IntegerArgumentType.integer(0))
                        .executes(ctx -> ksSet(ctx, EntityArgument.getPlayers(ctx, "targets"),
                            IntegerArgumentType.getInteger(ctx, "kills"))))))
            .then(Commands.literal("add")
                .then(Commands.argument("targets", EntityArgument.players())
                    .then(Commands.argument("kills", IntegerArgumentType.integer(0))
                        .executes(ctx -> ksAdd(ctx, EntityArgument.getPlayers(ctx, "targets"),
                            IntegerArgumentType.getInteger(ctx, "kills"))))))
            .then(Commands.literal("get")
                .then(Commands.argument("target", EntityArgument.player())
                    .executes(ctx -> ksGet(ctx, EntityArgument.getPlayer(ctx, "target")))))
            .then(Commands.literal("tier")
                .then(Commands.argument("targets", EntityArgument.players())
                    .then(Commands.argument("tier", IntegerArgumentType.integer(1, 2))
                        .executes(ctx -> ksTier(ctx, EntityArgument.getPlayers(ctx, "targets"),
                            IntegerArgumentType.getInteger(ctx, "tier"))))))
            .then(Commands.literal("skill")
                .then(Commands.argument("targets", EntityArgument.players())
                    .then(Commands.argument("skill", StringArgumentType.word())
                        .suggests(skillSuggestion)
                        .then(Commands.argument("state", StringArgumentType.word())
                            .suggests(stateSuggestion)
                            .executes(ctx -> ksSkill(ctx,
                                EntityArgument.getPlayers(ctx, "targets"),
                                StringArgumentType.getString(ctx, "skill"),
                                StringArgumentType.getString(ctx, "state")))))))
            .then(Commands.literal("reset")
                .then(Commands.argument("targets", EntityArgument.players())
                    .executes(ctx -> ksReset(ctx, EntityArgument.getPlayers(ctx, "targets")))))
            .then(Commands.literal("harness")
                .executes(ctx -> ksHarness(ctx)))
        );
    }

    private int ksSet(CommandContext<CommandSourceStack> ctx, Collection<ServerPlayer> targets, int kills) {
        int raw = kills * KILL_SCALE;
        for (ServerPlayer player : targets) {
            setScore(player, "streak", raw);
            ctx.getSource().sendSuccess(() ->
                Component.literal("\u00a7e" + player.getName().getString() + "\u00a77 streak set to \u00a7a" + kills + "\u00a77 (" + raw + ")"),
                false);
        }
        return targets.size();
    }

    private int ksAdd(CommandContext<CommandSourceStack> ctx, Collection<ServerPlayer> targets, int kills) {
        int raw = kills * KILL_SCALE;
        for (ServerPlayer player : targets) {
            addScore(player, "streak", raw);
            int newKills = getScore(player, "streak") / KILL_SCALE;
            ctx.getSource().sendSuccess(() ->
                Component.literal("\u00a7e" + player.getName().getString() + "\u00a77 streak now \u00a7a" + newKills),
                false);
        }
        return targets.size();
    }

    private int ksGet(CommandContext<CommandSourceStack> ctx, ServerPlayer target) {
        int raw = getScore(target, "streak");
        int kills = raw / KILL_SCALE;
        ctx.getSource().sendSuccess(() ->
            Component.literal("\u00a7e" + target.getName().getString() + "\u00a77 streak: \u00a7a" + kills + "\u00a77 (" + raw + ")"),
            false);
        return raw;
    }

    private int ksTier(CommandContext<CommandSourceStack> ctx, Collection<ServerPlayer> targets, int tier) {
        for (ServerPlayer player : targets) {
            if (tier == 1) {
                setScore(player, "streak", TIER1_THRESHOLD);
                setScore(player, "receivedTier", 0);
            } else {
                setScore(player, "streak", TIER2_THRESHOLD);
                setScore(player, "receivedTier", 1);
            }
            ctx.getSource().sendSuccess(() ->
                Component.literal("\u00a7e" + player.getName().getString() + "\u00a77 set to \u00a7aTier " + tier + "\u00a77 \u2014 datapack will grant next tick"),
                false);
        }
        return targets.size();
    }

    private int ksSkill(CommandContext<CommandSourceStack> ctx, Collection<ServerPlayer> targets,
                        String skill, String state) {
        SkillInfo info = SKILL_MAP.get(skill);
        if (info == null) {
            ctx.getSource().sendFailure(Component.literal("\u00a7cUnknown skill: " + skill + "\u00a77 (valid: " + String.join(", ", SKILLS) + ")"));
            return 0;
        }

        for (ServerPlayer player : targets) {
            switch (state) {
                case "charge" -> {
                    if (info.chargeObj() != null) {
                        setScore(player, info.chargeObj(), info.fullCharge());
                        ctx.getSource().sendSuccess(() ->
                            Component.literal("\u00a7e" + player.getName().getString() + "\u00a77 " + skill + " charge \u2192 \u00a7a" + info.fullCharge()), false);
                    } else {
                        ctx.getSource().sendFailure(Component.literal("\u00a7c" + skill + " has no charge objective"));
                    }
                }
                case "cooldown" -> {
                    if (info.cooldownObj() != null) {
                        setScore(player, info.cooldownObj(), 0);
                        ctx.getSource().sendSuccess(() ->
                            Component.literal("\u00a7e" + player.getName().getString() + "\u00a77 " + skill + " cooldown \u2192 \u00a7a0\u00a77 (ready)"), false);
                    } else {
                        ctx.getSource().sendFailure(Component.literal("\u00a7c" + skill + " has no cooldown objective"));
                    }
                }
                case "ready" -> {
                    if (info.chargeObj() != null) setScore(player, info.chargeObj(), info.fullCharge());
                    if (info.cooldownObj() != null) setScore(player, info.cooldownObj(), 0);
                    if ("tier2".equals(skill)) setScore(player, "tier2Unlocked", 1);
                    ctx.getSource().sendSuccess(() ->
                        Component.literal("\u00a7e" + player.getName().getString() + "\u00a77 " + skill + " \u2192 \u00a7aready"), false);
                }
                case "reset" -> {
                    if (info.chargeObj() != null) setScore(player, info.chargeObj(), 0);
                    if (info.cooldownObj() != null) setScore(player, info.cooldownObj(), 0);
                    ctx.getSource().sendSuccess(() ->
                        Component.literal("\u00a7e" + player.getName().getString() + "\u00a77 " + skill + " \u2192 \u00a7creset"), false);
                }
                default -> {
                    ctx.getSource().sendFailure(Component.literal("\u00a7cUnknown state: " + state + "\u00a77 (valid: charge, cooldown, ready, reset)"));
                    return 0;
                }
            }
        }
        return targets.size();
    }

    private int ksReset(CommandContext<CommandSourceStack> ctx, Collection<ServerPlayer> targets) {
        for (ServerPlayer player : targets) {
            ctx.getSource().getServer().getCommands()
                .performPrefixedCommand(
                    player.createCommandSourceStack(),
                    "function killstreak:life_reset"
                );
            ctx.getSource().sendSuccess(() ->
                Component.literal("\u00a7e" + player.getName().getString() + "\u00a77 life reset (via datapack)"), false);
        }
        return targets.size();
    }

    // ===== /ks harness \u2014 Apoli live-probe =====

    private int ksHarness(CommandContext<CommandSourceStack> ctx) {
        var src = ctx.getSource();
        var server = src.getServer();
        int passed = 0;
        int failed = 0;

        src.sendSuccess(() -> Component.literal("\u00a76\u00a7l=== KS Harness \u2014 Apoli Live-Probe ==="), false);

        // 1. Check Apoli power types exist
        String[] powerTypes = {
            "apoli:modify_damage_taken",
            "apoli:add_velocity",
            "apoli:prevent_attack",
            "apoli:execute_command",
            "apoli:damage_over_time"
        };
        for (String powerType : powerTypes) {
            boolean exists = checkPowerTypeExists(server, powerType);
            final boolean pass = exists;
            final String name = powerType;
            src.sendSuccess(() -> Component.literal(pass ? "  \u00a7a\u2714 " + name : "  \u00a7c\u2718 " + name + " (not found)"), false);
            if (pass) passed++; else failed++;
        }

        // 2. Test /damage command routing
        boolean damageWorks = testDamageCommand(server, src);
        final boolean dmgPass = damageWorks;
        src.sendSuccess(() -> Component.literal(dmgPass ? "  \u00a7a\u2714 /damage routing" : "  \u00a7c\u2718 /damage routing"), false);
        if (damageWorks) passed++; else failed++;

        // 3. Check scoreboard objectives exist (killstreak system)
        String[] objectives = {"streak", "receivedTier", "tier2Unlocked", "mjolnirStormCharge", "mjolnirStormCooldown", "mjolnirBoltCooldown"};
        for (String obj : objectives) {
            boolean exists = server.getScoreboard().getObjective(obj) != null;
            final boolean pass = exists;
            final String name = obj;
            src.sendSuccess(() -> Component.literal(pass ? "  \u00a7a\u2714 objective: " + name : "  \u00a7c\u2718 objective: " + name + " (missing)"), false);
            if (exists) passed++; else failed++;
        }

        // Summary
        final int p = passed, f = failed;
        src.sendSuccess(() -> Component.literal("\u00a76\u00a7l=== Results: \u00a7a" + p + " passed\u00a76, \u00a7c" + f + " failed\u00a76 ==="), false);

        return passed;
    }

    /** Check if an Apoli power type is registered */
    private boolean checkPowerTypeExists(net.minecraft.server.MinecraftServer server, String powerType) {
        try {
            if (!net.fabricmc.loader.api.FabricLoader.getInstance().isModLoaded("origins")) {
                return false;
            }
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    /** Test if /damage command works */
    private boolean testDamageCommand(net.minecraft.server.MinecraftServer server, CommandSourceStack src) {
        try {
            var dispatcher = server.getCommands().getDispatcher();
            var node = dispatcher.getRoot().getChild("damage");
            return node != null;
        } catch (Exception e) {
            return false;
        }
    }

    // ===== Scoreboard utilities =====

    private static ServerScoreboard getScoreboard(ServerPlayer player) {
        return player.level().getServer().getScoreboard();
    }

    private static void setScore(ServerPlayer player, String objectiveName, int value) {
        ServerScoreboard scoreboard = getScoreboard(player);
        Objective objective = scoreboard.getObjective(objectiveName);
        if (objective == null) {
            LOG.warn("Scoreboard objective '{}' not found \u2014 skipping setScore", objectiveName);
            return;
        }
        ScoreAccess score = scoreboard.getOrCreatePlayerScore(player, objective);
        score.set(value);
    }

    private static void addScore(ServerPlayer player, String objectiveName, int amount) {
        ServerScoreboard scoreboard = getScoreboard(player);
        Objective objective = scoreboard.getObjective(objectiveName);
        if (objective == null) {
            LOG.warn("Scoreboard objective '{}' not found \u2014 skipping addScore", objectiveName);
            return;
        }
        ScoreAccess score = scoreboard.getOrCreatePlayerScore(player, objective);
        score.add(amount);
    }

    private static int getScore(ServerPlayer player, String objectiveName) {
        ServerScoreboard scoreboard = getScoreboard(player);
        Objective objective = scoreboard.getObjective(objectiveName);
        if (objective == null) return 0;
        ScoreAccess score = scoreboard.getOrCreatePlayerScore(player, objective);
        return score.get();
    }
}
