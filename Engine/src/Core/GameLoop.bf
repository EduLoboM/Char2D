namespace Engine.Core;

public interface i_game_loop
{
    void initialize();
    void update(float delta_time);
    void draw(float alpha);
    void cleanup();
}
