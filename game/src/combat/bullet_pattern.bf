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

class bone_zone_pattern : bullet_pattern
{
    private float m_wave_timer = 0.0f;
    private int m_wave_index = 0;
    private const float WAVE_INTERVAL = 0.65f;
    private const float BONE_SPEED = 130.0f;
    private const float BONE_WIDTH = 10.0f;
    private const float BONE_HEIGHT = 28.0f;
    private const int BONES_PER_WAVE = 4;
    private const float SPAWN_OFFSET = 40.0f;

    public override void update(float delta_time, my_game game)
    {
        m_spawn_timer += delta_time;
        m_wave_timer += delta_time;

        if (m_wave_timer >= WAVE_INTERVAL)
        {
            m_wave_timer = 0.0f;
            bool from_bottom = (m_wave_index % 2 == 0);
            m_wave_index++;

            float ax = game.arena_x;
            float aw = game.arena_w;
            float ay = game.arena_y;
            float ah = game.arena_h;

            int safe_slot = (int)(game_rand.next() % (uint32)BONES_PER_WAVE);

            float slot_width = aw / (float)BONES_PER_WAVE;
            for (int i = 0; i < BONES_PER_WAVE; i++)
            {
                if (i == safe_slot) continue;

                float bx = ax + slot_width * i + (slot_width - BONE_WIDTH) / 2.0f;
                float by;
                float vy;

                if (from_bottom)
                {
                    by = ay + ah + SPAWN_OFFSET;
                    vy = -BONE_SPEED;
                }
                else
                {
                    by = ay - SPAWN_OFFSET - BONE_HEIGHT;
                    vy = BONE_SPEED;
                }

                game.spawn_custom_bullet(bx, by, 0.0f, vy, .BoneVertical, size: BONE_WIDTH, damage: 8);
            }
        }
    }
}

class diamond_orbit_pattern : bullet_pattern
{
    private float m_shoot_timer = 0.0f;
    private const int ORBITER_COUNT = 4;
    private const float ORBIT_RADIUS = 70.0f;
    private const float ORBITER_SIZE = 14.0f;
    private const float SHOT_INTERVAL = 1.2f;
    private const float SHOT_SPEED = 175.0f;
    private const float SHOT_SIZE = 8.0f;

    public override void initialize(my_game game)
    {
        float cx = game.arena_x + game.arena_w / 2.0f;
        float cy = game.arena_y + game.arena_h / 2.0f;

        for (int i = 0; i < ORBITER_COUNT; i++)
        {
            float angle = (2.0f * Math.PI_f / (float)ORBITER_COUNT) * i;
            float ox = cx + (float)Math.Cos(angle) * ORBIT_RADIUS - ORBITER_SIZE / 2.0f;
            float oy = cy + (float)Math.Sin(angle) * ORBIT_RADIUS - ORBITER_SIZE / 2.0f;

            game.spawn_custom_bullet(ox, oy, 0.0f, 0.0f, .DiamondOrbiter, extra_x: angle, extra_y: ORBIT_RADIUS, size: ORBITER_SIZE, damage: 0);
        }

        m_shoot_timer = 0.0f;
    }

    public override void update(float delta_time, my_game game)
    {
        m_shoot_timer += delta_time;

        if (m_shoot_timer >= SHOT_INTERVAL)
        {
            m_shoot_timer = 0.0f;

            float target_x = game.soul_center_x;
            float target_y = game.soul_center_y;

            for (int i = 0; i < game.m_combat.m_bullets.Count; i++)
            {
                enemy_bullet b = game.m_combat.m_bullets[i];
                if (b.type == .DiamondOrbiter)
                {
                    float bcx = b.x + b.size / 2.0f;
                    float bcy = b.y + b.size / 2.0f;

                    float dx = target_x - bcx;
                    float dy = target_y - bcy;
                    float dist = (float)Math.Sqrt(dx * dx + dy * dy);
                    if (dist > 0.0f)
                    {
                        float vx = (dx / dist) * SHOT_SPEED;
                        float vy = (dy / dist) * SHOT_SPEED;
                        game.spawn_custom_bullet(bcx - SHOT_SIZE / 2.0f, bcy - SHOT_SIZE / 2.0f, vx, vy, .DiamondShot, size: SHOT_SIZE, damage: 8);
                    }
                }
            }
        }
    }
}

