using System;
using System.Collections;
using engine.core;
using engine.diagnostics;
using SDL3;

namespace game;

class my_game : i_game_loop
{
    public List<character> m_party = new .() ~ delete _;
    public List<character> m_enemies = new .() ~ delete _;

    public combat_manager m_combat = new .() ~ delete _;
    public input_state m_input;
    public arena m_arena = new .(layout.ARENA_DEFAULT_X, layout.ARENA_DEFAULT_Y, layout.ARENA_DEFAULT_W, layout.ARENA_DEFAULT_H) ~ delete _;
    public player_soul m_soul = new .() ~ delete _;

    public texture_cache m_textures = new .() ~ delete _;
    public float m_game_time = 0.0f;

    public float invincibility_timer = 0.0f;
    public float invincibility_phase = 0.0f;
    public float graze_visual_timer = 0.0f;

    public character m_player => m_party.Count > 0 ? m_party[0] : null;
    public character m_enemy => m_enemies.Count > 0 ? m_enemies[0] : null;

    public float arena_x => m_arena.x;
    public float arena_y => m_arena.y;
    public float arena_w => m_arena.w;
    public float arena_h => m_arena.h;

    public float get_soul_x() => m_soul.x;
    public float get_soul_y() => m_soul.y;
    public float get_soul_size() => m_soul.size;
    public float get_enemy_x() => m_enemy.x;
    public float get_enemy_y() => m_enemy.y;
    public float get_dodge_timer() => m_combat.dodge_timer;

    public float soul_x => m_soul.x;
    public float soul_y => m_soul.y;
    public float soul_size => m_soul.size;
    public float soul_center_x => m_soul.center_x;
    public float soul_center_y => m_soul.center_y;
    public float enemy_x => m_enemy.x;
    public float enemy_y => m_enemy.y;
    public float dodge_timer => m_combat.dodge_timer;

    public void spawn_bullet(float x, float y, float speed_x, float speed_y)
    {
        m_combat.spawn_bullet(x, y, speed_x, speed_y);
    }

    public void spawn_custom_bullet(float x, float y, float speed_x, float speed_y, BulletType type, float extra_x = 0.0f, float extra_y = 0.0f, float size = 12.0f, int damage = 10)
    {
        m_combat.spawn_custom_bullet(x, y, speed_x, speed_y, type, extra_x, extra_y, size, damage);
    }

    public void initialize()
    {
        logger.setup("my_game has initialized!");

        m_party.Add(new character("Hero", 100, 10, 5, 5, 78.0f, 150.0f, "game/ast/images/sprite/character.png", 64, 64));
        m_enemies.Add(new character("Demon", 100, 10, 5, 5, 498.0f, 150.0f, "game/ast/images/sprite/polar_bear_2026.png", 64, 64));

        m_soul.reset_position(m_arena);
        m_combat.initialize();
    }

    public void update(float delta_time)
    {
        float dt = Math.Min(delta_time, 0.1f);

        bool* keys = (bool*)SDL_GetKeyboardState(null);
        m_input.update(keys);

        m_game_time += dt;

        for (var c in m_party)
            c.update_shake(dt);
        for (var c in m_enemies)
            c.update_shake(dt);

        if (graze_visual_timer > 0.0f)
        {
            graze_visual_timer -= dt;
            if (graze_visual_timer < 0.0f)
                graze_visual_timer = 0.0f;
        }

        update_invincibility(dt);

        m_combat.update(dt, ref m_input, this);

        check_battle_status();
    }

    private void update_invincibility(float delta_time)
    {
        if (invincibility_timer > 0.0f)
        {
            float progress = (bullet_system.INVINCIBILITY_DURATION - invincibility_timer) / bullet_system.INVINCIBILITY_DURATION;
            float current_frequency = 6.0f + progress * 24.0f;
            invincibility_phase += delta_time * current_frequency;

            invincibility_timer -= delta_time;
            if (invincibility_timer < 0.0f)
            {
                invincibility_timer = 0.0f;
                invincibility_phase = 0.0f;
            }
        }
    }

    private void check_battle_status()
    {
        if (m_player.is_dead())
        {
            logger.game("Player died! Respawning...");
            respawn_player();
        }

        if (m_enemy.is_dead())
        {
            logger.game("Enemy died! Respawning...");
            respawn_enemy();
        }
    }

    private void respawn_player()
    {
        for (var c in m_party)
            c.reset_character(78.0f, 150.0f);
        m_combat.m_last_mg_type = null;
        m_combat.m_last_pattern = null;
        invincibility_timer = 0.0f;
        invincibility_phase = 0.0f;
        m_combat.start_strategy_phase(this);
    }

    private void respawn_enemy()
    {
        for (var c in m_enemies)
        {
            c.max_health += 10;
            c.attack_power += 2;
            c.reset_character(498.0f, 150.0f);
        }
        m_combat.m_last_mg_type = null;
        m_combat.m_last_pattern = null;
        m_combat.start_strategy_phase(this);
    }

    public void draw(SDL_Renderer* renderer, float alpha)
    {
        if (m_combat.m_current_state == .strategy || m_combat.m_current_state == .selecting_minigame || m_combat.m_current_state == .selecting_defense)
            combat_renderer.draw_action_panel(renderer, m_combat.m_selected_action);

        for (var c in m_party)
        {
            combat_renderer.draw_character_bars(renderer, c, true, m_combat.m_current_state, m_combat.player_actions_left, m_combat.max_player_actions, m_game_time);
            combat_renderer.draw_character_sprite(renderer, c, m_textures);
        }

        for (var c in m_enemies)
        {
            combat_renderer.draw_character_bars(renderer, c, false, m_combat.m_current_state, m_combat.player_actions_left, 1, m_game_time);
            combat_renderer.draw_character_sprite(renderer, c, m_textures);
        }

        if (m_combat.m_current_state == .dodging)
        {
            combat_renderer.draw_arena(renderer, this, m_textures);

            for (int i = 0; i < m_combat.m_bullets.Count; i++)
                combat_renderer.draw_bullet(renderer, ref m_combat.m_bullets[i], m_game_time);
        }

        if (m_combat.m_current_state == .minigame)
            combat_renderer.draw_minigame_panel(renderer, m_combat.m_active_minigame, this);

        if (m_combat.m_current_state == .selecting_minigame)
            combat_renderer.draw_minigame_selection(renderer, m_combat.m_selected_minigame, m_player.tp);

        if (m_combat.m_current_state == .selecting_defense)
            combat_renderer.draw_defense_selection(renderer, m_combat.m_selected_defense);
    }

    public void cleanup()
    {
        logger.setup("my_game is cleaning up!");

        m_textures.cleanup();

        for (var c in m_party)
            delete c;
        m_party.Clear();

        for (var c in m_enemies)
            delete c;
        m_enemies.Clear();
    }
}
