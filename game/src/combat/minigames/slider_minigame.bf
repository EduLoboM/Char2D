using System;
using SDL3;

namespace game;

class slider_minigame : attack_minigame
{
    private float m_cursor = 0.0f;
    private float m_speed = 0.85f;

    private const float INITIAL_SPEED = 0.85f;
    private const float SWEET_SPOT_CENTER = 0.5f;
    private const float MAX_TIME = 3.0f;

    private const float TRACK_X = 220.0f;
    private const float TRACK_Y = 310.0f;
    private const float TRACK_W = 200.0f;
    private const float TRACK_H = 10.0f;

    private const float SWEET_SPOT_X = 310.0f;
    private const float SWEET_SPOT_Y = 308.0f;
    private const float SWEET_SPOT_W = 20.0f;
    private const float SWEET_SPOT_H = 14.0f;

    private const float CURSOR_Y = 304.0f;
    private const float CURSOR_W = 4.0f;
    private const float CURSOR_H = 22.0f;

    public override void initialize()
    {
        m_cursor = 0.0f;
        m_speed = INITIAL_SPEED;
    }

    public override void update(ref input_state input, float delta_time, my_game game)
    {
        m_timer += delta_time;

        m_cursor += m_speed * delta_time;
        if (m_cursor > 1.0f)
        {
            m_cursor = 1.0f;
            m_speed = -INITIAL_SPEED;
        }
        else if (m_cursor < 0.0f)
        {
            m_cursor = 0.0f;
            m_speed = INITIAL_SPEED;
        }

        if (input.space_just_pressed)
        {
            float dist = Math.Abs(m_cursor - SWEET_SPOT_CENTER);
            game.m_combat.resolve_attack(dist, game);
        }
        else if (m_timer >= MAX_TIME)
        {
            game.m_combat.resolve_attack(1.0f, game);
        }
    }

    public override void draw(SDL_Renderer* renderer, my_game game)
    {
        SDL_FRect track = .() { x = TRACK_X, y = TRACK_Y, w = TRACK_W, h = TRACK_H };
        SDL_SetRenderDrawColor(renderer, 40, 40, 50, 255);
        SDL_RenderFillRect(renderer, &track);
        SDL_SetRenderDrawColor(renderer, 80, 80, 90, 255);
        SDL_RenderRect(renderer, &track);

        SDL_FRect sweet_spot = .() { x = SWEET_SPOT_X, y = SWEET_SPOT_Y, w = SWEET_SPOT_W, h = SWEET_SPOT_H };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        draw_utils.set_color(renderer, colors.GREEN, 128);
        SDL_RenderFillRect(renderer, &sweet_spot);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);

        float cx = TRACK_X + m_cursor * TRACK_W;
        SDL_FRect cursor_rect = .() { x = cx - CURSOR_W / 2.0f, y = CURSOR_Y, w = CURSOR_W, h = CURSOR_H };
        draw_utils.set_color(renderer, colors.GOLD);
        SDL_RenderFillRect(renderer, &cursor_rect);
    }
}
