using System;
using System.Collections;
using engine.core;
using engine.diagnostics;
using SDL3;
using SDL3_image;

namespace game;

enum ActionType
{
    Fight = 0,
    Item = 1,
    Defend = 2,
    Mercy = 3
}

enum MinigameType
{
    Slider = 0,
    Tap = 1,
    Arrow = 2,
    Charge = 3,
    RideTheBus = 4
}

enum BulletPatternType
{
    Waves = 0,
    Spiral = 1,
    Rain = 2,
    Homing = 3
}

class my_game : i_game_loop
{
    private character m_player = null;
    private character m_enemy = null;
    private combat_state m_current_state;

    private List<enemy_bullet> m_bullets = new .() ~ delete _;
    private float m_dodge_timer = 0.0f;
    private float m_spawn_timer = 0.0f;
    private const float MAX_DODGE_TIME = 8.0f;

    private attack_minigame m_active_minigame = null;
    private bullet_pattern m_active_pattern = null;
    private String m_mg_result_text = new .() ~ delete _;
    private float m_mg_result_timer = 0.0f;

    private int m_player_actions_left = 1;
    private int m_max_player_actions = 1;

    private ActionType m_selected_action = .Fight;
    private MinigameType? m_last_mg_type = null;
    private BulletPatternType? m_last_pattern = null;
    private float m_game_time = 0.0f;

    public bool prev_space => m_prev_space;

    public float get_arena_x() => m_arena_x;
    public float get_arena_y() => m_arena_y;
    public float get_arena_w() => m_arena_w;
    public float get_arena_h() => m_arena_h;
    public float get_soul_x() => m_soul_x;
    public float get_soul_y() => m_soul_y;
    public float get_soul_size() => m_soul_size;
    public float get_enemy_x() => m_enemy.x;
    public float get_enemy_y() => m_enemy.y;
    public float get_dodge_timer() => m_dodge_timer;

    public void spawn_bullet(float x, float y, float speed_x, float speed_y)
    {
        m_bullets.Add(.(x, y, speed_x, speed_y));
    }

    private float m_soul_x;
    private float m_soul_y;
    private float m_soul_size = 12.0f;
    private float m_soul_speed = 180.0f;
    private float m_soul_resistance = 1.0f;
    private SDL_Texture* m_soul_texture = null;
    private float m_invincibility_timer = 0.0f;
    private float m_invincibility_phase = 0.0f;
    private const float INVINCIBILITY_DURATION = 1.5f;
    private float m_graze_visual_timer = 0.0f;
    private const float GRAZE_VISUAL_DURATION = 0.25f;
    private const float GRAZE_MARGIN = 12.0f;

    private float m_arena_x = 220.0f;
    private float m_arena_y = 80.0f;
    private float m_arena_w = 200.0f;
    private float m_arena_h = 200.0f;

    private bool m_prev_left = false;
    private bool m_prev_right = false;
    private bool m_prev_space = false;
    private bool m_prev_return = false;

    public void initialize()
    {
        logger.info("my_game has initialized!");

        m_player = new character("Hero", 100, 10, 5, 5, 100.0f, 150.0f); 
        m_enemy = new character("Demon", 100, 10, 5, 5, 500.0f, 150.0f);

        m_soul_x = m_arena_x + (m_arena_w / 2) - (m_soul_size / 2);
        m_soul_y = m_arena_y + (m_arena_h / 2) - (m_soul_size / 2);

        m_current_state = .strategy; 
        m_player_actions_left = 1;
        m_max_player_actions = 1;
        m_selected_action = .Fight;
        m_last_mg_type = null;
        m_last_pattern = null;
    }

