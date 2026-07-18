using System;
using System.Collections;
using engine.diagnostics;

namespace game;

class bullet_system
{
    public const float GRAZE_MARGIN = 12.0f;
    public const float GRAZE_VISUAL_DURATION = 0.25f;
    public const float INVINCIBILITY_DURATION = 1.5f;

    public static void update(List<enemy_bullet> bullets, bullet_pattern pattern, float delta_time, my_game game)
    {
        if (pattern != null)
            pattern.update(delta_time, game);

        float center_x = game.arena_x + game.arena_w / 2.0f;
        float center_y = game.arena_y + game.arena_h / 2.0f;

        for (int i = 0; i < bullets.Count; i++)
        {
            enemy_bullet bullet = bullets[i];

            if (!bullet.Update(delta_time, game))
            {
                bullets.RemoveAt(i);
                i--;
                continue;
            }

            if (check_collision(&bullet, game) && game.invincibility_timer <= 0.0f)
            {
                apply_damage(&bullet, game);

                if (bullet.type != .LaserActive)
                {
                    bullets.RemoveAt(i);
                    i--;
                    continue;
                }
            }

            check_graze(&bullet, game);

            if (is_out_of_bounds(&bullet, center_x, center_y))
            {
                bullets.RemoveAt(i);
                i--;
                continue;
            }

            bullets[i] = bullet;
        }
    }

    private static void apply_damage(enemy_bullet* bullet, my_game game)
    {
        if (game.m_combat.active_defense == .Evade)
        {
            if (game_rand.next_float() < 0.20f)
            {
                logger.game("Evaded! 0 damage taken.");
                game.invincibility_timer = INVINCIBILITY_DURATION;
                game.invincibility_phase = 0.0f;
                return;
            }
        }

        int damage_taken = (int)(bullet.damage * game.m_soul.resistance);
        game.m_player.take_damage(damage_taken);
        game.m_player.add_tp(-10);
        logger.game(scope $"The player took damage! Health: {game.m_player.health}. TP lost!");

        if (game.m_combat.active_defense == .Counter)
        {
            int counter_damage = damage_taken / 2;
            if (counter_damage < 1) counter_damage = 1;
            game.m_enemy.take_damage(counter_damage);
            logger.game(scope $"Counter Activated! Dealt {counter_damage} damage to enemy.");
        }

        game.invincibility_timer = INVINCIBILITY_DURATION;
        game.invincibility_phase = 0.0f;
    }

    private static bool is_out_of_bounds(enemy_bullet* bullet, float center_x, float center_y)
    {
        if (!bullet.type.IsBounded)
            return false;

        float dx = bullet.x - center_x;
        float dy = bullet.y - center_y;
        return (dx * dx + dy * dy) > 250.0f * 250.0f;
    }

    private static bool check_collision(enemy_bullet* bullet, my_game game)
    {
        float soul_x = game.get_soul_x();
        float soul_y = game.get_soul_y();
        float soul_size = game.get_soul_size();
        float scx = soul_x + soul_size / 2.0f;
        float scy = soul_y + soul_size / 2.0f;

        if (bullet.type == .LaserActive)
        {
            float min_x = Math.Min(bullet.x, bullet.speed_x);
            float max_x = Math.Max(bullet.x, bullet.speed_x);
            float min_y = Math.Min(bullet.y, bullet.speed_y);
            float max_y = Math.Max(bullet.y, bullet.speed_y);
            float r = game.m_soul.hitbox_radius + bullet.size / 2.0f;


            if (scx < min_x - r || scx > max_x + r ||
                scy < min_y - r || scy > max_y + r)
            {
                return false;
            }

            float vx = bullet.speed_x - bullet.x;
            float vy = bullet.speed_y - bullet.y;
            float v_lensq = vx * vx + vy * vy;

            if (v_lensq > 0.0f)
            {
                float wx = scx - bullet.x;
                float wy = scy - bullet.y;
                float t = (wx * vx + wy * vy) / v_lensq;
                if (t < 0.0f) t = 0.0f;
                if (t > 1.0f) t = 1.0f;

                float dx = scx - (bullet.x + t * vx);
                float dy = scy - (bullet.y + t * vy);
                float dist_sq = dx * dx + dy * dy;

                return dist_sq < r * r;
            }
        }
        else if (bullet.type.IsCollidable)
        {
            float closest_x = Math.Clamp(scx, bullet.x, bullet.x + bullet.size);
            float closest_y = Math.Clamp(scy, bullet.y, bullet.y + bullet.size);

            float dx = scx - closest_x;
            float dy = scy - closest_y;
            float dist_sq = dx * dx + dy * dy;

            return dist_sq < game.m_soul.hitbox_radius * game.m_soul.hitbox_radius;
        }
        return false;
    }

    private static void check_graze(enemy_bullet* bullet, my_game game)
    {
        if (!bullet.type.IsBounded)
            return;

        float soul_x = game.get_soul_x();
        float soul_y = game.get_soul_y();
        float soul_size = game.get_soul_size();

        bool in_range = (soul_x - GRAZE_MARGIN < bullet.x + bullet.size &&
                          soul_x + soul_size + GRAZE_MARGIN > bullet.x &&
                          soul_y - GRAZE_MARGIN < bullet.y + bullet.size &&
                          soul_y + soul_size + GRAZE_MARGIN > bullet.y);

        if (in_range)
        {
            game.graze_visual_timer = GRAZE_VISUAL_DURATION;
            if (!bullet.is_grazed)
            {
                bullet.is_grazed = true;
                game.m_player.add_tp(2);
                logger.game(scope $"Graze! TP gained. Current TP: {game.m_player.tp}");
            }
        }
    }
}
