using System;
using SDL3;

namespace game;

struct input_state
{
    private bool m_up;
    private bool m_down;
    private bool m_left;
    private bool m_right;
    private bool m_space;
    private bool m_return;

    private bool m_prev_up;
    private bool m_prev_down;
    private bool m_prev_left;
    private bool m_prev_right;
    private bool m_prev_space;
    private bool m_prev_return;

    public bool up => m_up;
    public bool down => m_down;
    public bool left => m_left;
    public bool right => m_right;
    public bool space => m_space;
    public bool return_key => m_return;

    public bool prev_space => m_prev_space;

    public bool up_just_pressed => m_up && !m_prev_up;
    public bool down_just_pressed => m_down && !m_prev_down;
    public bool left_just_pressed => m_left && !m_prev_left;
    public bool right_just_pressed => m_right && !m_prev_right;
    public bool space_just_pressed => m_space && !m_prev_space;
    public bool return_just_pressed => m_return && !m_prev_return;

    public void update(bool* keys) mut
    {
        m_prev_up = m_up;
        m_prev_down = m_down;
        m_prev_left = m_left;
        m_prev_right = m_right;
        m_prev_space = m_space;
        m_prev_return = m_return;

        m_up = keys[(int32)SDL_Scancode.SDL_SCANCODE_UP] || keys[(int32)SDL_Scancode.SDL_SCANCODE_W];
        m_down = keys[(int32)SDL_Scancode.SDL_SCANCODE_DOWN] || keys[(int32)SDL_Scancode.SDL_SCANCODE_S];
        m_left = keys[(int32)SDL_Scancode.SDL_SCANCODE_LEFT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_A];
        m_right = keys[(int32)SDL_Scancode.SDL_SCANCODE_RIGHT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_D];
        m_space = keys[(int32)SDL_Scancode.SDL_SCANCODE_SPACE];
        m_return = keys[(int32)SDL_Scancode.SDL_SCANCODE_RETURN];
    }
}
