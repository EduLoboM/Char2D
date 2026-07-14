using System;
using System.Collections;
using SDL3;

namespace game;

class arena_renderer
{
    public static void draw_character_sprite(SDL_Renderer* renderer, character c, texture_cache textures)
    {
        SDL_Texture* tex = textures.get(renderer, c.texture_path);
        if (tex != null)
        {
            if (c.sprite != null)
            {
                c.sprite.Texture = tex;
                c.sprite.Draw(renderer, c.x + c.shake_offset_x, c.y + c.shake_offset_y);
            }
        }
        else
        {
            SDL_FRect rect = .() {
                x = c.x + c.shake_offset_x,
                y = c.y + c.shake_offset_y,
                w = c.width,
                h = c.height
            };
            SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
            SDL_RenderFillRect(renderer, &rect);
        }
    }

    public static void draw_arena(SDL_Renderer* renderer, my_game game, texture_cache textures)
    {
        List<Vector2> vertices = scope .();
        game.m_arena.get_transformed_vertices(vertices);
        draw_utils.draw_filled_polygon(renderer, vertices, colors.ARENA_BG[0], colors.ARENA_BG[1], colors.ARENA_BG[2], colors.ARENA_BG[3]);
        draw_utils.draw_polygon_outline(renderer, vertices, colors.PANEL_BORDER_ALT[0], colors.PANEL_BORDER_ALT[1], colors.PANEL_BORDER_ALT[2], colors.PANEL_BORDER_ALT[3]);

        float soul_x = game.soul_x;
        float soul_y = game.soul_y;
        float soul_size = game.soul_size;
        float cx = game.soul_center_x;
        float cy = game.soul_center_y;

        if (game.graze_visual_timer > 0.0f)
        {
            float radius = soul_size / 2.0f + bullet_system.GRAZE_MARGIN;
            float t = game.graze_visual_timer / bullet_system.GRAZE_VISUAL_DURATION;
            uint8 graze_alpha = (uint8)(t * 80);
            draw_utils.draw_circle_filled(renderer, cx, cy, radius, colors.GRAZE_YELLOW[0], colors.GRAZE_YELLOW[1], colors.GRAZE_YELLOW[2], graze_alpha);
        }

        SDL_Texture* soul_tex = textures.get(renderer, "static/img/sprites/beta_soul.png");
        SDL_FRect soul_rect = .() { x = soul_x, y = soul_y, w = soul_size, h = soul_size };
        uint8 target_alpha = 255;
        if (game.invincibility_timer > 0.0f)
        {
            int blink_step = (int)game.invincibility_phase;
            if (blink_step % 2 == 0)
                target_alpha = 127;
        }

        if (soul_tex != null)
        {
            SDL_SetTextureAlphaMod(soul_tex, target_alpha);
            SDL_RenderTexture(renderer, soul_tex, null, &soul_rect);
            SDL_SetTextureAlphaMod(soul_tex, 255);
        }
        else
        {
            SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
            draw_utils.set_color(renderer, colors.SOUL_GREEN, target_alpha);
            SDL_RenderFillRect(renderer, &soul_rect);
            SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
        }
    }

    public static void draw_bullet(SDL_Renderer* renderer, ref enemy_bullet bullet, float game_time)
    {
        switch (bullet.type)
        {
            case .LaserTelegraph:
                draw_laser_telegraph(renderer, ref bullet, game_time);
            case .LaserActive:
                draw_laser_active(renderer, ref bullet);
            case .VortexCenter:
                draw_vortex(renderer, ref bullet, game_time);
            case .Explosion:
                draw_explosion(renderer, ref bullet);
            default:
                draw_standard_bullet(renderer, ref bullet);
        }
    }

