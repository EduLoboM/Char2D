using System;
using SDL3;

namespace game;

class charge_minigame : attack_minigame
{
    private float m_charge = 0.0f;
    private bool m_is_charging = false;
    private bool m_started = false;

    private const float CHARGE_SPEED = 0.65f;
    private const float TARGET_CHARGE = 0.80f;
    private const float MAX_TIME = 3.0f;

    private const float TRACK_X = 220.0f;
    private const float TRACK_Y = 310.0f;
    private const float TRACK_W = 200.0f;
    private const float TRACK_H = 12.0f;

    private const float SWEET_SPOT_OFFSET_X = 150.0f;
    private const float SWEET_SPOT_Y = 308.0f;
    private const float SWEET_SPOT_W = 20.0f;
    private const float SWEET_SPOT_H = 16.0f;

    public override void initialize()
    {
        m_timer = 0.0f;
        m_charge = 0.0f;
        m_is_charging = false;
        m_started = false;
    }

    public override void update(ref input_state input, float delta_time, my_game game)
    {
        m_timer += delta_time;

        if (!m_started)
        {
            if (input.space_just_pressed)
            {
                m_started = true;
                m_is_charging = true;
                m_charge = 0.0f;
            }

            if (m_timer >= MAX_TIME)
            {
                game.m_combat.resolve_attack(1.0f, game);
            }
        }
        else
        {
            if (input.space)
            {
                m_charge += delta_time * CHARGE_SPEED;

                if (m_charge > 1.0f)
                {
                    game.m_combat.resolve_attack(1.0f, game);
                    return;
                }
            }
            else
            {
                if (m_is_charging)
                {
                    float dist = Math.Abs(m_charge - TARGET_CHARGE);
                    game.m_combat.resolve_attack(dist, game);
                }
            }
        }
    }

    public override void draw(SDL_Renderer* renderer, my_game game)
    {
        SDL_FRect track = .() { x = TRACK_X, y = TRACK_Y, w = TRACK_W, h = TRACK_H };
        SDL_SetRenderDrawColor(renderer, 40, 40, 50, 255);
        SDL_RenderFillRect(renderer, &track);

        SDL_FRect sweet_spot = .() { x = TRACK_X + SWEET_SPOT_OFFSET_X, y = SWEET_SPOT_Y, w = SWEET_SPOT_W, h = SWEET_SPOT_H };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        draw_utils.set_color(renderer, colors.GREEN, 128);
        SDL_RenderFillRect(renderer, &sweet_spot);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);

        float fill_w = m_charge * TRACK_W;
        SDL_FRect fill_bar = .() { x = TRACK_X, y = TRACK_Y, w = fill_w, h = TRACK_H };
        draw_utils.set_color(renderer, colors.GOLD);
        SDL_RenderFillRect(renderer, &fill_bar);

        SDL_SetRenderDrawColor(renderer, 80, 80, 95, 255);
        SDL_RenderRect(renderer, &track);
    }
}