    public void update(float delta_time)
    {
        bool* keys = (bool*)SDL_GetKeyboardState(null);
        bool left_pressed = keys[(int32)SDL_Scancode.SDL_SCANCODE_LEFT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_A];
        bool right_pressed = keys[(int32)SDL_Scancode.SDL_SCANCODE_RIGHT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_D];
        bool space_pressed = keys[(int32)SDL_Scancode.SDL_SCANCODE_SPACE];
        bool return_pressed = keys[(int32)SDL_Scancode.SDL_SCANCODE_RETURN];

        m_game_time += delta_time;

        if (m_mg_result_timer > 0.0f)
        {
            m_mg_result_timer -= delta_time;
        }

        if (m_graze_visual_timer > 0.0f)
        {
            m_graze_visual_timer -= delta_time;
            if (m_graze_visual_timer < 0.0f)
                m_graze_visual_timer = 0.0f;
        }

        if (m_invincibility_timer > 0.0f)
        {
            float progress = (INVINCIBILITY_DURATION - m_invincibility_timer) / INVINCIBILITY_DURATION;
            float current_frequency = 6.0f + progress * 24.0f;
            m_invincibility_phase += delta_time * current_frequency;

            m_invincibility_timer -= delta_time;
            if (m_invincibility_timer < 0.0f)
            {
                m_invincibility_timer = 0.0f;
                m_invincibility_phase = 0.0f;
            }
        }

        switch (m_current_state) {
            case .strategy:
                update_strategy(left_pressed, right_pressed, space_pressed);
                break;
                
            case .minigame:
                if (m_active_minigame != null)
                {
                    m_active_minigame.update(space_pressed, keys, delta_time, this);
                }
                break;
                
            case .dodging:
                update_dodging(keys, return_pressed, delta_time);
                break;
        }

        check_battle_status();

        m_prev_left = left_pressed;
        m_prev_right = right_pressed;
        m_prev_space = space_pressed;
        m_prev_return = return_pressed;
    }

    private void update_strategy(bool left_pressed, bool right_pressed, bool space_pressed)
    {
        if (left_pressed && !m_prev_left) {
            int action_val = (int)m_selected_action - 1;
            if (action_val < 0) {
                action_val = 3;
            }
            m_selected_action = (ActionType)action_val;
            logger.info(scope $"Selected Action changed to: {m_selected_action}");
        }
        else if (right_pressed && !m_prev_right) {
            int action_val = (int)m_selected_action + 1;
            if (action_val > 3) {
                action_val = 0;
            }
            m_selected_action = (ActionType)action_val;
            logger.info(scope $"Selected Action changed to: {m_selected_action}");
        }

        if (space_pressed && !m_prev_space) {
            execute_action();
        }
    }

    private void execute_action()
    {
        switch (m_selected_action) {
            case .Fight:
                logger.info("Attack Action.");
                if (m_player.tp >= 20)
                {
                    start_attack_minigame();
                }
                else
                {
                    logger.info("Not enough TP!");
                }
                break;
            case .Item:
                logger.info("Item Action.");
                m_player.heal(20);
                m_player_actions_left--;
                check_turn_resolution();
                break;
            case .Defend:
                logger.info("Defend Action.");
                m_soul_resistance -= 0.5f;
                m_player.tp += 50;
                if (m_player.tp > m_player.max_tp)
                {
                    m_player.tp = m_player.max_tp;
                }
                if (m_soul_resistance < 0.1f)
                {
                    m_soul_resistance = 0.1f;
                }
                m_player_actions_left--;
                check_turn_resolution();
                break;
            case .Mercy:
                logger.info("Mercy Action.");
                if (m_enemy.is_mercy_ready()) {
                    logger.info("Enemy spared! Defeating...");
                    m_enemy.take_damage(m_enemy.health);
                } else {
                    m_enemy.mercy_bar += 1;
                    if (m_enemy.mercy_bar > m_enemy.max_mercy_bar) {
                        m_enemy.mercy_bar = m_enemy.max_mercy_bar;
                    }
                }
                m_player_actions_left--;
                check_turn_resolution();
                break;
        }
    }

    private void start_dodge_phase()
    {
        m_current_state = .dodging;
        logger.info("Dodge Phase.");
        
        m_soul_x = m_arena_x + (m_arena_w / 2) - (m_soul_size / 2);
        m_soul_y = m_arena_y + (m_arena_h / 2) - (m_soul_size / 2);

        m_bullets.Clear();
        m_dodge_timer = 0.0f;
        m_spawn_timer = 0.0f;
        m_graze_visual_timer = 0.0f;
        m_invincibility_timer = 0.0f;
        m_invincibility_phase = 0.0f;

        delete m_active_pattern;
        BulletPatternType next_pattern = .Waves;
        while (true)
        {
            next_pattern = (BulletPatternType)(game_rand.next() % 4);
            if (next_pattern != m_last_pattern)
                break;
        }

        m_last_pattern = next_pattern;

        switch (next_pattern)
        {
            case .Waves: m_active_pattern = new waves_pattern(); break;
            case .Spiral: m_active_pattern = new spiral_pattern(); break;
            case .Rain: m_active_pattern = new rain_pattern(); break;
            case .Homing: m_active_pattern = new homing_pattern(); break;
        }
        m_active_pattern.initialize(this);
        logger.info(scope $"Dodge phase started with Pattern: {next_pattern}");
    }

