using System;
using SDL3;

namespace game;

abstract class bullet_pattern
{
    public float m_spawn_timer = 0.0f;

    public abstract void initialize(my_game game);
    public abstract void update(float delta_time, my_game game);
}

class waves_pattern : bullet_pattern
{
    public override void initialize(my_game game)
    {
        m_spawn_timer = 0.0f;
    }

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        if (m_spawn_timer >= 0.35f)
        {
            m_spawn_timer = 0.0f;
            float arena_y = game.get_arena_y();
            float arena_h = game.get_arena_h();
            float random_y = game_rand.next_range(arena_y, arena_y + arena_h - 12.0f);
            game.spawn_bullet(game.get_arena_x() + game.get_arena_w() + 30.0f, random_y, -180.0f, 0.0f);
        }
    }
}

class spiral_pattern : bullet_pattern
{
    public override void initialize(my_game game)
    {
        m_spawn_timer = 0.0f;
    }

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        float dodge_timer = game.get_dodge_timer();

        if (dodge_timer >= 1.0f)
        {
            if (m_spawn_timer >= 0.12f)
            {
                m_spawn_timer = 0.0f;
                float angle = (dodge_timer - 1.0f) * 4.5f;
                float speed_x = (float)Math.Cos(angle) * 120.0f;
                float speed_y = (float)Math.Sin(angle) * 120.0f;
                float cx = game.get_arena_x() + (game.get_arena_w() / 2.0f) - 6.0f;
                float cy = game.get_arena_y() + (game.get_arena_h() / 2.0f) - 6.0f;
                game.spawn_bullet(cx, cy, speed_x, speed_y);
            }
        }
    }
}

class rain_pattern : bullet_pattern
{
    public override void initialize(my_game game)
    {
        m_spawn_timer = 0.0f;
    }

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        if (m_spawn_timer >= 0.25f)
        {
            m_spawn_timer = 0.0f;
            float arena_x = game.get_arena_x();
            float arena_w = game.get_arena_w();
            float random_x = game_rand.next_range(arena_x, arena_x + arena_w - 12.0f);
            game.spawn_bullet(random_x, game.get_arena_y() - 30.0f, 0.0f, 150.0f);
        }
    }
}

class homing_pattern : bullet_pattern
{
    public override void initialize(my_game game)
    {
        m_spawn_timer = 0.0f;
    }

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        if (m_spawn_timer >= 0.8f)
        {
            m_spawn_timer = 0.0f;
            float target_x = game.get_soul_x() + game.get_soul_size() / 2.0f;
            float target_y = game.get_soul_y() + game.get_soul_size() / 2.0f;
            float enemy_x = game.get_enemy_x();
            float enemy_y = game.get_enemy_y();
            
            float dx = target_x - enemy_x;
            float dy = target_y - enemy_y;
            float dist = (float)Math.Sqrt(dx * dx + dy * dy);
            if (dist > 0.0f)
            {
                float speed_x = (dx / dist) * 220.0f;
                float speed_y = (dy / dist) * 220.0f;
                game.spawn_bullet(enemy_x, enemy_y, speed_x, speed_y);
            }
        }
    }
}
