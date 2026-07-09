using System;
using SDL3;

namespace game;

enum CardSuit
{
    Hearts = 0,
    Diamonds = 1,
    Clubs = 2,
    Spades = 3
}

enum RideTheBusStage
{
    RedOrBlack = 0,
    HigherOrLower = 1,
    InOrOut = 2,
    GuessSuit = 3,
    Win = 4,
    Fail = 5
}

enum ArrowDirection
{
    Left = 0,
    Down = 1,
    Up = 2,
    Right = 3
}

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

    private const float INITIAL_SPEED = 0.85f;
    private const float SWEET_SPOT_CENTER = 0.5f;
    private const float MAX_TIME = 3.0f;

    public override void initialize()
    {
        m_cursor = 0.0f;
        m_speed = INITIAL_SPEED;
    }

    public override void update(bool space_pressed, bool* keys, float delta_time, my_game game)
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

        if (space_pressed && !game.prev_space)
        {
            float dist = Math.Abs(m_cursor - SWEET_SPOT_CENTER);
            game.resolve_attack(dist);
        }
        else if (m_timer >= MAX_TIME)
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
    private const float TAP_INCREMENT = 0.12f;
    private const float MAX_TIME = 2.0f;

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
            m_fill += TAP_INCREMENT;
            if (m_fill >= 1.0f)
            {
                m_fill = 1.0f;
                game.resolve_attack(0.0f);
                return;
            }
        }

        if (m_timer >= MAX_TIME)
        {
            float dist = 1.0f - m_fill;
            if (dist < 0.0f) dist = 0.0f;
            game.resolve_attack(dist);
        }
    }

    public override void draw(SDL_Renderer* renderer, my_game game)
    {
        float timer_ratio = (MAX_TIME - m_timer) / MAX_TIME;
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
    public ArrowDirection direction;
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
            m_arrows[i].direction = (ArrowDirection)(game_rand.next() % 4);
            m_arrows[i].active = true;
        }

        m_prev_up = true;
        m_prev_down = true;
        m_prev_left = true;
        m_prev_right = true;
    }

    private void draw_arrow(SDL_Renderer* renderer, float cx, float cy, ArrowDirection dir, bool solid, uint8 r, uint8 g, uint8 b)
    {
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        if (solid)
        {
            for (int offset = -1; offset <= 1; offset++)
            {
                switch (dir)
                {
                    case .Left:
                        SDL_RenderLine(renderer, cx + 8, cy + offset, cx - 8, cy + offset);
                        SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy - 6 + offset);
                        SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy + 6 + offset);
                        break;
                    case .Down:
                        SDL_RenderLine(renderer, cx + offset, cy - 8, cx + offset, cy + 8);
                        SDL_RenderLine(renderer, cx, cy + 8, cx - 6 + offset, cy + 2);
                        SDL_RenderLine(renderer, cx, cy + 8, cx + 6 + offset, cy + 2);
                        break;
                    case .Up:
                        SDL_RenderLine(renderer, cx + offset, cy + 8, cx + offset, cy - 8);
                        SDL_RenderLine(renderer, cx, cy - 8, cx - 6 + offset, cy - 2);
                        SDL_RenderLine(renderer, cx, cy - 8, cx + 6 + offset, cy - 2);
                        break;
                    case .Right:
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
                case .Left:
                    SDL_RenderLine(renderer, cx + 8, cy, cx - 8, cy);
                    SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy - 6);
                    SDL_RenderLine(renderer, cx - 8, cy, cx - 2, cy + 6);
                    break;
                case .Down:
                    SDL_RenderLine(renderer, cx, cy - 8, cx, cy + 8);
                    SDL_RenderLine(renderer, cx, cy + 8, cx - 6, cy + 2);
                    SDL_RenderLine(renderer, cx, cy + 8, cx + 6, cy + 2);
                    break;
                case .Up:
                    SDL_RenderLine(renderer, cx, cy + 8, cx, cy - 8);
                    SDL_RenderLine(renderer, cx, cy - 8, cx - 6, cy - 2);
                    SDL_RenderLine(renderer, cx, cy - 8, cx + 6, cy - 2);
                    break;
                case .Right:
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

        ArrowDirection pressed_dir = .Left;
        bool has_pressed = false;
        if (left_pressed) { pressed_dir = .Left; has_pressed = true; }
        else if (down_pressed) { pressed_dir = .Down; has_pressed = true; }
        else if (up_pressed) { pressed_dir = .Up; has_pressed = true; }
        else if (right_pressed) { pressed_dir = .Right; has_pressed = true; }

        if (has_pressed)
        {
            int best_idx = -1;
            float best_diff = 9999.0f;
            for (int i = 0; i < 6; i++)
            {
                if (m_arrows[i].active && m_arrows[i].direction == pressed_dir && m_arrows[i].y >= 230.0f)
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

        draw_arrow(renderer, 240, target_y, .Left, false, 120, 120, 130);
        draw_arrow(renderer, 280, target_y, .Down, false, 120, 120, 130);
        draw_arrow(renderer, 320, target_y, .Up, false, 120, 120, 130);
        draw_arrow(renderer, 360, target_y, .Right, false, 120, 120, 130);

        for (int i = 0; i < 6; i++)
        {
            if (m_arrows[i].active && m_arrows[i].y >= 230.0f && m_arrows[i].y <= 335.0f)
            {
                float col_x = 240.0f + (int)m_arrows[i].direction * 40.0f;
                draw_arrow(renderer, col_x, m_arrows[i].y, m_arrows[i].direction, true, 241, 196, 15);
            }
        }
    }
}

class charge_minigame : attack_minigame
{
    private float m_charge = 0.0f;
    private bool m_is_charging = false;
    private bool m_started = false;

    private const float CHARGE_SPEED = 0.65f;
    private const float TARGET_CHARGE = 0.80f;
    private const float MAX_TIME = 3.0f;

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
            
            if (m_timer >= MAX_TIME)
            {
                game.resolve_attack(1.0f);
            }
        }
        else
        {
            if (space_held)
            {
                m_charge += delta_time * CHARGE_SPEED;
                
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
                    float dist = Math.Abs(m_charge - TARGET_CHARGE);
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

class ride_the_bus_minigame : attack_minigame
{
    public struct card
    {
        public int value; // 2..14
        public CardSuit suit;
        
        public bool is_red() => suit == .Hearts || suit == .Diamonds;
        
        public char8 suit_logo_char()
        {
            switch (suit)
            {
                case .Hearts: return 'h'; // Hearts (♥)
                case .Diamonds: return 'd'; // Diamonds (♦)
                case .Clubs: return 'c'; // Clubs (♣)
                case .Spades: return 's'; // Spades (♠)
            }
        }
        
        public char8 value_char()
        {
            switch (value)
            {
                case 14: return 'A';
                case 13: return 'K';
                case 12: return 'Q';
                case 11: return 'J';
                case 10: return 'T';
                default: return (char8)('0' + value);
            }
        }
    }

    // Constants for positioning and sizing
    private const float CARD_WIDTH = 40.0f;
    private const float CARD_HEIGHT = 55.0f;
    private const float CARD_GAP = 12.0f;
    private const float PANEL_CENTER_X = 320.0f;
    private const float CARDS_Y = 268.0f;
    private const float PIP_SIZE = 6.0f;
    private const float PIP_GAP = 6.0f;
    private const float PIP_Y = 235.0f;

    private card[4] m_cards;
    private bool[4] m_revealed;
    private RideTheBusStage m_stage = .RedOrBlack;
    private float m_transition_timer = 0.0f;
    private bool m_resolved = false;
    private String m_message = new .() ~ delete _;

    private bool m_prev_left = false;
    private bool m_prev_right = false;
    private bool m_prev_up = false;
    private bool m_prev_down = false;

    private int m_correct_guesses = 0;

    public override void initialize()
    {
        m_timer = 0.0f;
        m_stage = .RedOrBlack;
        m_transition_timer = 0.0f;
        m_resolved = false;
        m_message.Set("");
        m_correct_guesses = 0;

        // Card 0
        m_cards[0].value = (int)(game_rand.next() % 13) + 2;
        m_cards[0].suit = (CardSuit)(game_rand.next() % 4);

        // Card 1: must differ from Card 0 by at least 2 for gameplay fairness
        while (true)
        {
            m_cards[1].value = (int)(game_rand.next() % 13) + 2;
            if (Math.Abs(m_cards[1].value - m_cards[0].value) >= 2)
                break;
        }
        m_cards[1].suit = (CardSuit)(game_rand.next() % 4);

        // Card 2
        m_cards[2].value = (int)(game_rand.next() % 13) + 2;
        m_cards[2].suit = (CardSuit)(game_rand.next() % 4);

        // Card 3
        m_cards[3].value = (int)(game_rand.next() % 13) + 2;
        m_cards[3].suit = (CardSuit)(game_rand.next() % 4);

        m_revealed[0] = false;
        m_revealed[1] = false;
        m_revealed[2] = false;
        m_revealed[3] = false;

        m_prev_left = true;
        m_prev_right = true;
        m_prev_up = true;
        m_prev_down = true;
    }

    public override void update(bool space_pressed, bool* keys, float delta_time, my_game game)
    {
        m_timer += delta_time;

        if (m_resolved)
        {
            update_resolution(delta_time, game);
            return;
        }

        if (m_transition_timer > 0.0f)
        {
            update_transition(delta_time);
            return;
        }

        bool left_held = keys[(int32)SDL_Scancode.SDL_SCANCODE_LEFT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_A];
        bool right_held = keys[(int32)SDL_Scancode.SDL_SCANCODE_RIGHT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_D];
        bool up_held = keys[(int32)SDL_Scancode.SDL_SCANCODE_UP] || keys[(int32)SDL_Scancode.SDL_SCANCODE_W];
        bool down_held = keys[(int32)SDL_Scancode.SDL_SCANCODE_DOWN] || keys[(int32)SDL_Scancode.SDL_SCANCODE_S];

        bool left_pressed = left_held && !m_prev_left;
        bool right_pressed = right_held && !m_prev_right;
        bool up_pressed = up_held && !m_prev_up;
        bool down_pressed = down_held && !m_prev_down;

        m_prev_left = left_held;
        m_prev_right = right_held;
        m_prev_up = up_held;
        m_prev_down = down_held;

        switch (m_stage)
        {
            case .RedOrBlack:
                update_stage_red_black(left_pressed, right_pressed);
                break;
            case .HigherOrLower:
                update_stage_higher_lower(up_pressed, down_pressed);
                break;
            case .InOrOut:
                update_stage_in_out(left_pressed, right_pressed);
                break;
            case .GuessSuit:
                update_stage_guess_suit(left_pressed, right_pressed, up_pressed, down_pressed);
                break;
            default:
                break;
        }
    }

    private void update_resolution(float delta_time, my_game game)
    {
        m_transition_timer -= delta_time;
        if (m_transition_timer <= 0.0f)
        {
            if (m_stage == .Win)
            {
                game.resolve_attack(0.0f);
            }
            else if (m_stage == .Fail)
            {
                float score = 1.0f;
                if (m_correct_guesses == 1) score = 0.55f;
                else if (m_correct_guesses == 2) score = 0.4f;
                else if (m_correct_guesses == 3) score = 0.15f;
                
                game.resolve_attack(score);
            }
        }
    }

    private void update_transition(float delta_time)
    {
        m_transition_timer -= delta_time;
        if (m_transition_timer <= 0.0f)
        {
            m_stage = (RideTheBusStage)((int)m_stage + 1);
        }
    }

    private void advance_stage(int card_index, int correct_guesses)
    {
        m_revealed[card_index] = true;
        m_correct_guesses = correct_guesses;
        m_transition_timer = 0.8f;
    }

    private void fail_minigame(int card_index)
    {
        m_revealed[card_index] = true;
        m_message.Set("WRONG!");
        m_transition_timer = 1.0f;
        m_resolved = true;
        m_stage = .Fail;
    }

    private void win_minigame(int card_index, int correct_guesses)
    {
        m_revealed[card_index] = true;
        m_correct_guesses = correct_guesses;
        m_message.Set("PERFECT!");
        m_transition_timer = 1.0f;
        m_resolved = true;
        m_stage = .Win;
    }

    private void update_stage_red_black(bool left_pressed, bool right_pressed)
    {
        if (left_pressed || right_pressed)
        {
            bool guessed_red = left_pressed;
            if (guessed_red == m_cards[0].is_red())
            {
                advance_stage(0, 1);
            }
            else
            {
                fail_minigame(0);
            }
        }
    }

    private void update_stage_higher_lower(bool up_pressed, bool down_pressed)
    {
        if (up_pressed || down_pressed)
        {
            bool guessed_higher = up_pressed;
            bool is_higher = m_cards[1].value > m_cards[0].value;
            if (guessed_higher == is_higher)
            {
                advance_stage(1, 2);
            }
            else
            {
                fail_minigame(1);
            }
        }
    }

    private void update_stage_in_out(bool left_pressed, bool right_pressed)
    {
        if (left_pressed || right_pressed)
        {
            bool guessed_in = left_pressed;
            int min_v = Math.Min(m_cards[0].value, m_cards[1].value);
            int max_v = Math.Max(m_cards[0].value, m_cards[1].value);
            bool is_in = m_cards[2].value > min_v && m_cards[2].value < max_v;
            if (guessed_in == is_in)
            {
                advance_stage(2, 3);
            }
            else
            {
                fail_minigame(2);
            }
        }
    }

    private void update_stage_guess_suit(bool left_pressed, bool right_pressed, bool up_pressed, bool down_pressed)
    {
        if (left_pressed || right_pressed || up_pressed || down_pressed)
        {
            CardSuit guessed_suit = .Hearts;
            if (left_pressed) guessed_suit = .Hearts;
            else if (up_pressed) guessed_suit = .Diamonds;
            else if (down_pressed) guessed_suit = .Clubs;
            else if (right_pressed) guessed_suit = .Spades;

            if (guessed_suit == m_cards[3].suit)
            {
                win_minigame(3, 4);
            }
            else
            {
                fail_minigame(3);
            }
        }
    }

    private void draw_suit_icon_7x7(SDL_Renderer* renderer, float cx, float cy, CardSuit suit, float scale, uint8 r, uint8 g, uint8 b)
    {
        uint8[7] rows = .();
        switch (suit)
        {
            case .Hearts:
                rows = .(0b0100010, 0b1110111, 0b1111111, 0b1111111, 0b0111110, 0b0011100, 0b0001000);
                break;
            case .Diamonds:
                rows = .(0b0001000, 0b0011100, 0b0111110, 0b1111111, 0b0111110, 0b0011100, 0b0001000);
                break;
            case .Clubs:
                rows = .(0b0011100, 0b0111110, 0b1111111, 0b1111111, 0b1111111, 0b0001000, 0b0011100);
                break;
            case .Spades:
                rows = .(0b0001000, 0b0011100, 0b0111110, 0b1111111, 0b1110111, 0b0001000, 0b0011100);
                break;
        }

        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        for (int row = 0; row < 7; row++)
        {
            for (int col = 0; col < 7; col++)
            {
                if (((rows[row] >> (6 - col)) & 1) == 1)
                {
                    SDL_FRect px = .() {
                        x = cx + col * scale,
                        y = cy + row * scale,
                        w = scale,
                        h = scale
                    };
                    SDL_RenderFillRect(renderer, &px);
                }
            }
        }
    }

    public override void draw(SDL_Renderer* renderer, my_game game)
    {
        draw_stage_pips(renderer);
        draw_prompt(renderer, game);
        draw_cards(renderer, game);
        draw_controls(renderer, game);
    }

    private void draw_stage_pips(SDL_Renderer* renderer)
    {
        float total_pips_w = PIP_SIZE * 4 + PIP_GAP * 3; // 42
        float pip_start_x = PANEL_CENTER_X - total_pips_w / 2.0f; // 299

        for (int i = 0; i < 4; i++)
        {
            float px = pip_start_x + i * (PIP_SIZE + PIP_GAP);
            SDL_FRect pip = .() { x = px, y = PIP_Y, w = PIP_SIZE, h = PIP_SIZE };

            if (i < m_correct_guesses)
            {
                // Completed stage — gold filled
                SDL_SetRenderDrawColor(renderer, 241, 196, 15, 255);
                SDL_RenderFillRect(renderer, &pip);
            }
            else if ((RideTheBusStage)i == m_stage && !m_resolved)
            {
                // Current stage — pulsing outline
                float pulse = (float)Math.Sin(m_timer * 4.0f) * 0.5f + 0.5f;
                uint8 pa = (uint8)(120 + pulse * 135);
                SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
                SDL_SetRenderDrawColor(renderer, 241, 196, 15, pa);
                SDL_RenderRect(renderer, &pip);
                SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
            }
            else
            {
                // Future stage — dim
                SDL_SetRenderDrawColor(renderer, 60, 60, 70, 255);
                SDL_RenderRect(renderer, &pip);
            }
        }
    }

    private void draw_prompt(SDL_Renderer* renderer, my_game game)
    {
        StringView prompt = "";
        uint8 pr = 200, pg2 = 200, pb = 200; // Default neutral

        if (m_message.Length > 0)
        {
            prompt = m_message;
            if (m_stage == .Win)
            {
                // PERFECT — bright green
                pr = 46; pg2 = 204; pb = 113;
            }
            else
            {
                // WRONG — red
                pr = 231; pg2 = 76; pb = 60;
            }
        }
        else
        {
            switch (m_stage)
            {
                case .RedOrBlack:
                    prompt = "RED OR BLACK";
                    pr = 241; pg2 = 196; pb = 15;
                    break;
                case .HigherOrLower:
                    prompt = "HIGHER OR LOWER";
                    pr = 241; pg2 = 196; pb = 15;
                    break;
                case .InOrOut:
                    prompt = "IN OR OUT";
                    pr = 241; pg2 = 196; pb = 15;
                    break;
                case .GuessSuit:
                    prompt = "GUESS THE SUIT";
                    pr = 241; pg2 = 196; pb = 15;
                    break;
                default:
                    break;
            }
        }

        float text_w = prompt.Length * 6.0f * 1.5f;
        SDL_SetRenderDrawColor(renderer, pr, pg2, pb, 255);
        game.draw_pixel_string(renderer, PANEL_CENTER_X - text_w / 2.0f, 246, prompt, 1.5f);

        // --- Decorative divider line (centered) ---
        float total_cards_w = CARD_WIDTH * 4 + CARD_GAP * 3; // 196
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, 80, 80, 95, 100);
        SDL_RenderLine(renderer, PANEL_CENTER_X - total_cards_w / 2.0f - 5, 261, PANEL_CENTER_X + total_cards_w / 2.0f + 5, 261);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    private void draw_cards(SDL_Renderer* renderer, my_game game)
    {
        float total_cards_w = CARD_WIDTH * 4 + CARD_GAP * 3; // 196
        float cards_start_x = PANEL_CENTER_X - total_cards_w / 2.0f; // 222

        for (int i = 0; i < 4; i++)
        {
            float cx = cards_start_x + i * (CARD_WIDTH + CARD_GAP);
            draw_single_card(renderer, game, cx, CARDS_Y, CARD_WIDTH, CARD_HEIGHT, m_cards[i], m_revealed[i], m_stage == (RideTheBusStage)i);
        }
    }

    private void draw_controls(SDL_Renderer* renderer, my_game game)
    {
        if (m_message.Length == 0)
        {
            float ctrl_y = 330;
            switch (m_stage)
            {
                case .RedOrBlack:
                    draw_key_label(renderer, game, PANEL_CENTER_X - 50, ctrl_y, "<", "RED");
                    draw_key_label(renderer, game, PANEL_CENTER_X + 4, ctrl_y, ">", "BLACK");
                    break;
                case .HigherOrLower:
                    draw_key_label(renderer, game, PANEL_CENTER_X - 47, ctrl_y, "^", "HIGH");
                    draw_key_label(renderer, game, PANEL_CENTER_X + 13, ctrl_y, "v", "LOW");
                    break;
                case .InOrOut:
                    draw_key_label(renderer, game, PANEL_CENTER_X - 43, ctrl_y, "<", "IN");
                    draw_key_label(renderer, game, PANEL_CENTER_X + 9, ctrl_y, ">", "OUT");
                    break;
                case .GuessSuit:
                    draw_key_label(renderer, game, PANEL_CENTER_X - 59, ctrl_y, "<", "h");
                    draw_key_label(renderer, game, PANEL_CENTER_X - 27, ctrl_y, "^", "d");
                    draw_key_label(renderer, game, PANEL_CENTER_X + 5, ctrl_y, "v", "c");
                    draw_key_label(renderer, game, PANEL_CENTER_X + 37, ctrl_y, ">", "s");
                    break;
                default:
                    break;
            }
        }
    }

    private void draw_single_card(SDL_Renderer* renderer, my_game game, float x, float y, float w, float h, card c, bool revealed, bool active)
    {
        draw_card_shadow(renderer, x, y, w, h);

        if (!revealed)
        {
            draw_card_back(renderer, game, x, y, w, h, active);
        }
        else
        {
            draw_card_front(renderer, game, x, y, w, h, c);
        }
    }

    private void draw_card_shadow(SDL_Renderer* renderer, float x, float y, float w, float h)
    {
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_FRect shadow = .() { x = x + 2, y = y + 2, w = w, h = h };
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 80);
        SDL_RenderFillRect(renderer, &shadow);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    private void draw_card_back(SDL_Renderer* renderer, my_game game, float x, float y, float w, float h, bool active)
    {
        SDL_FRect rect = .() { x = x, y = y, w = w, h = h };

        if (active)
        {
            // Pulsing glow border for active card
            float pulse = (float)Math.Sin(m_timer * 5.0f) * 0.5f + 0.5f;
            uint8 glow_a = (uint8)(100 + pulse * 155);

            SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
            SDL_FRect glow_outer = .() { x = x - 3, y = y - 3, w = w + 6, h = h + 6 };
            SDL_SetRenderDrawColor(renderer, 241, 196, 15, (uint8)(glow_a / 2));
            SDL_RenderFillRect(renderer, &glow_outer);
            SDL_FRect glow_mid = .() { x = x - 2, y = y - 2, w = w + 4, h = h + 4 };
            SDL_SetRenderDrawColor(renderer, 241, 196, 15, glow_a);
            SDL_RenderRect(renderer, &glow_mid);
            SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);

            // Card body — deep blue gradient feel
            SDL_SetRenderDrawColor(renderer, 25, 80, 140, 255);
            SDL_RenderFillRect(renderer, &rect);

            // Inner darker stripe for depth
            SDL_FRect inner = .() { x = x + 3, y = y + 3, w = w - 6, h = h - 6 };
            SDL_SetRenderDrawColor(renderer, 18, 60, 110, 255);
            SDL_RenderFillRect(renderer, &inner);

            // Diamond pattern on card back
            draw_card_back_pattern(renderer, x, y, w, h, 60, 140, 220, 60);

            // Bright border
            SDL_SetRenderDrawColor(renderer, 241, 196, 15, 255);
            SDL_RenderRect(renderer, &rect);

            // "?" in center with golden color
            SDL_SetRenderDrawColor(renderer, 241, 196, 15, 255);
            game.draw_pixel_string(renderer, x + w / 2.0f - 6.0f, y + h / 2.0f - 5.0f, "?", 2.0f);
        }
        else
        {
            // Inactive card — muted dark with subtle pattern
            SDL_SetRenderDrawColor(renderer, 40, 40, 48, 255);
            SDL_RenderFillRect(renderer, &rect);

            SDL_FRect inner2 = .() { x = x + 3, y = y + 3, w = w - 6, h = h - 6 };
            SDL_SetRenderDrawColor(renderer, 35, 35, 42, 255);
            SDL_RenderFillRect(renderer, &inner2);

            // Subtle diamond pattern
            draw_card_back_pattern(renderer, x, y, w, h, 70, 70, 80, 40);

            SDL_SetRenderDrawColor(renderer, 60, 60, 68, 255);
            SDL_RenderRect(renderer, &rect);
        }
    }

    private void draw_card_back_pattern(SDL_Renderer* renderer, float x, float y, float w, float h, uint8 r, uint8 g, uint8 b, uint8 a)
    {
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, r, g, b, a);
        for (float dy = 6; dy < h - 6; dy += 8)
        {
            for (float dx = 6; dx < w - 6; dx += 8)
            {
                float cx = x + dx;
                float cy = y + dy;
                SDL_RenderLine(renderer, cx, cy - 2, cx + 2, cy);
                SDL_RenderLine(renderer, cx + 2, cy, cx, cy + 2);
                SDL_RenderLine(renderer, cx, cy + 2, cx - 2, cy);
                SDL_RenderLine(renderer, cx - 2, cy, cx, cy - 2);
            }
        }
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    private void draw_card_front(SDL_Renderer* renderer, my_game game, float x, float y, float w, float h, card c)
    {
        SDL_FRect rect = .() { x = x, y = y, w = w, h = h };

        // Revealed card face — cream white background
        SDL_SetRenderDrawColor(renderer, 245, 242, 235, 255);
        SDL_RenderFillRect(renderer, &rect);
        
        uint8 r = 25, g = 25, b = 30; // Solid black/charcoal for Spades/Clubs
        if (c.is_red())
        {
            r = 200; g = 50; b = 40; // Red suits (Hearts/Diamonds)
        }
        
        // Colored accent stripe at top
        SDL_FRect accent = .() { x = x + 1, y = y + 1, w = w - 2, h = 3 };
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        SDL_RenderFillRect(renderer, &accent);

        // Outer border matching suit color
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        SDL_RenderRect(renderer, &rect);

        // Inner frame for premium feel
        SDL_FRect inner_frame = .() { x = x + 2, y = y + 5, w = w - 4, h = h - 7 };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, r, g, b, 40);
        SDL_RenderRect(renderer, &inner_frame);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);

        // Draw rank at top-left
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        if (c.value == 10)
        {
            game.draw_pixel_string(renderer, x + 3, y + 7, "10", 1.0f);
        }
        else
        {
            char8[2] rank_str = .();
            rank_str[0] = c.value_char();
            rank_str[1] = 0;
            game.draw_pixel_string(renderer, x + 4, y + 7, StringView(&rank_str[0]), 1.0f);
        }
        
        // Draw small suit icon at bottom-right
        char8[2] suit_str = .();
        suit_str[0] = c.suit_logo_char();
        suit_str[1] = 0;
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        game.draw_pixel_string(renderer, x + w - 9, y + h - 10, StringView(&suit_str[0]), 1.0f);
        
        // Draw large custom 7x7 suit icon in the center
        draw_suit_icon_7x7(renderer, x + w / 2.0f - 10.5f, y + h / 2.0f - 8.0f, c.suit, 3.0f, r, g, b);
    }

    private void draw_key_label(SDL_Renderer* renderer, my_game game, float x, float y, StringView key, StringView label)
    {
        // Key box background
        float key_w = key.Length * 6.0f + 6;
        SDL_FRect key_bg = .() { x = x, y = y, w = key_w, h = 10 };
        SDL_SetRenderDrawColor(renderer, 50, 50, 60, 255);
        SDL_RenderFillRect(renderer, &key_bg);
        SDL_SetRenderDrawColor(renderer, 100, 100, 115, 255);
        SDL_RenderRect(renderer, &key_bg);

        // Key text (centered in box)
        SDL_SetRenderDrawColor(renderer, 220, 220, 230, 255);
        game.draw_pixel_string(renderer, x + 3, y + 2, key, 1.0f);

        // Label text to the right
        SDL_SetRenderDrawColor(renderer, 160, 160, 170, 255);
        game.draw_pixel_string(renderer, x + key_w + 4, y + 2, label, 1.0f);
    }
}