    private void update_dodging(bool* keys, bool return_pressed, float delta_time)
    {
        if (return_pressed && !m_prev_return) {
            start_strategy_phase();
            return;
        }

        m_dodge_timer += delta_time;
        if (m_dodge_timer >= MAX_DODGE_TIME) {
            start_strategy_phase();
            return;
        }

        update_bullets(delta_time);
        update_soul_movement(keys, delta_time);
    }

    private void start_strategy_phase()
    {
        m_current_state = .strategy;
        logger.info("Strategy Phase.");
        m_bullets.Clear();
        m_soul_resistance = 1.0f;

        if (m_enemy.is_staggered())
        {
            m_player_actions_left = 2;
            m_max_player_actions = 2;
            logger.info("Enemy is staggered! Player gets 2 actions.");
        }
        else
        {
            m_player_actions_left = 1;
            m_max_player_actions = 1;
        }
    }

    private void update_bullets(float delta_time)
    {
        if (m_active_pattern != null)
        {
            m_active_pattern.update(delta_time, this);
        }
        
        float center_x = m_arena_x + m_arena_w / 2.0f;
        float center_y = m_arena_y + m_arena_h / 2.0f;

        for (int i = 0; i < m_bullets.Count; i++)
        {
            enemy_bullet* bullet = &m_bullets[i];
            bullet.x += bullet.speed_x * delta_time;
            bullet.y += bullet.speed_y * delta_time;

            bool is_colliding = (m_soul_x < bullet.x + bullet.size &&
                                 m_soul_x + m_soul_size > bullet.x &&
                                 m_soul_y < bullet.y + bullet.size &&
                                 m_soul_y + m_soul_size > bullet.y);

            if (is_colliding && m_invincibility_timer <= 0.0f)
            {
                m_player.take_damage((int)(bullet.damage * m_soul_resistance));
                logger.info(scope $"The player took damage! Health: {m_player.health}");
                m_invincibility_timer = INVINCIBILITY_DURATION;
                m_invincibility_phase = 0.0f;
                m_bullets.RemoveAt(i);
                i--;
                continue;
            }

            bool is_in_graze_range = (m_soul_x - GRAZE_MARGIN < bullet.x + bullet.size &&
                                      m_soul_x + m_soul_size + GRAZE_MARGIN > bullet.x &&
                                      m_soul_y - GRAZE_MARGIN < bullet.y + bullet.size &&
                                      m_soul_y + m_soul_size + GRAZE_MARGIN > bullet.y);

            if (is_in_graze_range)
            {
                m_graze_visual_timer = GRAZE_VISUAL_DURATION;
                if (!bullet.is_grazed)
                {
                    bullet.is_grazed = true;
                    m_player.tp += 5;
                    if (m_player.tp > m_player.max_tp)
                    {
                        m_player.tp = m_player.max_tp;
                    }
                    logger.info(scope $"Graze! TP gained. Current TP: {m_player.tp}");
                }
            }

            float dx = bullet.x - center_x;
            float dy = bullet.y - center_y;
            if (dx * dx + dy * dy > 250.0f * 250.0f)
            {
                m_bullets.RemoveAt(i);
                i--;
            }
        }
    }

    private void update_soul_movement(bool* keys, float delta_time)
    {
        if (keys[(int32)SDL_Scancode.SDL_SCANCODE_W] || keys[(int32)SDL_Scancode.SDL_SCANCODE_UP]) m_soul_y -= m_soul_speed * delta_time;
        if (keys[(int32)SDL_Scancode.SDL_SCANCODE_S] || keys[(int32)SDL_Scancode.SDL_SCANCODE_DOWN]) m_soul_y += m_soul_speed * delta_time;
        if (keys[(int32)SDL_Scancode.SDL_SCANCODE_A] || keys[(int32)SDL_Scancode.SDL_SCANCODE_LEFT]) m_soul_x -= m_soul_speed * delta_time;
        if (keys[(int32)SDL_Scancode.SDL_SCANCODE_D] || keys[(int32)SDL_Scancode.SDL_SCANCODE_RIGHT]) m_soul_x += m_soul_speed * delta_time;

        if (m_soul_x < m_arena_x) m_soul_x = m_arena_x;
        if (m_soul_y < m_arena_y) m_soul_y = m_arena_y;
        if (m_soul_x > m_arena_x + m_arena_w - m_soul_size) m_soul_x = m_arena_x + m_arena_w - m_soul_size;
        if (m_soul_y > m_arena_y + m_arena_h - m_soul_size) m_soul_y = m_arena_y + m_arena_h - m_soul_size;
    }

