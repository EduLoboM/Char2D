using System;
using SDL3;

namespace game;

class tap_minigame : attack_minigame
{
    private float m_fill = 0.0f;
    private const float TAP_INCREMENT = 0.12f;
    private const float MAX_TIME = 2.0f;

    private const float TIME_BAR_X = 220.0f;
    private const float TIME_BAR_Y = 300.0f;
    private const float TIME_BAR_MAX_W = 200.0f;
    private const float TIME_BAR_H = 4.0f;

    private const float TRACK_X = 220.0f;
    private const float TRACK_Y = 315.0f;
    private const float TRACK_W = 200.0f;
    private const float TRACK_H = 12.0f;

    private const float TARGET_LINE_X = 420.0f;
    private const float TARGET_LINE_Y = 313.0f;
    private const float TARGET_LINE_W = 2.0f;
    private const float TARGET_LINE_H = 16.0f;

    public override void initialize()
    {
        m_timer = 0.0f;
        m_fill = 0.0f;
    }

    public override void update(ref input_state input, float delta_time, my_game game)
    {
        m_timer += delta_time;

        if (input.space_just_pressed)
        {
            m_fill += TAP_INCREMENT;
            if (m_fill >= 1.0f)
            {
                m_fill = 1.0f;
                game.m_combat.resolve_attack(0.0f, game);
                return;
            }
        }

        if (m_timer >= MAX_TIME)
        {
            float dist = 1.0f - m_fill;
            if (dist < 0.0f) dist = 0.0f;
            game.m_combat.resolve_attack(dist, game);
        }
    }

    public override void draw(SDL_Renderer* renderer, my_game game)
    {
        float timer_ratio = (MAX_TIME - m_timer) / MAX_TIME;
        if (timer_ratio < 0.0f) timer_ratio = 0.0f;
        SDL_FRect time_bar = .() { x = TIME_BAR_X, y = TIME_BAR_Y, w = timer_ratio * TIME_BAR_MAX_W, h = TIME_BAR_H };
        draw_utils.set_color(renderer, colors.RED);
        SDL_RenderFillRect(renderer, &time_bar);

        SDL_FRect track = .() { x = TRACK_X, y = TRACK_Y, w = TRACK_W, h = TRACK_H };
        SDL_SetRenderDrawColor(renderer, 40, 40, 50, 255);
        SDL_RenderFillRect(renderer, &track);

        float fill_ratio = m_fill;
        if (fill_ratio > 1.0f) fill_ratio = 1.0f;
        SDL_FRect fill_bar = .() { x = TRACK_X, y = TRACK_Y, w = fill_ratio * TRACK_W, h = TRACK_H };
        draw_utils.set_color(renderer, colors.GREEN);
        SDL_RenderFillRect(renderer, &fill_bar);
        SDL_SetRenderDrawColor(renderer, 80, 80, 95, 255);
        SDL_RenderRect(renderer, &track);

        SDL_FRect target_line = .() { x = TARGET_LINE_X, y = TARGET_LINE_Y, w = TARGET_LINE_W, h = TARGET_LINE_H };
        draw_utils.set_color(renderer, colors.GOLD);
        SDL_RenderFillRect(renderer, &target_line);
    }
}
