using System;
using engine.core;
using engine.diagnostics;
using SDL3;

namespace game;

class my_game : i_game_loop
{
    private character m_player = null;
    private character m_enemy = null;
    private combat_state m_current_state;

    private enemy_bullet m_test_bullet = .();
    private bool m_bullet_active = false;

    private float m_soul_x;
    private float m_soul_y;
    private float m_soul_size = 12.0f;
    private float m_soul_speed = 180.0f;
    private float m_soul_resistance = 1.0f;

    private float m_arena_x = 220.0f;
    private float m_arena_y = 80.0f;
    private float m_arena_w = 200.0f;
    private float m_arena_h = 200.0f;

    private int m_selected_action = 0;
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
    }

    public void update(float delta_time)
    {
        bool* keys = (bool*)SDL_GetKeyboardState(null);
        bool left_pressed = keys[(int32)SDL_Scancode.SDL_SCANCODE_LEFT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_A];
        bool right_pressed = keys[(int32)SDL_Scancode.SDL_SCANCODE_RIGHT] || keys[(int32)SDL_Scancode.SDL_SCANCODE_D];
        bool space_pressed = keys[(int32)SDL_Scancode.SDL_SCANCODE_SPACE];
        bool return_pressed = keys[(int32)SDL_Scancode.SDL_SCANCODE_RETURN];

        switch (m_current_state) {
            case .strategy:
                update_strategy(left_pressed, right_pressed, space_pressed);
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
            m_selected_action--;
            if (m_selected_action < 0) {
                m_selected_action = 3;
            }
            logger.info(scope $"Selected Action changed to: {m_selected_action}");
        }
        else if (right_pressed && !m_prev_right) {
            m_selected_action++;
            if (m_selected_action > 3) {
                m_selected_action = 0;
            }
            logger.info(scope $"Selected Action changed to: {m_selected_action}");
        }

        if (space_pressed && !m_prev_space) {
            execute_action();
            start_dodge_phase();
        }
    }

    private void execute_action()
    {
        switch (m_selected_action) {
            case 0:
                logger.info("Attack Action.");
                if (m_player.tp >= 20)
                {
                    m_enemy.take_damage(m_player.attack_power * 2);
                    m_player.tp -= 20;
                }
                break;
            case 1:
                logger.info("Item Action.");
                m_player.heal(20);
                break;
            case 2:
                logger.info("Defend Action.");
                m_soul_resistance -= 0.5f;
                m_player.tp += 50;
                if (m_soul_resistance < 0.1f)
                {
                    m_soul_resistance = 0.1f;
                }
                break;
            case 3:
                logger.info("Mercy Action.");
                m_enemy.mercy_bar += 10;
                if (m_enemy.mercy_bar > m_enemy.max_mercy_bar) {
                    m_enemy.mercy_bar = m_enemy.max_mercy_bar;
                }
                break;
        }
    }

    private void start_dodge_phase()
    {
        m_current_state = .dodging;
        logger.info("Dodge Phase.");
        
        m_soul_x = m_arena_x + (m_arena_w / 2) - (m_soul_size / 2);
        m_soul_y = m_arena_y + (m_arena_h / 2) - (m_soul_size / 2);

        m_test_bullet.x = m_enemy.x;
        m_test_bullet.y = m_enemy.y;
        m_test_bullet.speed_x = 300.0f; 
        m_bullet_active = true;
        logger.info(scope $"Bullet spawned: x={m_test_bullet.x}, y={m_test_bullet.y}, size={m_test_bullet.size}");
    }

    private void update_dodging(bool* keys, bool return_pressed, float delta_time)
    {
        if (return_pressed && !m_prev_return) {
            start_strategy_phase();
        }

        update_bullet(delta_time);
        update_soul_movement(keys, delta_time);
    }

    private void start_strategy_phase()
    {
        m_current_state = .strategy;
        logger.info("Strategy Phase.");
        m_bullet_active = false;
        m_soul_resistance = 1.0f;
    }

    private void update_bullet(float delta_time)
    {
        if (!m_bullet_active) return;

        m_test_bullet.x -= m_test_bullet.speed_x * delta_time;
        m_test_bullet.y -= m_test_bullet.speed_y * delta_time;

        if (m_soul_x < m_test_bullet.x + m_test_bullet.size &&
            m_soul_x + m_soul_size > m_test_bullet.x &&
            m_soul_y < m_test_bullet.y + m_test_bullet.size &&
            m_soul_y + m_soul_size > m_test_bullet.y) 
        {
            m_player.take_damage((int)(m_test_bullet.damage * m_soul_resistance));
            logger.info(scope $"The palyer took damage! Health: {m_player.health}");

            m_test_bullet.x = m_enemy.x;
            m_test_bullet.y = m_enemy.y;
        }

        if (m_test_bullet.x < m_arena_x) {
             m_test_bullet.x = m_enemy.x;
             m_test_bullet.y = m_enemy.y;
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
            logger.info("O jogador morreu! Reiniciando...");
            respawn_player();
        }
        
        if (m_enemy.is_dead())
        {
            logger.info("O inimigo foi derrotado! Próximo inimigo...");
            respawn_enemy();
        }
    }

    private void respawn_player()
    {
        m_player.reset_character(100.0f, 150.0f);
        start_strategy_phase();
    }

    private void respawn_enemy()
    {
        m_enemy.max_health += 10;
        m_enemy.attack_power += 2;
        m_enemy.reset_character(500.0f, 150.0f);
        start_strategy_phase();
    }

    private void desenhar_barra(SDL_Renderer* renderer, float x, float y, float val, float max_val, uint8 r, uint8 g, uint8 b)
    {
        float bar_width = 32;
        float bar_height = 10;
        float bar_w = val * bar_width / max_val;
        SDL_FRect max_bar = .() { x = x, y = y, w = bar_width, h = bar_height };
        SDL_FRect bar = .() { x = x, y = y, w = bar_w, h = bar_height };
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(renderer, &max_bar);
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        SDL_RenderFillRect(renderer, &bar);
    }

    private void desenhar_barras(SDL_Renderer* renderer, character c)
    {
        desenhar_barra(renderer, c.x, c.y - 15, c.health, c.max_health, 255, 0, 0);

        if (c == m_player)
        {
            desenhar_barra(renderer, c.x, c.y - 30, c.tp, c.max_tp, 255, 255, 0);
        }
        else
        {
            desenhar_barra(renderer, c.x, c.y - 30, c.stagger, c.max_stagger, 255, 255, 0);
            desenhar_barra(renderer, c.x, c.y - 45, c.mercy_bar, c.max_mercy_bar, 0, 0, 255);
        }
    }

    public void draw(SDL_Renderer* renderer, float alpha)
    {
        desenhar_barras(renderer, m_player);
        
        SDL_FRect player_rect = .() { x = m_player.x, y = m_player.y, w = m_player.width, h = m_player.height };
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(renderer, &player_rect);

        desenhar_barras(renderer, m_enemy);

        SDL_FRect enemy_rect = .() { x = m_enemy.x, y = m_enemy.y, w = m_enemy.width, h = m_enemy.height };
        SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
        SDL_RenderFillRect(renderer, &enemy_rect);

        if (m_current_state == .dodging) {
            SDL_FRect arena_rect = .() { x = m_arena_x, y = m_arena_y, w = m_arena_w, h = m_arena_h };
            SDL_SetRenderDrawColor(renderer, 50, 50, 50, 255); 
            SDL_RenderFillRect(renderer, &arena_rect);
            SDL_FRect soul_rect = .() { x = m_soul_x, y = m_soul_y, w = m_soul_size, h = m_soul_size };
            SDL_SetRenderDrawColor(renderer, 0, 255, 100, 255); 
            SDL_RenderFillRect(renderer, &soul_rect);

            if (m_bullet_active) {
                SDL_FRect bullet_rect = .() { x = m_test_bullet.x, y = m_test_bullet.y, w = m_test_bullet.size, h = m_test_bullet.size };
                SDL_SetRenderDrawColor(renderer, 255, 255, 0, 255); 
                SDL_RenderFillRect(renderer, &bullet_rect);
            }
        }
    }

    public void cleanup()
    {
        logger.info("my_game is cleaning up!");
        delete m_player;
        delete m_enemy;
    }
}