    private void check_battle_status()
    {
        if (m_player.is_dead())
        {
            logger.info("Player died! Respawning...");
            respawn_player();
        }
        
        if (m_enemy.is_dead())
        {
            logger.info("Enemy died! Respawning...");
            respawn_enemy();
        }
    }

    private void check_turn_resolution()
    {
        if (m_enemy.is_dead())
        {
            return;
        }

        if (m_max_player_actions == 2 && m_player_actions_left == 1)
        {
            logger.info("First extra action used. Clearing stagger bar.");
            m_enemy.recover_from_stun();
        }

        if (m_player_actions_left <= 0)
        {
            if (m_max_player_actions == 2)
            {
                logger.info("Extra turn finished. Entering dodge phase.");
                start_dodge_phase();
            }
            else if (m_enemy.is_staggered())
            {
                logger.info("Enemy Staggered! Skipping dodge phase.");
                start_strategy_phase();
            }
            else
            {
                start_dodge_phase();
            }
        }
    }

    private void start_attack_minigame()
    {
        delete m_active_minigame;
        m_current_state = .minigame;
        MinigameType type = .Slider;
        while (true)
        {
            type = (MinigameType)(game_rand.next() % 5);
            if (type != m_last_mg_type)
                break;
        }

        m_last_mg_type = type;

        switch (type)
        {
            case .Slider: m_active_minigame = new slider_minigame(); break;
            case .Tap: m_active_minigame = new tap_minigame(); break;
            case .Arrow: m_active_minigame = new arrow_minigame(); break;
            case .Charge: m_active_minigame = new charge_minigame(); break;
            case .RideTheBus: m_active_minigame = new ride_the_bus_minigame(); break;
        }
        m_active_minigame.initialize();
        logger.info(scope $"Attack Minigame started: Type {type}");
    }

    public void resolve_attack(float dist)
    {
        float score = 1.0f;
        int stagger_gain = 0;

        if (dist <= 0.05f)
        {
            m_mg_result_text.Set("PERFECT!");
            score = 1.5f;
            stagger_gain = 2;
        }
        else if (dist <= 0.18f)
        {
            m_mg_result_text.Set("GOOD");
            score = 1.0f;
            stagger_gain = 1;
        }
        else if (dist < 0.6f)
        {
            m_mg_result_text.Set("WEAK");
            score = 0.5f;
            stagger_gain = 1;
        }
        else
        {
            m_mg_result_text.Set("MISS");
            score = 0.0f;
            stagger_gain = 0;
        }

        m_mg_result_timer = 0.8f;
        m_current_state = .strategy;

        delete m_active_minigame;
        m_active_minigame = null;

        int damage = (int)(m_player.attack_power * 2 * score);
        m_enemy.take_damage(damage);
        m_player.tp -= 20;

        m_enemy.stagger += stagger_gain;
        if (m_enemy.stagger > m_enemy.max_stagger)
        {
            m_enemy.stagger = m_enemy.max_stagger;
        }

        logger.info(scope $"Minigame result: {m_mg_result_text}, damage={damage}, stagger_gain={stagger_gain}");

        m_player_actions_left--;
        check_turn_resolution();
    }

