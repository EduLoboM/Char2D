using System;

namespace game;

class player_soul
{
    public float x;
    public float y;
    public float size = 12.0f;
    public float speed = 75.0f;
    public float resistance = 1.0f;

    public float center_x => x + size / 2.0f;
    public float center_y => y + size / 2.0f;

    public void update_movement(ref input_state input, float delta_time, arena bounds)
    {
        if (input.up) y -= speed * delta_time;
        if (input.down) y += speed * delta_time;
        if (input.left) x -= speed * delta_time;
        if (input.right) x += speed * delta_time;

        bounds.constrain_soul(this);
    }

    public void reset_position(arena bounds)
    {
        x = bounds.center_x - (size / 2.0f);
        y = bounds.center_y - (size / 2.0f);
    }
}
