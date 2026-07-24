using System;

namespace game;

struct enemy_bullet {
    public float x;
    public float y;
    public float size = 12.0f;
    public float speed_x = 0.0f;
    public float speed_y = 0.0f;
    public int damage = 10;
    public bool is_grazed = false;
    public BulletType type = .Normal;
    public float timer = 0.0f;
    public float extra_x = 0.0f;
    public float extra_y = 0.0f;

    public this(float x, float y, float speed_x, float speed_y, float size = 12.0f, int damage = 10) {
        this.x = x;
        this.y = y;
        this.speed_x = speed_x;
        this.speed_y = speed_y;
        this.size = size;
        this.damage = damage;
        this.is_grazed = false;
        this.type = .Normal;
        this.timer = 0.0f;
        this.extra_x = 0.0f;
        this.extra_y = 0.0f;
    }

    public bool Update(float delta_time, my_game game) mut
    {
        switch (type)
        {
            case .SineWave:
                update_sine_wave(delta_time);
            case .SineWaveDNA:
                update_sine_wave_dna(delta_time);
            case .Fragmentation:
                update_fragmentation(delta_time, game);
            case .Explosion:
                if (!update_explosion(delta_time))
                    return false;
            case .LaserTelegraph:
                update_laser_telegraph(delta_time);
            case .LaserActive:
                if (!update_laser_active(delta_time))
                    return false;
            case .VortexCenter:

                break;
            case .DiamondOrbiter:
                update_diamond_orbiter(delta_time, game);
            default:
                update_default(delta_time);
        }

        return true;
    }

    private void update_sine_wave(float delta_time) mut
    {
        timer += delta_time;
        x += speed_x * delta_time;
        y = extra_x + (float)Math.Sin(timer * 7.5f) * 50.0f;
    }

    private void update_sine_wave_dna(float delta_time) mut
    {
        timer += delta_time;
        x += speed_x * delta_time;
        y = extra_x + (float)Math.Cos(timer * 7.5f) * 50.0f;
    }

    private void update_fragmentation(float delta_time, my_game game) mut
    {
        timer += delta_time;
        x += speed_x * delta_time;
        y += speed_y * delta_time;

        if (timer >= 1.5f)
        {
            type = .Explosion;
            timer = 0.0f;
            speed_x = 0.0f;
            speed_y = 0.0f;

            for (int angle_deg = 0; angle_deg < 360; angle_deg += 45)
            {
                float angle_rad = (float)(angle_deg * (Math.PI_f / 180.0f));
                float vx = (float)Math.Cos(angle_rad) * 140.0f;
                float vy = (float)Math.Sin(angle_rad) * 140.0f;
                float bx = x + size / 2.0f - 4.0f;
                float by = y + size / 2.0f - 4.0f;
                game.spawn_custom_bullet(bx, by, vx, vy, .FragmentationSmall, size: 8.0f, damage: 5);
            }
        }
    }

    private bool update_explosion(float delta_time) mut
    {
        timer += delta_time;
        return timer < 0.25f;
    }

    private void update_laser_telegraph(float delta_time) mut
    {
        timer += delta_time;
        if (timer >= 1.0f)
        {
            type = .LaserActive;
            timer = 0.0f;
        }
    }

    private bool update_laser_active(float delta_time) mut
    {
        timer += delta_time;
        return timer < 0.2f;
    }

    private void update_diamond_orbiter(float delta_time, my_game game) mut
    {
        timer += delta_time;
        extra_x += 2.2f * delta_time;

        float cx = game.arena_x + game.arena_w / 2.0f;
        float cy = game.arena_y + game.arena_h / 2.0f;
        float orbit_radius = extra_y;
        x = cx + (float)Math.Cos(extra_x) * orbit_radius - size / 2.0f;
        y = cy + (float)Math.Sin(extra_x) * orbit_radius - size / 2.0f;
    }

    private void update_default(float delta_time) mut
    {
        x += speed_x * delta_time;
        y += speed_y * delta_time;
    }
}
