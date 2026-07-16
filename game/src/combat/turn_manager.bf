using System;
using engine.diagnostics;

namespace game;

class turn_manager
{
    public static void execute_action(ActionType action, my_game game, combat_manager manager)
    {
        switch (action)
        {
            case .Fight:
                logger.game("Attack Action.");
                if (game.m_player.tp >= 15)
                    manager.enter_minigame_selection();
                else
                    logger.game("Not enough TP!");

            case .Item:
                logger.game("Item Action.");
                game.m_player.heal(20);
                manager.player_actions_left--;
                check_turn_resolution(game, manager);

            case .Defend:
                logger.game("Defend Action.");
                manager.enter_defense_selection();

            case .Mercy:
                logger.game("Mercy Action.");
                if (game.m_enemy.is_mercy_ready())
                {
                    logger.game("Enemy spared! Defeating...");
                    game.m_enemy.take_damage(game.m_enemy.health);
                }
                else
                {
                    game.m_enemy.add_mercy(1);
                }
                manager.player_actions_left--;
                check_turn_resolution(game, manager);
        }
    }

    public static void resolve_attack(float dist, my_game game, combat_manager manager)
    {
        float score = 1.0f;
        int stagger_gain = 0;

        if (dist <= 0.05f)
        {
            manager.set_mg_result("PERFECT!");
            score = 1.5f;
            stagger_gain = 2;
        }
        else if (dist <= 0.18f)
        {
            manager.set_mg_result("GOOD");
            score = 1.0f;
            stagger_gain = 1;
        }
        else if (dist < 0.6f)
        {
            manager.set_mg_result("WEAK");
            score = 0.5f;
            stagger_gain = 1;
        }
        else
        {
            manager.set_mg_result("MISS");
            score = 0.0f;
            stagger_gain = 0;
        }

        manager.mg_result_timer = 0.8f;
        manager.set_state(.strategy);
        manager.clear_active_minigame();

        int damage = (int)(game.m_player.attack_power * 2 * score * manager.current_mg_multiplier);
        game.m_enemy.take_damage(damage);

        game.m_enemy.add_stagger(stagger_gain);

        logger.game(scope $"Minigame result: {manager.mg_result_text}, damage={damage}, stagger_gain={stagger_gain}");

        manager.player_actions_left--;
        check_turn_resolution(game, manager);
    }

    public static void check_turn_resolution(my_game game, combat_manager manager)
    {
        if (game.m_enemy.is_dead())
            return;

        if (manager.max_player_actions == 2 && manager.player_actions_left == 1)
        {
            logger.game("First extra action used. Clearing stagger bar.");
            game.m_enemy.recover_from_stun();
        }

        if (manager.player_actions_left <= 0)
        {
            if (manager.max_player_actions == 2)
            {
                logger.game("Extra turn finished. Entering dodge phase.");
                manager.start_dodge_phase(game);
            }
            else if (game.m_enemy.is_staggered())
            {
                logger.game("Enemy Staggered! Skipping dodge phase.");
                manager.start_strategy_phase(game);
            }
            else
            {
                manager.start_dodge_phase(game);
            }
        }
    }
}