    private static void draw_laser_telegraph(SDL_Renderer* renderer, ref enemy_bullet bullet, float game_time)
    {
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        float dx = bullet.speed_x - bullet.x;
        float dy = bullet.speed_y - bullet.y;
        float len = (float)Math.Sqrt(dx * dx + dy * dy);
        if (len > 0.0f)
        {
            float step = 8.0f;
            float vx = dx / len;
            float vy = dy / len;

            if (Math.Sin(game_time * 25.0f) > 0.0f)
                draw_utils.set_color(renderer, colors.RED, 220);
            else
                draw_utils.set_color(renderer, colors.GOLD, 180);

            for (float d = 0.0f; d < len; d += step)
            {
                float x1 = bullet.x + vx * d;
                float y1 = bullet.y + vy * d;
                float x2 = bullet.x + vx * Math.Min(d + 4.0f, len);
                float y2 = bullet.y + vy * Math.Min(d + 4.0f, len);
                SDL_RenderLine(renderer, x1, y1, x2, y2);
            }
        }
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    private static void draw_laser_active(SDL_Renderer* renderer, ref enemy_bullet bullet)
    {
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        float dx = bullet.speed_x - bullet.x;
        float dy = bullet.speed_y - bullet.y;
        float len = (float)Math.Sqrt(dx * dx + dy * dy);
        if (len > 0.0f)
        {
            float px = -dy / len;
            float py = dx / len;
            draw_utils.set_color(renderer, colors.RED);
            for (int offset = -2; offset <= 2; offset++)
            {
                SDL_RenderLine(
                    renderer,
                    bullet.x + px * offset,
                    bullet.y + py * offset,
                    bullet.speed_x + px * offset,
                    bullet.speed_y + py * offset
                );
            }
        }
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    private static void draw_vortex(SDL_Renderer* renderer, ref enemy_bullet bullet, float game_time)
    {
        float bcx = bullet.x + bullet.size / 2.0f;
        float bcy = bullet.y + bullet.size / 2.0f;

        draw_utils.draw_circle_filled(renderer, bcx, bcy, bullet.size / 2.0f, 15, 10, 25, 255);

        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        for (int r_idx = 0; r_idx < 3; r_idx++)
        {
            float angle_offset = game_time * 5.0f + r_idx * 1.5f;
            float base_radius = bullet.size / 2.0f + 4.0f + r_idx * 6.0f;
            float bradius = base_radius + (float)Math.Sin(game_time * 8.0f + r_idx) * 2.0f;

            draw_utils.draw_circle_outline(renderer, bcx, bcy, bradius, colors.PURPLE[0], colors.PURPLE[1], colors.PURPLE[2], 200);

            float dot_x = bcx + (float)Math.Cos(angle_offset) * bradius;
            float dot_y = bcy + (float)Math.Sin(angle_offset) * bradius;
            draw_utils.draw_circle_filled(renderer, dot_x, dot_y, 3.0f, colors.PURPLE[0], colors.PURPLE[1], colors.PURPLE[2], 220);
        }
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    private static void draw_explosion(SDL_Renderer* renderer, ref enemy_bullet bullet)
    {
        float t = bullet.timer / 0.25f;
        float current_size = bullet.size * (1.0f + t * 2.0f);
        SDL_FRect bullet_rect = .() {
            x = bullet.x - (current_size - bullet.size) / 2.0f,
            y = bullet.y - (current_size - bullet.size) / 2.0f,
            w = current_size,
            h = current_size
        };

        uint8 r = colors.RED[0];
        uint8 g = (uint8)((1.0f - t) * 200);
        uint8 b = (uint8)((1.0f - t) * 50);
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        SDL_RenderFillRect(renderer, &bullet_rect);
    }

    private static void draw_standard_bullet(SDL_Renderer* renderer, ref enemy_bullet bullet)
    {
        SDL_FRect bullet_rect = .() { x = bullet.x, y = bullet.y, w = bullet.size, h = bullet.size };

        switch (bullet.type)
        {
            case .SineWave:      draw_utils.set_color(renderer, colors.BLUE);
            case .SineWaveDNA:   draw_utils.set_color(renderer, colors.PURPLE);
            case .Fragmentation: draw_utils.set_color(renderer, colors.ORANGE);
            case .FragmentationSmall: draw_utils.set_color(renderer, colors.GOLD);
            default:             SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);
        }

        SDL_RenderFillRect(renderer, &bullet_rect);
    }
}