    public void draw_circle_outline(SDL_Renderer* renderer, float cx, float cy, float radius, uint8 r, uint8 g, uint8 b, uint8 a)
    {
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, r, g, b, a);
        const int points = 24;
        float prev_x = cx + radius;
        float prev_y = cy;
        for (int i = 1; i <= points; i++)
        {
            float angle = (i * 2.0f * 3.14159f) / points;
            float curr_x = cx + (float)Math.Cos(angle) * radius;
            float curr_y = cy + (float)Math.Sin(angle) * radius;
            SDL_RenderLine(renderer, prev_x, prev_y, curr_x, curr_y);
            prev_x = curr_x;
            prev_y = curr_y;
        }
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    public void draw_circle_filled(SDL_Renderer* renderer, float cx, float cy, float radius, uint8 r, uint8 g, uint8 b, uint8 a)
    {
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, r, g, b, a);
        for (float dy = -radius; dy <= radius; dy += 1.0f)
        {
            float dx = (float)Math.Sqrt(radius * radius - dy * dy);
            SDL_RenderLine(renderer, cx - dx, cy + dy, cx + dx, cy + dy);
        }
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    public void draw_pixel_char(SDL_Renderer* renderer, float x, float y, char8 c, float scale)
    {
        uint32 glyph = 0;
        switch (c)
        {
            case 'S': glyph = 0b1111110000111110000111111; break;
            case 'M': glyph = 0b1000111011101011000110001; break;
            case 'D': glyph = 0b1111010001100011000111110; break;
            case 'T': glyph = 0b1111100100001000010000100; break;
            case 'R': glyph = 0b1111010001111101001010001; break;
            case 'A': glyph = 0b0111010001111111000110001; break;
            case 'E': glyph = 0b1111110000111101000011111; break;
            case 'G': glyph = 0b0111010000101111000101110; break;
            case 'I': glyph = 0b0111000100001000010001110; break;
            case 'N': glyph = 0b1000111001101011001110001; break;
            case 'O': glyph = 0b0111010001100011000101110; break;
            case 'Y': glyph = 0b1000110001010100010000100; break;
            case 'F': glyph = 0b1111110000111101000010000; break;
            case 'H': glyph = 0b1000110001111111000110001; break;
            case 'C': glyph = 0b0111110000100001000001111; break;
            case 'J': glyph = 0b0111100010000101001001100; break;
            case 'K': glyph = 0b1000110010111001001010001; break;
            case 'Q': glyph = 0b0111010001100011001001101; break;
            case 'P': glyph = 0b1111010001111101000010000; break;
            case 'U': glyph = 0b1000110001100011000101110; break;
            case 'B': glyph = 0b1111010001111101000111110; break;
            case 'L': glyph = 0b1000010000100001000011111; break;
            case 'W': glyph = 0b1000110001101011101110001; break;
            case 'V': glyph = 0b1000110001100010101000100; break;
            case '0': glyph = 0b0111010011101011100101110; break;
            case '1': glyph = 0b0010001100001000010001110; break;
            case '2': glyph = 0b1111000001011101000011111; break;
            case '3': glyph = 0b1111000001011100000111111; break;
            case '4': glyph = 0b1000110001111110000100001; break;
            case '5': glyph = 0b1111110000111100000111110; break;
            case '6': glyph = 0b0111110000111101000101110; break;
            case '7': glyph = 0b1111100001000100010000100; break;
            case '8': glyph = 0b0111010001011101000101110; break;
            case '9': glyph = 0b0111010001011110000101110; break;
            case '?': glyph = 0b0111010001001100010000100; break;
            case '<': glyph = 0b0010001100111110110000100; break; // Solid Left Arrow
            case '>': glyph = 0b0010000110111110011000100; break; // Solid Right Arrow
            case '-': glyph = 0b0000000000111110000000000; break;
            case '^': glyph = 0b0010001110111110010000100; break; // Solid Up Arrow
            case 'v': glyph = 0b0010000100111110111000100; break; // Solid Down Arrow
            case 'h': glyph = 0b0101011111111110111000100; break;
            case 'd': glyph = 0b0010001110111110111000100; break;
            case 'c': glyph = 0b0010001110111110010001110; break; // Refined 5x5 Club
            case 's': glyph = 0b0010001110111111101100100; break; // Refined 5x5 Spade
        }

        if (glyph == 0) return;

        for (int row = 0; row < 5; row++)
        {
            for (int col = 0; col < 5; col++)
            {
                int bitIndex = 24 - (row * 5 + col);
                if (((glyph >> bitIndex) & 1) == 1)
                {
                    SDL_FRect px = .() {
                        x = x + col * scale,
                        y = y + row * scale,
                        w = scale,
                        h = scale
                    };
                    SDL_RenderFillRect(renderer, &px);
                }
            }
        }
    }

