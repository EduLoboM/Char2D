using System;
using SDL3;

namespace game;

enum ArrowDirection
{
    Left = 0,
    Down = 1,
    Up = 2,
    Right = 3
}

struct falling_arrow
{
    public float y;
    public ArrowDirection direction;
    public bool active;
}

class arrow_minigame : attack_minigame
{
    private falling_arrow[6] m_arrows;
    private float m_speed = 120.0f;

    private int m_arrows_spawned = 0;
    private float m_total_dist = 0.0f;

    private const float TARGET_Y = 315.0f;
    private const float SPAWN_Y_START = 230.0f;
    private const float ARROW_SPACING_Y = 65.0f;
    private const float DESPAWN_Y = 335.0f;
    private const float COL_START_X = 240.0f;
    private const float COL_GAP_X = 40.0f;

    private const float DOTS_START_X = 275.0f;
    private const float DOTS_GAP_X = 15.0f;
    private const float DOTS_Y = 242.0f;

    public override void initialize()
    {
        m_timer = 0.0f;
        m_speed = 120.0f;
        m_arrows_spawned = 0;
        m_total_dist = 0.0f;

        for (int i = 0; i < 6; i++)
        {
            m_arrows[i] = .();
            m_arrows[i].y = SPAWN_Y_START - i * ARROW_SPACING_Y;
            m_arrows[i].direction = (ArrowDirection)(game_rand.next() % 4);
            m_arrows[i].active = true;
        }
    }

    private void draw_arrow(SDL_Renderer* renderer, float cx, float cy, ArrowDirection dir, bool solid, uint8 r, uint8 g, uint8 b)
    {
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        int start_offset = solid ? -1 : 0;
        int end_offset = solid ? 1 : 0;

        for (int offset = start_offset; offset <= end_offset; offset++)
        {
            switch (dir)
            {
                case .Left:
                    SDL_RenderLine(renderer, cx + 8, cy + offset, cx - 8, cy + offset);
                    SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy - 6 + offset);
                    SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy + 6 + offset);
                case .Down:
                    SDL_RenderLine(renderer, cx + offset, cy - 8, cx + offset, cy + 8);
                    SDL_RenderLine(renderer, cx, cy + 8, cx - 6 + offset, cy + 2);
                    SDL_RenderLine(renderer, cx, cy + 8, cx + 6 + offset, cy + 2);
                case .Up:
                    SDL_RenderLine(renderer, cx + offset, cy + 8, cx + offset, cy - 8);
                    SDL_RenderLine(renderer, cx, cy - 8, cx - 6 + offset, cy - 2);
                    SDL_RenderLine(renderer, cx, cy - 8, cx + 6 + offset, cy - 2);
                case .Right:
                    SDL_RenderLine(renderer, cx - 8, cy + offset, cx + 8, cy + offset);
                    SDL_RenderLine(renderer, cx + 8, cy, cx + 2, cy - 6 + offset);
                    SDL_RenderLine(renderer, cx + 8, cy, cx + 2, cy + 6 + offset);
            }
        }
    }

    public override void update(ref input_state input, float delta_time, my_game game)
    {
        m_timer += delta_time;

        for (int i = 0; i < 6; i++)
        {
            if (m_arrows[i].active)
            {
                m_arrows[i].y += m_speed * delta_time;
                if (m_arrows[i].y >= DESPAWN_Y)
                {
                    m_arrows[i].active = false;
                    m_total_dist += 1.0f;
                    m_arrows_spawned++;
                }
            }
        }

        if (m_arrows_spawned == 6)
        {
            game.m_combat.resolve_attack(m_total_dist / 6.0f, game);
            return;
        }

        ArrowDirection pressed_dir = .Left;
        bool has_pressed = false;
        if (input.left_just_pressed) { pressed_dir = .Left; has_pressed = true; }
        else if (input.down_just_pressed) { pressed_dir = .Down; has_pressed = true; }
        else if (input.up_just_pressed) { pressed_dir = .Up; has_pressed = true; }
        else if (input.right_just_pressed) { pressed_dir = .Right; has_pressed = true; }

        if (has_pressed)
        {
            int best_idx = -1;
            float best_diff = 9999.0f;
            for (int i = 0; i < 6; i++)
            {
                if (m_arrows[i].active && m_arrows[i].direction == pressed_dir && m_arrows[i].y >= SPAWN_Y_START)
                {
                    float diff = Math.Abs(m_arrows[i].y - TARGET_Y);
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
        for (int i = 0; i < 6; i++)
        {
            SDL_FRect dot = .() { x = DOTS_START_X + i * DOTS_GAP_X, y = DOTS_Y, w = 8, h = 8 };
            if (i < m_arrows_spawned)
            {
                draw_utils.set_color(renderer, colors.GOLD);
                SDL_RenderFillRect(renderer, &dot);
            }
            else
            {
                draw_utils.set_color(renderer, colors.PANEL_BORDER);
                SDL_RenderRect(renderer, &dot);
            }
        }

        draw_arrow(renderer, COL_START_X, TARGET_Y, .Left, false, 120, 120, 130);
        draw_arrow(renderer, COL_START_X + COL_GAP_X, TARGET_Y, .Down, false, 120, 120, 130);
        draw_arrow(renderer, COL_START_X + COL_GAP_X * 2, TARGET_Y, .Up, false, 120, 120, 130);
        draw_arrow(renderer, COL_START_X + COL_GAP_X * 3, TARGET_Y, .Right, false, 120, 120, 130);

        for (int i = 0; i < 6; i++)
        {
            if (m_arrows[i].active && m_arrows[i].y >= SPAWN_Y_START && m_arrows[i].y <= DESPAWN_Y)
            {
                float col_x = COL_START_X + (int)m_arrows[i].direction * COL_GAP_X;
                draw_arrow(renderer, col_x, m_arrows[i].y, m_arrows[i].direction, true, colors.GOLD[0], colors.GOLD[1], colors.GOLD[2]);
            }
        }
    }
}
