using System;
using System.Collections;
using engine.diagnostics;
using SDL3;

namespace game;

class combat_manager
{
    public combat_state m_current_state = .strategy;
    public attack_minigame m_active_minigame = null ~ delete _;
    public bullet_pattern m_active_pattern = null ~ delete _;

    public List<enemy_bullet> m_bullets = new .() ~ delete _;
    public float dodge_timer = 0.0f;
    public const float MAX_DODGE_TIME = 8.0f;

    public ActionType m_selected_action = .Fight;
    public MinigameType m_selected_minigame = .Slider;
    public DefenseType m_selected_defense = .Evade;
    public DefenseType? active_defense = null;
    public MinigameType? m_last_mg_type = null;
    public BulletPatternType? m_last_pattern = null;
    public float current_mg_multiplier = 1.0f;

    public int player_actions_left = 1;
    public int max_player_actions = 1;

    public float mg_result_timer = 0.0f;
    private String m_mg_result_text = new .() ~ delete _;
    public StringView mg_result_text => m_mg_result_text;

    public void set_mg_result(StringView text) { m_mg_result_text.Set(text); }
    public void set_state(combat_state state) { m_current_state = state; }
    public void clear_active_minigame() { delete m_active_minigame; m_active_minigame = null; }

    public void spawn_bullet(float x, float y, float speed_x, float speed_y)
    {
        m_bullets.Add(.(x, y, speed_x, speed_y));
    }

    public void spawn_custom_bullet(float x, float y, float speed_x, float speed_y, BulletType type, float extra_x = 0.0f, float extra_y = 0.0f, float size = 12.0f, int damage = 10)
    {
        enemy_bullet bullet = .(x, y, speed_x, speed_y, size, damage);
        bullet.type = type;
        bullet.extra_x = extra_x;
        bullet.extra_y = extra_y;
        m_bullets.Add(bullet);
    }

    public void initialize()
    {
        m_current_state = .strategy;
        player_actions_left = 1;
        max_player_actions = 1;
        m_selected_action = .Fight;
        m_last_mg_type = null;
        m_last_pattern = null;
    }

    public void update(float delta_time, ref input_state input, my_game game)
    {
        if (mg_result_timer > 0.0f)
            mg_result_timer -= delta_time;

        switch (m_current_state)
        {
            case .strategy:
                update_strategy(ref input, game);
            case .selecting_minigame:
                update_selecting_minigame(ref input, game);
            case .selecting_defense:
                update_selecting_defense(ref input, game);
            case .minigame:
                if (m_active_minigame != null)
                    m_active_minigame.update(ref input, delta_time, game);
            case .dodging:
                update_dodging(ref input, delta_time, game);
        }
    }

    private void update_strategy(ref input_state input, my_game game)
    {
        if (input.left_just_pressed)
        {
            int val = (int)m_selected_action - 1;
            if (val < 0) val = 3;
            m_selected_action = (ActionType)val;
            logger.game(scope $"Selected Action changed to: {m_selected_action}");
        }
        else if (input.right_just_pressed)
        {
            int val = (int)m_selected_action + 1;
            if (val > 3) val = 0;
            m_selected_action = (ActionType)val;
            logger.game(scope $"Selected Action changed to: {m_selected_action}");
        }

        if (input.space_just_pressed)
            turn_manager.execute_action(m_selected_action, game, this);
    }

    private void update_selecting_minigame(ref input_state input, my_game game)
    {
        if (input.return_just_pressed)
        {
            m_current_state = .strategy;
            logger.game("Cancelled minigame selection.");
            return;
        }

        if (input.left_just_pressed)
        {
            int val = (int)m_selected_minigame - 1;
            if (val < 0) val = 4;
            m_selected_minigame = (MinigameType)val;
        }
        else if (input.right_just_pressed)
        {
            int val = (int)m_selected_minigame + 1;
            if (val > 4) val = 0;
            m_selected_minigame = (MinigameType)val;
        }

        if (input.space_just_pressed)
        {
            int cost = m_selected_minigame.TpCost;
            if (game.m_player.tp >= cost)
            {
                game.m_player.add_tp(-cost);
                start_minigame(m_selected_minigame);
            }
            else
            {
                logger.game("Not enough TP for this minigame!");
            }
        }
    }