    public void draw_pixel_string(SDL_Renderer* renderer, float x, float y, StringView text, float scale)
    {
        float cur_x = x;
        for (int i = 0; i < text.Length; i++)
        {
            draw_pixel_char(renderer, cur_x, y, text[i], scale);
            cur_x += 6.0f * scale;
        }
    }

    private void respawn_player()
    {
        m_player.reset_character(100.0f, 150.0f);
        m_last_mg_type = null;
        m_last_pattern = null;
        m_invincibility_timer = 0.0f;
        m_invincibility_phase = 0.0f;
        start_strategy_phase();
    }

    private void respawn_enemy()
    {
        m_enemy.max_health += 10;
        m_enemy.attack_power += 2;
        m_enemy.reset_character(500.0f, 150.0f);
        m_last_mg_type = null;
        m_last_pattern = null;
        start_strategy_phase();
    }

    private void draw_bar(SDL_Renderer* renderer, float x, float y, float val, float max_val, uint8 r, uint8 g, uint8 b)
    {
        float bar_width = 32;
        float bar_height = 4;
        float bar_w = val * bar_width / max_val;
        if (bar_w < 0.0f) bar_w = 0.0f;
        if (bar_w > bar_width) bar_w = bar_width;

        SDL_FRect max_bar = .() { x = x, y = y, w = bar_width, h = bar_height };
        SDL_FRect bar = .() { x = x, y = y, w = bar_w, h = bar_height };

        SDL_SetRenderDrawColor(renderer, 25, 25, 30, 255);
        SDL_RenderFillRect(renderer, &max_bar);

        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        SDL_RenderFillRect(renderer, &bar);

        SDL_SetRenderDrawColor(renderer, 50, 50, 55, 255);
        SDL_RenderRect(renderer, &max_bar);
    }

    private void draw_bars(SDL_Renderer* renderer, character c)
    {
        if (c == m_player)
        {
            draw_bar(renderer, c.x, c.y - 12, c.health, c.max_health, 46, 204, 113);
            draw_bar(renderer, c.x, c.y - 20, c.tp, c.max_tp, 241, 196, 15);

            if (m_current_state == .strategy)
            {
                for (int i = 0; i < m_player_actions_left; i++)
                {
                    SDL_FRect dot = .() { x = c.x + i * 8, y = c.y - 28, w = 4, h = 4 };
                    SDL_SetRenderDrawColor(renderer, 46, 204, 113, 255);
                    SDL_RenderFillRect(renderer, &dot);
                }
            }
        }
        else
        {
            draw_bar(renderer, c.x, c.y - 12, c.health, c.max_health, 231, 76, 60);
            
            uint8 sr = 255;
            uint8 sg = 255;
            uint8 sb = 255;
            if (c.is_staggered())
            {
                sr = (uint8)((Math.Sin(m_game_time * 4.0f) * 0.5f + 0.5f) * 200 + 55);
                sg = (uint8)((Math.Sin(m_game_time * 4.0f + 2.094f) * 0.5f + 0.5f) * 200 + 55);
                sb = (uint8)((Math.Sin(m_game_time * 4.0f + 4.188f) * 0.5f + 0.5f) * 200 + 55);
            }
            draw_bar(renderer, c.x, c.y - 20, c.stagger, c.max_stagger, sr, sg, sb);
            
            draw_bar(renderer, c.x, c.y - 28, c.mercy_bar, c.max_mercy_bar, 52, 152, 219);
        }
    }

