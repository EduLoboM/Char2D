using System;
using SDL3;

namespace game;

abstract class bullet_pattern
{
    public float m_spawn_timer = 0.0f;

    public virtual void initialize(my_game game) { }
    public abstract void update(float delta_time, my_game game);
}

class waves_pattern : bullet_pattern
{
    private const float SPAWN_INTERVAL = 0.35f;
    private const float BULLET_SPEED = -180.0f;
    private const float SPAWN_OFFSET_X = 30.0f;
    private const float BULLET_SIZE = 12.0f;

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        if (m_spawn_timer >= SPAWN_INTERVAL)
        {
            m_spawn_timer = 0.0f;
            float arena_y = game.arena_y;
            float arena_h = game.arena_h;
            float random_y = game_rand.next_range(arena_y, arena_y + arena_h - BULLET_SIZE);
            game.spawn_bullet(game.arena_x + game.arena_w + SPAWN_OFFSET_X, random_y, BULLET_SPEED, 0.0f);
        }
    }
}

class spiral_pattern : bullet_pattern
{
    private const float SPAWN_INTERVAL = 0.12f;
    private const float DELAY_START = 1.0f;
    private const float BULLET_SPEED = 120.0f;
    private const float ANGLE_SPEED = 4.5f;
    private const float BULLET_HALF_SIZE = 6.0f;

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        float dodge_timer = game.dodge_timer;

        if (dodge_timer >= DELAY_START && m_spawn_timer >= SPAWN_INTERVAL)
        {
            m_spawn_timer = 0.0f;
            float angle = (dodge_timer - DELAY_START) * ANGLE_SPEED;
            float speed_x = (float)Math.Cos(angle) * BULLET_SPEED;
            float speed_y = (float)Math.Sin(angle) * BULLET_SPEED;
            float cx = game.arena_x + (game.arena_w / 2.0f) - BULLET_HALF_SIZE;
            float cy = game.arena_y + (game.arena_h / 2.0f) - BULLET_HALF_SIZE;
            game.spawn_bullet(cx, cy, speed_x, speed_y);
        }
    }
}

class rain_pattern : bullet_pattern
{
    private const float SPAWN_INTERVAL = 0.25f;
    private const float BULLET_SPEED = 150.0f;
    private const float SPAWN_OFFSET_Y = 30.0f;
    private const float BULLET_SIZE = 12.0f;

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        if (m_spawn_timer >= SPAWN_INTERVAL)
        {
            m_spawn_timer = 0.0f;
            float arena_x = game.arena_x;
            float arena_w = game.arena_w;
            float random_x = game_rand.next_range(arena_x, arena_x + arena_w - BULLET_SIZE);
            game.spawn_bullet(random_x, game.arena_y - SPAWN_OFFSET_Y, 0.0f, BULLET_SPEED);
        }
    }
}

class homing_pattern : bullet_pattern
{
    private const float SPAWN_INTERVAL = 0.8f;
    private const float BULLET_SPEED = 220.0f;

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        if (m_spawn_timer >= SPAWN_INTERVAL)
        {
            m_spawn_timer = 0.0f;
            float target_x = game.soul_x + game.soul_size / 2.0f;
            float target_y = game.soul_y + game.soul_size / 2.0f;
            float enemy_x = game.enemy_x;
            float enemy_y = game.enemy_y;

            float dx = target_x - enemy_x;
            float dy = target_y - enemy_y;
            float dist = (float)Math.Sqrt(dx * dx + dy * dy);
            if (dist > 0.0f)
            {
                float speed_x = (dx / dist) * BULLET_SPEED;
                float speed_y = (dy / dist) * BULLET_SPEED;
                game.spawn_bullet(enemy_x, enemy_y, speed_x, speed_y);
            }
        }
    }
}

