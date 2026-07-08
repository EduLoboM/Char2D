using System;
using SDL3;

namespace game;

abstract class attack_minigame
{
    public float m_timer = 0.0f;

    public abstract void initialize();
    public abstract void update(bool space_pressed, bool* keys, float delta_time, my_game game);
    public abstract void draw(SDL_Renderer* renderer, my_game game);
}

class slider_minigame : attack_minigame
{
    private float m_cursor = 0.0f;
    private float m_speed = 0.85f;

    public override void initialize()
    {
        m_cursor = 0.0f;
        m_speed = 0.85f;
    }

    public override void update(bool space_pressed, bool* keys, float delta_time, my_game game)
    {
        m_timer += delta_time;

        m_cursor += m_speed * delta_time;
        if (m_cursor > 1.0f)
        {
            m_cursor = 1.0f;
            m_speed = -0.85f;
        }
        else if (m_cursor < 0.0f)
        {
            m_cursor = 0.0f;
            m_speed = 0.85f;
        }

        if (space_pressed && !game.prev_space)
        {
            float dist = Math.Abs(m_cursor - 0.5f);
            game.resolve_attack(dist);
        }
        else if (m_timer >= 3.0f)
        {
            game.resolve_attack(1.0f);
        }
    }

    public override void draw(SDL_Renderer* renderer, my_game game)
    {
        SDL_FRect track = .() { x = 220, y = 310, w = 200, h = 10 };
        SDL_SetRenderDrawColor(renderer, 40, 40, 50, 255);
        SDL_RenderFillRect(renderer, &track);
        SDL_SetRenderDrawColor(renderer, 80, 80, 90, 255);
        SDL_RenderRect(renderer, &track);

        SDL_FRect sweet_spot = .() { x = 310, y = 308, w = 20, h = 14 };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, 46, 204, 113, 128);
        SDL_RenderFillRect(renderer, &sweet_spot);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);

        float cx = 220.0f + m_cursor * 200.0f;
        SDL_FRect cursor_rect = .() { x = cx - 2, y = 304, w = 4, h = 22 };
        SDL_SetRenderDrawColor(renderer, 241, 196, 15, 255);
        SDL_RenderFillRect(renderer, &cursor_rect);
    }
}

class tap_minigame : attack_minigame
{
    private float m_fill = 0.0f;

    public override void initialize()
    {
        m_timer = 0.0f;
        m_fill = 0.0f;
    }

    public override void update(bool space_pressed, bool* keys, float delta_time, my_game game)
    {
        m_timer += delta_time;

        if (space_pressed && !game.prev_space)
        {
            m_fill += 0.12f;
            if (m_fill >= 1.0f)
            {
                m_fill = 1.0f;
                game.resolve_attack(0.0f);
                return;
            }
        }

        if (m_timer >= 2.0f)
        {
            float dist = 1.0f - m_fill;
            if (dist < 0.0f) dist = 0.0f;
            game.resolve_attack(dist);
        }
    }

    public override void draw(SDL_Renderer* renderer, my_game game)
    {
        float timer_ratio = (2.0f - m_timer) / 2.0f;
        if (timer_ratio < 0.0f) timer_ratio = 0.0f;
        SDL_FRect time_bar = .() { x = 220, y = 300, w = timer_ratio * 200.0f, h = 4 };
        SDL_SetRenderDrawColor(renderer, 231, 76, 60, 255);
        SDL_RenderFillRect(renderer, &time_bar);

        SDL_FRect track = .() { x = 220, y = 315, w = 200, h = 12 };
        SDL_SetRenderDrawColor(renderer, 40, 40, 50, 255);
        SDL_RenderFillRect(renderer, &track);

        float fill_ratio = m_fill;
        if (fill_ratio > 1.0f) fill_ratio = 1.0f;
        SDL_FRect fill_bar = .() { x = 220, y = 315, w = fill_ratio * 200.0f, h = 12 };
        SDL_SetRenderDrawColor(renderer, 46, 204, 113, 255);
        SDL_RenderFillRect(renderer, &fill_bar);
        SDL_SetRenderDrawColor(renderer, 80, 80, 95, 255);
        SDL_RenderRect(renderer, &track);

        SDL_FRect target_line = .() { x = 420, y = 313, w = 2, h = 16 };
        SDL_SetRenderDrawColor(renderer, 241, 196, 15, 255);
        SDL_RenderFillRect(renderer, &target_line);
    }
}

struct falling_arrow
{
    public float y;
    public int col;
    public bool active;
}

class arrow_minigame : attack_minigame
{
    private falling_arrow[6] m_arrows;
    private float m_speed = 120.0f;

    private int m_arrows_spawned = 0;
    private float m_total_dist = 0.0f;