    public void draw(SDL_Renderer* renderer, float alpha)
    {
        if (m_current_state == .strategy)
        {
            SDL_FRect bg = .() { x = 8, y = 338, w = 82, h = 14 };
            SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
            SDL_SetRenderDrawColor(renderer, 20, 20, 25, 180);
            SDL_RenderFillRect(renderer, &bg);
            SDL_SetRenderDrawColor(renderer, 70, 70, 80, 255);
            SDL_RenderRect(renderer, &bg);

            StringView action_str = "";
            switch (m_selected_action)
            {
                case .Fight: action_str = "FIGHT"; break;
                case .Item: action_str = "ITEM"; break;
                case .Defend: action_str = "DEFEND"; break;
                case .Mercy: action_str = "MERCY"; break;
            }

            float txt_w = action_str.Length * 9.0f;
            float txt_x = 49.0f - (txt_w / 2.0f);

            SDL_SetRenderDrawColor(renderer, 241, 196, 15, 255);
            draw_pixel_string(renderer, txt_x, 341, action_str, 1.5f);
            SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
        }

        draw_bars(renderer, m_player);
        
        SDL_FRect player_rect = .() { x = m_player.x, y = m_player.y, w = m_player.width, h = m_player.height };
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(renderer, &player_rect);

        draw_bars(renderer, m_enemy);

        SDL_FRect enemy_rect = .() { x = m_enemy.x, y = m_enemy.y, w = m_enemy.width, h = m_enemy.height };
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(renderer, &enemy_rect);

        if (m_current_state == .dodging) {
            SDL_FRect arena_rect = .() { x = m_arena_x, y = m_arena_y, w = m_arena_w, h = m_arena_h };
            SDL_SetRenderDrawColor(renderer, 50, 50, 50, 255); 
            SDL_RenderFillRect(renderer, &arena_rect);

            float cx = m_soul_x + m_soul_size / 2.0f;
            float cy = m_soul_y + m_soul_size / 2.0f;
            float radius = m_soul_size / 2.0f + GRAZE_MARGIN;
 
            if (m_graze_visual_timer > 0.0f)
            {
                float t = m_graze_visual_timer / GRAZE_VISUAL_DURATION;
                uint8 graze_alpha = (uint8)(t * 80);
                draw_circle_filled(renderer, cx, cy, radius, 252, 239, 141, graze_alpha);
            }

            if (m_soul_texture == null)
            {
                m_soul_texture = IMG_LoadTexture(renderer, "game/assets/beta_soul.png");
                if (m_soul_texture == null)
                    m_soul_texture = IMG_LoadTexture(renderer, "assets/beta_soul.png");
                if (m_soul_texture == null)
                    m_soul_texture = IMG_LoadTexture(renderer, "../game/assets/beta_soul.png");
            }

            SDL_FRect soul_rect = .() { x = m_soul_x, y = m_soul_y, w = m_soul_size, h = m_soul_size };
            uint8 target_alpha = 255;
            if (m_invincibility_timer > 0.0f)
            {
                int blink_step = (int)m_invincibility_phase;
                if (blink_step % 2 == 0)
                {
                    target_alpha = 127;
                }
            }

            if (m_soul_texture != null)
            {
                SDL_SetTextureAlphaMod(m_soul_texture, target_alpha);
                SDL_RenderTexture(renderer, m_soul_texture, null, &soul_rect);
                SDL_SetTextureAlphaMod(m_soul_texture, 255);
            }
            else
            {
                SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
                SDL_SetRenderDrawColor(renderer, 0, 255, 100, target_alpha); 
                SDL_RenderFillRect(renderer, &soul_rect);
                SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
            }

            SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255);
            for (int i = 0; i < m_bullets.Count; i++) {
                ref enemy_bullet bullet = ref m_bullets[i];
                SDL_FRect bullet_rect = .() { x = bullet.x, y = bullet.y, w = bullet.size, h = bullet.size };
                SDL_RenderFillRect(renderer, &bullet_rect);
            }
        }

        if (m_current_state == .minigame)
        {
            SDL_FRect mg_panel = .() { x = 200, y = 230, w = 240, h = 110 };
            SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
            SDL_SetRenderDrawColor(renderer, 20, 20, 25, 230);
            SDL_RenderFillRect(renderer, &mg_panel);
            SDL_SetRenderDrawColor(renderer, 80, 80, 95, 255);
            SDL_RenderRect(renderer, &mg_panel);

            if (m_active_minigame != null)
            {
                m_active_minigame.draw(renderer, this);
            }
        }
    }

    public void cleanup()
    {
        logger.info("my_game is cleaning up!");
        if (m_soul_texture != null)
        {
            SDL_DestroyTexture(m_soul_texture);
            m_soul_texture = null;
        }

        delete m_player;
        delete m_enemy;
        delete m_active_minigame;
        delete m_active_pattern;
    }
}

class game_rand {
    private static uint32 s_seed = 12345;

    public static uint32 next() {
        s_seed = s_seed * 1664525 + 1013904223;
        return s_seed;
    }

    public static float next_float() {
        next();
        return (float)(s_seed & 0xFFFFFF) / 16777216.0f;
    }

    public static float next_range(float min, float max) {
        return min + next_float() * (max - min);
    }
}