class zigzag_corridor_pattern : bullet_pattern
{
    private float m_wave_timer = 0.0f;
    private int m_side = 0;
    private const float WAVE_INTERVAL = 0.8f;
    private const float WALL_SPEED = 100.0f;
    private const float BULLET_SIZE = 10.0f;
    private const float SPACING = 14.0f;
    private const float GAP_SIZE = 40.0f;
    private const float SPAWN_OFFSET = 30.0f;

    public override void update(float delta_time, my_game game)
    {
        m_wave_timer += delta_time;

        if (m_wave_timer >= WAVE_INTERVAL)
        {
            m_wave_timer = 0.0f;

            float ax = game.arena_x;
            float aw = game.arena_w;
            float ay = game.arena_y;

            float gap_min;
            float gap_max;

            if (m_side == 0)
            {
                gap_min = ax + 10.0f;
                gap_max = ax + aw * 0.35f;
            }
            else
            {
                gap_min = ax + aw * 0.65f - GAP_SIZE;
                gap_max = ax + aw - GAP_SIZE - 10.0f;
            }
            m_side = 1 - m_side;

            float gap_x = game_rand.next_range(gap_min, gap_max);
            float spawn_y = ay - SPAWN_OFFSET;

            float current_x = ax;
            while (current_x < ax + aw)
            {
                if (current_x + BULLET_SIZE > gap_x && current_x < gap_x + GAP_SIZE)
                {
                    current_x += SPACING;
                    continue;
                }

                game.spawn_custom_bullet(current_x, spawn_y, 0.0f, WALL_SPEED, .ZigzagWall, size: BULLET_SIZE, damage: 7);
                current_x += SPACING;
            }
        }
    }
}

class starburst_pattern : bullet_pattern
{
    private float m_burst_timer = 0.0f;
    private const float BURST_INTERVAL = 1.4f;
    private const int SHARD_COUNT = 10;
    private const float SHARD_SPEED = 130.0f;
    private const float SHARD_SIZE = 8.0f;
    private const float EDGE_MARGIN = 25.0f;

    public override void update(float delta_time, my_game game)
    {
        m_burst_timer += delta_time;

        if (m_burst_timer >= BURST_INTERVAL)
        {
            m_burst_timer = 0.0f;

            float ax = game.arena_x;
            float ay = game.arena_y;
            float aw = game.arena_w;
            float ah = game.arena_h;

            float sx;
            float sy;

            int edge = (int)(game_rand.next() % 4);
            switch (edge)
            {
                case 0:
                    sx = game_rand.next_range(ax + EDGE_MARGIN, ax + aw - EDGE_MARGIN);
                    sy = ay + EDGE_MARGIN;
                case 1:
                    sx = game_rand.next_range(ax + EDGE_MARGIN, ax + aw - EDGE_MARGIN);
                    sy = ay + ah - EDGE_MARGIN;
                case 2:
                    sx = ax + EDGE_MARGIN;
                    sy = game_rand.next_range(ay + EDGE_MARGIN, ay + ah - EDGE_MARGIN);
                default:
                    sx = ax + aw - EDGE_MARGIN;
                    sy = game_rand.next_range(ay + EDGE_MARGIN, ay + ah - EDGE_MARGIN);
            }

            float angle_offset = game_rand.next_range(0.0f, Math.PI_f * 2.0f);

            for (int i = 0; i < SHARD_COUNT; i++)
            {
                float angle = angle_offset + (2.0f * Math.PI_f / (float)SHARD_COUNT) * i;
                float vx = (float)Math.Cos(angle) * SHARD_SPEED;
                float vy = (float)Math.Sin(angle) * SHARD_SPEED;

                game.spawn_custom_bullet(sx - SHARD_SIZE / 2.0f, sy - SHARD_SIZE / 2.0f, vx, vy, .StarburstShard, size: SHARD_SIZE, damage: 7);
            }
        }
    }
}