    private bool m_prev_up = false;
    private bool m_prev_down = false;
    private bool m_prev_left = false;
    private bool m_prev_right = false;

    public override void initialize()
    {
        m_timer = 0.0f;
        m_speed = 120.0f;
        m_arrows_spawned = 0;
        m_total_dist = 0.0f;

        for (int i = 0; i < 6; i++)
        {
            m_arrows[i] = .();
            m_arrows[i].y = 230.0f - i * 65.0f;
            m_arrows[i].col = (int)(game_rand.next() % 4);
            m_arrows[i].active = true;
        }

        m_prev_up = true;
        m_prev_down = true;
        m_prev_left = true;
        m_prev_right = true;
    }

    private void draw_arrow(SDL_Renderer* renderer, float cx, float cy, int dir, bool solid, uint8 r, uint8 g, uint8 b)
    {
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        if (solid)
        {
            for (int offset = -1; offset <= 1; offset++)
            {
                switch (dir)
                {
                    case 0:
                        SDL_RenderLine(renderer, cx + 8, cy + offset, cx - 8, cy + offset);
                        SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy - 6 + offset);
                        SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy + 6 + offset);
                        break;
                    case 1:
                        SDL_RenderLine(renderer, cx + offset, cy - 8, cx + offset, cy + 8);
                        SDL_RenderLine(renderer, cx, cy + 8, cx - 6 + offset, cy + 2);
                        SDL_RenderLine(renderer, cx, cy + 8, cx + 6 + offset, cy + 2);
                        break;
                    case 2:
                        SDL_RenderLine(renderer, cx + offset, cy + 8, cx + offset, cy - 8);
                        SDL_RenderLine(renderer, cx, cy - 8, cx - 6 + offset, cy - 2);
                        SDL_RenderLine(renderer, cx, cy - 8, cx + 6 + offset, cy - 2);
                        break;
                    case 3:
                        SDL_RenderLine(renderer, cx - 8, cy + offset, cx + 8, cy + offset);
                        SDL_RenderLine(renderer, cx + 8, cy, cx + 2, cy - 6 + offset);
                        SDL_RenderLine(renderer, cx + 8, cy, cx + 2, cy + 6 + offset);
                        break;
                }
            }
        }
        else
        {
            switch (dir)
            {
                case 0:
                    SDL_RenderLine(renderer, cx + 8, cy, cx - 8, cy);
                    SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy - 6);
                    SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy + 6);
                    break;
                case 1:
                    SDL_RenderLine(renderer, cx, cy - 8, cx, cy + 8);
                    SDL_RenderLine(renderer, cx, cy + 8, cx - 6, cy + 2);
                    SDL_RenderLine(renderer, cx, cy + 8, cx + 6, cy + 2);
                    break;
                case 2:
                    SDL_RenderLine(renderer, cx, cy + 8, cx, cy - 8);
                    SDL_RenderLine(renderer, cx, cy - 8, cx - 6, cy - 2);
                    SDL_RenderLine(renderer, cx, cy - 8, cx + 6, cy - 2);
                    break;
                case 3:
                    SDL_RenderLine(renderer, cx - 8, cy, cx + 8, cy);
                    SDL_RenderLine(renderer, cx + 8, cy, cx + 2, cy - 6);
                    SDL_RenderLine(renderer, cx + 8, cy, cx + 2, cy + 6);
                    break;
            }
        }
    }

    public override void update(bool space_pressed, bool* keys, float delta_time, my_game game)
    {
        m_timer += delta_time;

        for (int i = 0; i < 6; i++)
        {
            if (m_arrows[i].active)
            {
                m_arrows[i].y += m_speed * delta_time;
                if (m_arrows[i].y >= 335.0f)
                {
                    m_arrows[i].active = false;
                    m_total_dist += 1.0f;
                    m_arrows_spawned++;
                }
            }
        }

        if (m_arrows_spawned == 6)
        {
            game.resolve_attack(m_total_dist / 6.0f);
            return;
        }

        bool up_held = keys[(int32)SDL_Scancode.SDL_SCANCODE_UP] || keys[(int32)SDL_Scancode.SDL_SCANCODE_W];
        bool down_held = keys[(int32)SDL_Scancode.SDL_SCANCODE_DOWN] || keys[(int32)SDL_Scancode.SDL_SCANCODE_S];
        bool left_held = keys[(int32)SDL_Scancode.SDL_SCANCODE_LEFT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_A];
        bool right_held = keys[(int32)SDL_Scancode.SDL_SCANCODE_RIGHT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_D];

        bool up_pressed = up_held && !m_prev_up;
        bool down_pressed = down_held && !m_prev_down;
        bool left_pressed = left_held && !m_prev_left;
        bool right_pressed = right_held && !m_prev_right;

        m_prev_up = up_held;
        m_prev_down = down_held;
        m_prev_left = left_held;
        m_prev_right = right_held;

        int pressed_col = -1;
        if (left_pressed) pressed_col = 0;
        else if (down_pressed) pressed_col = 1;
        else if (up_pressed) pressed_col = 2;
        else if (right_pressed) pressed_col = 3;

        if (pressed_col != -1)
        {
            int best_idx = -1;
            float best_diff = 9999.0f;
            for (int i = 0; i < 6; i++)
            {
                if (m_arrows[i].active && m_arrows[i].col == pressed_col && m_arrows[i].y >= 230.0f)
                {
                    float diff = Math.Abs(m_arrows[i].y - 315.0f);
                    if (diff < best_diff)
                    {
                        best_diff = diff;
                        best_idx = i;
                    }
                }
            }

            if (best_idx != -1 && best_diff < 40.0f)
            {
                m_arrows[best_idx].active = false;
                float dist = best_diff / 100.0f;
                m_total_dist += dist;
                m_arrows_spawned++;
            }
        }
    }

    public override void draw(SDL_Renderer* renderer, my_game game)
    {
        float target_y = 315.0f;

        for (int i = 0; i < 6; i++)
        {
            SDL_FRect dot = .() { x = 275.0f + i * 15.0f, y = 242.0f, w = 8, h = 8 };
            if (i < m_arrows_spawned)
            {
                SDL_SetRenderDrawColor(renderer, 241, 196, 15, 255);
                SDL_RenderFillRect(renderer, &dot);
            }
            else
            {
                SDL_SetRenderDrawColor(renderer, 70, 70, 80, 255);
                SDL_RenderRect(renderer, &dot);
            }
        }

        draw_arrow(renderer, 240, target_y, 0, false, 120, 120, 130);
        draw_arrow(renderer, 280, target_y, 1, false, 120, 120, 130);
        draw_arrow(renderer, 320, target_y, 2, false, 120, 120, 130);
        draw_arrow(renderer, 360, target_y, 3, false, 120, 120, 130);

        for (int i = 0; i < 6; i++)
        {
            if (m_arrows[i].active && m_arrows[i].y >= 230.0f && m_arrows[i].y <= 335.0f)
            {
                float col_x = 240.0f + m_arrows[i].col * 40.0f;
                draw_arrow(renderer, col_x, m_arrows[i].y, m_arrows[i].col, true, 241, 196, 15);
            }
        }
    }
}

