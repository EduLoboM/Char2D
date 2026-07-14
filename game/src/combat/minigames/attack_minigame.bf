using System;
using SDL3;

namespace game;

abstract class attack_minigame
{
    public float m_timer = 0.0f;

    public abstract void initialize();
    public abstract void update(ref input_state input, float delta_time, my_game game);
    public abstract void draw(SDL_Renderer* renderer, my_game game);
}
