using SDL3;

namespace Engine.Core;

public interface i_game_loop
{
    void initialize();
    void update(float delta_time);
    void draw(SDL_Renderer* renderer, float alpha);
    void cleanup();
}