    public void enter_minigame_selection()
    {
        m_current_state = .selecting_minigame;
        m_selected_minigame = .Slider;
        logger.game("Minigame Selection opened.");
    }

    public void enter_defense_selection()
    {
        m_current_state = .selecting_defense;
        m_selected_defense = .Evade;
        logger.game("Defense Selection opened.");
    }

    private void update_selecting_defense(ref input_state input, my_game game)
    {
        if (input.return_just_pressed)
        {
            m_current_state = .strategy;
            logger.game("Cancelled defense selection.");
            return;
        }

        if (input.left_just_pressed)
        {
            switch (m_selected_defense)
            {
                case .Evade: m_selected_defense = .Counter;
                case .Guard: m_selected_defense = .Evade;
                case .Counter: m_selected_defense = .Guard;
            }
        }
        else if (input.right_just_pressed)
        {
            switch (m_selected_defense)
            {
                case .Evade: m_selected_defense = .Guard;
                case .Guard: m_selected_defense = .Counter;
                case .Counter: m_selected_defense = .Evade;
            }
        }

        if (input.space_just_pressed)
        {
            execute_defense(m_selected_defense, game);
        }
    }

    public void execute_defense(DefenseType type, my_game game)
    {
        active_defense = type;
        logger.game(scope $"Selected defense: {type}");

        // Generates 16 TP immediately
        game.m_player.add_tp(16);

        // Pre-apply resistance modifier if Guard
        if (type == .Guard)
            game.m_soul.resistance = 0.5f;
        else
            game.m_soul.resistance = 1.0f;

        m_current_state = .strategy;
        player_actions_left--;
        turn_manager.check_turn_resolution(game, this);
    }

    private void start_minigame(MinigameType type)
    {
        delete m_active_minigame;
        m_current_state = .minigame;
        current_mg_multiplier = type.Multiplier;
        m_active_minigame = type.CreateInstance();
        m_active_minigame.initialize();
        logger.game(scope $"Attack Minigame started: Type {type}");
    }

    public void resolve_attack(float dist, my_game game)
    {
        turn_manager.resolve_attack(dist, game, this);
    }

    private void update_dodging(ref input_state input, float delta_time, my_game game)
    {
        if (input.return_just_pressed)
        {
            start_strategy_phase(game);
            return;
        }

        dodge_timer += delta_time;
        if (dodge_timer >= MAX_DODGE_TIME)
        {
            start_strategy_phase(game);
            return;
        }

        bullet_system.update(m_bullets, m_active_pattern, delta_time, game);
        game.m_soul.update_movement(ref input, delta_time, game.m_arena);
    }

    public void start_dodge_phase(my_game game)
    {
        m_current_state = .dodging;
        logger.game("Dodge Phase.");

        game.m_soul.size = 28.0f;
        game.m_soul.hitbox_radius = 11.0f;
        if (active_defense == .Guard)
        {
            game.m_soul.resistance = 0.5f;
        }
        else
        {
            game.m_soul.resistance = 1.0f;
        }

        game.m_soul.reset_position(game.m_arena);

        m_bullets.Clear();
        dodge_timer = 0.0f;
        game.graze_visual_timer = 0.0f;
        game.invincibility_timer = 0.0f;
        game.invincibility_phase = 0.0f;

        delete m_active_pattern;
        BulletPatternType next_pattern = .Waves;
        while (true)
        {
            next_pattern = (BulletPatternType)(game_rand.next() % 7);
            if (next_pattern != m_last_pattern)
                break;
        }

        m_last_pattern = next_pattern;
        m_active_pattern = next_pattern.CreateInstance();
        m_active_pattern.initialize(game);
        logger.game(scope $"Dodge phase started with Pattern: {next_pattern}");
    }

    public void start_strategy_phase(my_game game)
    {
        m_current_state = .strategy;
        logger.game("Strategy Phase.");
        m_bullets.Clear();
        game.m_soul.resistance = 1.0f;
        game.m_soul.size = 28.0f;
        game.m_soul.hitbox_radius = 11.0f;
        active_defense = null;

        if (game.m_enemy.is_staggered())
        {
            player_actions_left = 2;
            max_player_actions = 2;
            logger.game("Enemy is staggered! Player gets 2 actions.");
        }
        else
        {
            player_actions_left = 1;
            max_player_actions = 1;
        }
    }
}