class sine_wave_pattern : bullet_pattern
{
    private const float SPAWN_INTERVAL = 0.5f;
    private const float BULLET_SPEED = -160.0f;
    private const float SPAWN_OFFSET_X = 20.0f;
    private const float TOP_MARGIN = 30.0f;
    private const float BOTTOM_MARGIN = 42.0f;

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        if (m_spawn_timer >= SPAWN_INTERVAL)
        {
            m_spawn_timer = 0.0f;
            float arena_y = game.arena_y;
            float arena_h = game.arena_h;
            float base_y = game_rand.next_range(arena_y + TOP_MARGIN, arena_y + arena_h - BOTTOM_MARGIN);
            game.spawn_custom_bullet(game.arena_x + game.arena_w + SPAWN_OFFSET_X, base_y, BULLET_SPEED, 0.0f, .SineWave, base_y);
            game.spawn_custom_bullet(game.arena_x + game.arena_w + SPAWN_OFFSET_X, base_y, BULLET_SPEED, 0.0f, .SineWaveDNA, base_y);
        }
    }
}

class fragmentation_pattern : bullet_pattern
{
    private const float SPAWN_INTERVAL = 1.6f;
    private const float SPAWN_DISTANCE = 180.0f;
    private const float BULLET_SPEED = 90.0f;
    private const float BULLET_SIZE = 18.0f;
    private const int BULLET_DAMAGE = 15;

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        if (m_spawn_timer >= SPAWN_INTERVAL)
        {
            m_spawn_timer = 0.0f;

            float cx = game.arena_x + game.arena_w / 2.0f;
            float cy = game.arena_y + game.arena_h / 2.0f;

            float angle = game_rand.next_range(0.0f, 2.0f * Math.PI_f);
            float sx = cx + (float)Math.Cos(angle) * SPAWN_DISTANCE;
            float sy = cy + (float)Math.Sin(angle) * SPAWN_DISTANCE;

            float dx = cx - sx;
            float dy = cy - sy;
            float dist = (float)Math.Sqrt(dx * dx + dy * dy);
            float vx = (dx / dist) * BULLET_SPEED;
            float vy = (dy / dist) * BULLET_SPEED;

            game.spawn_custom_bullet(sx, sy, vx, vy, .Fragmentation, size: BULLET_SIZE, damage: BULLET_DAMAGE);
        }
    }
}

class laser_web_pattern : bullet_pattern
{
    private float m_wave_timer = 0.0f;
    private const float WAVE_INTERVAL = 2.6f;
    private const int LASER_COUNT = 6;
    private const float SPAWN_MARGIN = 20.0f;
    private const float LASER_LENGTH = 320.0f;
    private const float LASER_SIZE = 8.0f;
    private const int LASER_DAMAGE = 15;

    public override void initialize(my_game game)
    {
        m_wave_timer = 0.0f;
        spawn_web_wave(game);
    }

    public override void update(float delta_time, my_game game)
    {
        m_wave_timer += delta_time;
        if (m_wave_timer >= WAVE_INTERVAL)
        {
            m_wave_timer = 0.0f;
            spawn_web_wave(game);
        }
    }

    private void spawn_web_wave(my_game game)
    {
        float ax = game.arena_x;
        float ay = game.arena_y;
        float aw = game.arena_w;
        float ah = game.arena_h;

        for (int i = 0; i < LASER_COUNT; i++)
        {
            float px = game_rand.next_range(ax + SPAWN_MARGIN, ax + aw - SPAWN_MARGIN);
            float py = game_rand.next_range(ay + SPAWN_MARGIN, ay + ah - SPAWN_MARGIN);

            float angle = game_rand.next_range(0.0f, 2.0f * Math.PI_f);
            float dx = (float)Math.Cos(angle);
            float dy = (float)Math.Sin(angle);

            float x1 = px - dx * LASER_LENGTH;
            float y1 = py - dy * LASER_LENGTH;
            float x2 = px + dx * LASER_LENGTH;
            float y2 = py + dy * LASER_LENGTH;

            game.spawn_custom_bullet(x1, y1, x2, y2, .LaserTelegraph, size: LASER_SIZE, damage: LASER_DAMAGE);
        }
    }
}
