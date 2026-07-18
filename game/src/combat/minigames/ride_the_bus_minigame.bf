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

class ride_the_bus_minigame : attack_minigame
{
    public struct card
    {
        public int value;
        public CardSuit suit;

        public bool is_red() => suit == .Hearts || suit == .Diamonds;

        public char8 suit_logo_char()
        {
            switch (suit)
            {
                case .Hearts: return 'h';
                case .Diamonds: return 'd';
                case .Clubs: return 'c';
                case .Spades: return 's';
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

    private const float CARD_WIDTH = 40.0f;
    private const float CARD_HEIGHT = 55.0f;
    private const float CARD_GAP = 12.0f;
    private const float PANEL_CENTER_X = 320.0f;
    private const float CARDS_Y = 253.0f;
    private const float PIP_SIZE = 6.0f;
    private const float PIP_GAP = 6.0f;
    private const float PIP_Y = 220.0f;

    private card[4] m_cards;
    private bool[4] m_revealed;
    private RideTheBusStage m_stage = .RedOrBlack;
    private float m_transition_timer = 0.0f;
    private bool m_resolved = false;
    private String m_message = new .() ~ delete _;



    private int m_correct_guesses = 0;
    private bool m_last_guess_correct = false;
    private bool[4] m_guess_correct;

    public override void initialize()
    {
        m_timer = 0.0f;
        m_stage = .RedOrBlack;
        m_transition_timer = 0.0f;
        m_resolved = false;
        m_message.Set("");
        m_correct_guesses = 0;
        m_last_guess_correct = false;
        m_guess_correct[0] = false;
        m_guess_correct[1] = false;
        m_guess_correct[2] = false;
        m_guess_correct[3] = false;

        m_cards[0].value = (int)(game_rand.next() % 13) + 2;
        m_cards[0].suit = (CardSuit)(game_rand.next() % 4);

        while (true)
        {
            m_cards[1].value = (int)(game_rand.next() % 13) + 2;
            if (Math.Abs(m_cards[1].value - m_cards[0].value) >= 2)
                break;
        }
        m_cards[1].suit = (CardSuit)(game_rand.next() % 4);

        m_cards[2].value = (int)(game_rand.next() % 13) + 2;
        m_cards[2].suit = (CardSuit)(game_rand.next() % 4);

        m_cards[3].value = (int)(game_rand.next() % 13) + 2;
        m_cards[3].suit = (CardSuit)(game_rand.next() % 4);

        m_revealed[0] = false;
        m_revealed[1] = false;
        m_revealed[2] = false;
        m_revealed[3] = false;


    }

    public override void update(ref input_state input, float delta_time, my_game game)
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

        switch (m_stage)
        {
            case .RedOrBlack:
                update_stage_red_black(input.left_just_pressed, input.right_just_pressed);
                break;
            case .HigherOrLower:
                update_stage_higher_lower(input.up_just_pressed, input.down_just_pressed);
                break;
            case .InOrOut:
                update_stage_in_out(input.left_just_pressed, input.right_just_pressed);
                break;
            case .GuessSuit:
                update_stage_guess_suit(input.left_just_pressed, input.right_just_pressed, input.up_just_pressed, input.down_just_pressed);
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
            float dist = 0.80f;
            if (m_correct_guesses == 1) dist = 0.50f;
            else if (m_correct_guesses == 2) dist = 0.35f;
            else if (m_correct_guesses == 3) dist = 0.10f;
            else if (m_correct_guesses >= 4) dist = 0.0f;

            game.m_combat.resolve_attack(dist, game);
        }
    }

    private void update_transition(float delta_time)
    {
        m_transition_timer -= delta_time;
        if (m_transition_timer <= 0.0f)
        {
            m_message.Set("");
            m_stage = (RideTheBusStage)((int)m_stage + 1);
        }
    }

    private void guess_correct(int card_index)
    {
        m_revealed[card_index] = true;
        m_correct_guesses++;
        m_guess_correct[card_index] = true;
        m_last_guess_correct = true;
        m_message.Set("RIGHT");
        m_transition_timer = 0.6f;

        if (card_index == 3)
        {
            m_resolved = true;
            m_transition_timer = 0.8f;
        }
    }

    private void guess_wrong(int card_index)
    {
        m_revealed[card_index] = true;
        m_guess_correct[card_index] = false;
        m_last_guess_correct = false;
        m_message.Set("WRONG");
        m_transition_timer = 0.6f;

        if (card_index == 3)
        {
            m_resolved = true;
            m_transition_timer = 0.8f;
        }
    }

    private void update_stage_red_black(bool left_pressed, bool right_pressed)
    {
        if (left_pressed || right_pressed)
        {
            bool guessed_red = left_pressed;
            if (guessed_red == m_cards[0].is_red())
                guess_correct(0);
            else
                guess_wrong(0);
        }
    }

    private void update_stage_higher_lower(bool up_pressed, bool down_pressed)
    {
        if (up_pressed || down_pressed)
        {
            bool guessed_higher = up_pressed;
            bool is_higher = m_cards[1].value > m_cards[0].value;
            if (guessed_higher == is_higher)
                guess_correct(1);
            else
                guess_wrong(1);
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
                guess_correct(2);
            else
                guess_wrong(2);
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
                guess_correct(3);
            else
                guess_wrong(3);
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
        float total_pips_w = PIP_SIZE * 4 + PIP_GAP * 3;
        float pip_start_x = PANEL_CENTER_X - total_pips_w / 2.0f;

        for (int i = 0; i < 4; i++)
        {
            float px = pip_start_x + i * (PIP_SIZE + PIP_GAP);
            SDL_FRect pip = .() { x = px, y = PIP_Y, w = PIP_SIZE, h = PIP_SIZE };

            if (m_revealed[i] && m_guess_correct[i])
            {
                draw_utils.set_color(renderer, colors.GOLD);
                SDL_RenderFillRect(renderer, &pip);
            }
            else if (m_revealed[i] && !m_guess_correct[i])
            {
                draw_utils.set_color(renderer, colors.RED);
                SDL_RenderFillRect(renderer, &pip);
            }
            else if ((RideTheBusStage)i == m_stage && !m_resolved)
            {
                float pulse = (float)Math.Sin(m_timer * 4.0f) * 0.5f + 0.5f;
                uint8 pa = (uint8)(120 + pulse * 135);
                SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
                draw_utils.set_color(renderer, colors.GOLD, pa);
                SDL_RenderRect(renderer, &pip);
                SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
            }
            else
            {
                SDL_SetRenderDrawColor(renderer, 60, 60, 70, 255);
                SDL_RenderRect(renderer, &pip);
            }
        }
    }

    private void draw_prompt(SDL_Renderer* renderer, my_game game)
    {
        StringView prompt = "";
        uint8 pr = colors.TEXT_DEFAULT[0], pg2 = colors.TEXT_DEFAULT[1], pb = colors.TEXT_DEFAULT[2];

        if (m_message.Length > 0)
        {
            prompt = m_message;
            if (m_last_guess_correct)
            {
                pr = colors.GREEN[0]; pg2 = colors.GREEN[1]; pb = colors.GREEN[2];
            }
            else
            {
                pr = colors.RED[0]; pg2 = colors.RED[1]; pb = colors.RED[2];
            }
        }
        else
        {
            switch (m_stage)
            {
                case .RedOrBlack:
                    prompt = "RED OR BLACK";
                    pr = colors.GOLD[0]; pg2 = colors.GOLD[1]; pb = colors.GOLD[2];
                    break;
                case .HigherOrLower:
                    prompt = "HIGHER OR LOWER";
                    pr = colors.GOLD[0]; pg2 = colors.GOLD[1]; pb = colors.GOLD[2];
                    break;
                case .InOrOut:
                    prompt = "IN OR OUT";
                    pr = colors.GOLD[0]; pg2 = colors.GOLD[1]; pb = colors.GOLD[2];
                    break;
                case .GuessSuit:
                    prompt = "GUESS THE SUIT";
                    pr = colors.GOLD[0]; pg2 = colors.GOLD[1]; pb = colors.GOLD[2];
                    break;
                default:
                    break;
            }
        }

        float text_w = bitmap_font.measure_string(prompt, 16);
        SDL_SetRenderDrawColor(renderer, pr, pg2, pb, 255);
        bitmap_font.draw_string(renderer, PANEL_CENTER_X - text_w / 2.0f, 231 - 4, prompt, 16);

        float total_cards_w = CARD_WIDTH * 4 + CARD_GAP * 3;
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        draw_utils.set_color(renderer, colors.PANEL_BORDER_ALT, 100);
        SDL_RenderLine(renderer, PANEL_CENTER_X - total_cards_w / 2.0f - 5, 246, PANEL_CENTER_X + total_cards_w / 2.0f + 5, 246);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    private void draw_cards(SDL_Renderer* renderer, my_game game)
    {
        float total_cards_w = CARD_WIDTH * 4 + CARD_GAP * 3;
        float cards_start_x = PANEL_CENTER_X - total_cards_w / 2.0f;

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
            float ctrl_y = 315;
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
            float pulse = (float)Math.Sin(m_timer * 5.0f) * 0.5f + 0.5f;
            uint8 glow_a = (uint8)(100 + pulse * 155);

            SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
            SDL_FRect glow_outer = .() { x = x - 3, y = y - 3, w = w + 6, h = h + 6 };
            draw_utils.set_color(renderer, colors.GOLD, (uint8)(glow_a / 2));
            SDL_RenderFillRect(renderer, &glow_outer);
            SDL_FRect glow_mid = .() { x = x - 2, y = y - 2, w = w + 4, h = h + 4 };
            draw_utils.set_color(renderer, colors.GOLD, glow_a);
            SDL_RenderRect(renderer, &glow_mid);
            SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);

            SDL_SetRenderDrawColor(renderer, 25, 80, 140, 255);
            SDL_RenderFillRect(renderer, &rect);

            SDL_FRect inner = .() { x = x + 3, y = y + 3, w = w - 6, h = h - 6 };
            SDL_SetRenderDrawColor(renderer, 18, 60, 110, 255);
            SDL_RenderFillRect(renderer, &inner);

            draw_card_back_pattern(renderer, x, y, w, h, 60, 140, 220, 60);

            draw_utils.set_color(renderer, colors.GOLD);
            SDL_RenderRect(renderer, &rect);

            draw_utils.set_color(renderer, colors.GOLD);
            float q_w = bitmap_font.measure_string("?", 16);
            bitmap_font.draw_string(renderer, x + (w - q_w) / 2.0f, y + (h - 16) / 2.0f, "?", 16);
        }
        else
        {
            SDL_SetRenderDrawColor(renderer, 40, 40, 48, 255);
            SDL_RenderFillRect(renderer, &rect);

            SDL_FRect inner2 = .() { x = x + 3, y = y + 3, w = w - 6, h = h - 6 };
            SDL_SetRenderDrawColor(renderer, 35, 35, 42, 255);
            SDL_RenderFillRect(renderer, &inner2);

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

        SDL_SetRenderDrawColor(renderer, 245, 242, 235, 255);
        SDL_RenderFillRect(renderer, &rect);

        uint8 r = 25, g = 25, b = 30;
        if (c.is_red())
        {
            r = colors.RED[0]; g = colors.RED[1]; b = colors.RED[2];
        }

        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        SDL_RenderRect(renderer, &rect);

        SDL_FRect inner_frame = .() { x = x + 2, y = y + 2, w = w - 4, h = h - 4 };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, r, g, b, 40);
        SDL_RenderRect(renderer, &inner_frame);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);

        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        if (c.value == 10)
        {
            bitmap_font.draw_string(renderer, x + 3, y + 3, "10", 16);
        }
        else
        {
            char8[2] rank_str = .();
            rank_str[0] = c.value_char();
            rank_str[1] = 0;
            bitmap_font.draw_string(renderer, x + 3, y + 3, StringView(&rank_str[0]), 16);
        }

        char8[2] suit_str = .();
        suit_str[0] = c.suit_logo_char();
        suit_str[1] = 0;
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        float suit_w = bitmap_font.measure_string(StringView(&suit_str[0]), 16);
        bitmap_font.draw_string(renderer, x + w - suit_w - 3, y + h - 19, StringView(&suit_str[0]), 16);

        draw_suit_icon_7x7(renderer, x + w / 2.0f - 10.5f, y + h / 2.0f - 8.0f, c.suit, 3.0f, r, g, b);
    }

    private void draw_key_label(SDL_Renderer* renderer, my_game game, float x, float y, StringView key, StringView label)
    {
        float key_w = bitmap_font.measure_string(key, 16) + 6;
        SDL_FRect key_bg = .() { x = x, y = y - 3, w = key_w, h = 22 };
        draw_utils.set_color(renderer, colors.KEY_BG);
        SDL_RenderFillRect(renderer, &key_bg);
        draw_utils.set_color(renderer, colors.KEY_BORDER);
        SDL_RenderRect(renderer, &key_bg);

        draw_utils.set_color(renderer, colors.KEY_TEXT);
        bitmap_font.draw_string(renderer, x + 3, y, key, 16);

        draw_utils.set_color(renderer, colors.KEY_LABEL);
        bitmap_font.draw_string(renderer, x + key_w + 4, y, label, 16);
    }
}