class charge_minigame : attack_minigame
{
    private float m_charge = 0.0f;
    private bool m_is_charging = false;
    private bool m_started = false;

    public override void initialize()
    {
        m_timer = 0.0f;
        m_charge = 0.0f;
        m_is_charging = false;
        m_started = false;
    }

    public override void update(bool space_pressed, bool* keys, float delta_time, my_game game)
    {
        m_timer += delta_time;

        bool space_held = keys[(int32)SDL_Scancode.SDL_SCANCODE_SPACE];

        if (!m_started)
        {
            if (space_pressed && !game.prev_space)
            {
                m_started = true;
                m_is_charging = true;
                m_charge = 0.0f;
            }
            
            if (m_timer >= 3.0f)
            {
                game.resolve_attack(1.0f);
            }
        }
        else
        {
            if (space_held)
            {
                m_charge += delta_time * 0.65f;
                
                if (m_charge > 1.0f)
                {
                    game.resolve_attack(1.0f);
                    return;
                }
            }
            else
            {
                if (m_is_charging)
                {
                    float dist = Math.Abs(m_charge - 0.80f);
                    game.resolve_attack(dist);
                }
            }
        }
    }

    public override void draw(SDL_Renderer* renderer, my_game game)
    {
        SDL_FRect track = .() { x = 220, y = 310, w = 200, h = 12 };
        SDL_SetRenderDrawColor(renderer, 40, 40, 50, 255);
        SDL_RenderFillRect(renderer, &track);

        SDL_FRect sweet_spot = .() { x = 220 + 150, y = 308, w = 20, h = 16 };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, 46, 204, 113, 128);
        SDL_RenderFillRect(renderer, &sweet_spot);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);

        float fill_w = m_charge * 200.0f;
        SDL_FRect fill_bar = .() { x = 220, y = 310, w = fill_w, h = 12 };
        SDL_SetRenderDrawColor(renderer, 241, 196, 15, 255);
        SDL_RenderFillRect(renderer, &fill_bar);

        SDL_SetRenderDrawColor(renderer, 80, 80, 95, 255);
        SDL_RenderRect(renderer, &track);
    }
}
