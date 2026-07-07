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
    private float m_arena_x = 220.0f;
    private float m_arena_y = 80.0f;
    private float m_arena_w = 200.0f;
    private float m_arena_h = 200.0f;

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

        switch (m_current_state) {
            case .strategy:
                if (keys[(int32)SDL_Scancode.SDL_SCANCODE_SPACE]) {
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
                break;
                
            case .dodging:
                if (keys[(int32)SDL_Scancode.SDL_SCANCODE_RETURN]) {
                    m_current_state = .strategy;
                    logger.info("Strategy Phase.");
                    m_bullet_active = false;
                }

                if (m_bullet_active) {
                    m_test_bullet.x -= m_test_bullet.speed_x * delta_time;
                    m_test_bullet.y -= m_test_bullet.speed_y * delta_time;

                    if (m_soul_x < m_test_bullet.x + m_test_bullet.size &&
                        m_soul_x + m_soul_size > m_test_bullet.x &&
                        m_soul_y < m_test_bullet.y + m_test_bullet.size &&
                        m_soul_y + m_soul_size > m_test_bullet.y) 
                    {
                        m_player.take_damage(m_test_bullet.damage);
                        logger.info(scope $"The palyer took damage! Health: {m_player.health}");

                        m_test_bullet.x = m_enemy.x;
                        m_test_bullet.y = m_enemy.y;
                    }

                    if (m_test_bullet.x < m_arena_x) {
                         m_test_bullet.x = m_enemy.x;
                         m_test_bullet.y = m_enemy.y;
                    }
                }

                if (keys[(int32)SDL_Scancode.SDL_SCANCODE_W] || keys[(int32)SDL_Scancode.SDL_SCANCODE_UP]) m_soul_y -= m_soul_speed * delta_time;
                if (keys[(int32)SDL_Scancode.SDL_SCANCODE_S] || keys[(int32)SDL_Scancode.SDL_SCANCODE_DOWN]) m_soul_y += m_soul_speed * delta_time;
                if (keys[(int32)SDL_Scancode.SDL_SCANCODE_A] || keys[(int32)SDL_Scancode.SDL_SCANCODE_LEFT]) m_soul_x -= m_soul_speed * delta_time;
                if (keys[(int32)SDL_Scancode.SDL_SCANCODE_D] || keys[(int32)SDL_Scancode.SDL_SCANCODE_RIGHT]) m_soul_x += m_soul_speed * delta_time;

                if (m_soul_x < m_arena_x) m_soul_x = m_arena_x;
                if (m_soul_y < m_arena_y) m_soul_y = m_arena_y;
                if (m_soul_x > m_arena_x + m_arena_w - m_soul_size) m_soul_x = m_arena_x + m_arena_w - m_soul_size;
                if (m_soul_y > m_arena_y + m_arena_h - m_soul_size) m_soul_y = m_arena_y + m_arena_h - m_soul_size;
                
                break;
        }
    }

    public void draw(SDL_Renderer* renderer, float alpha)
    {
        SDL_FRect player_rect = .() { x = m_player.x, y = m_player.y, w = m_player.width, h = m_player.height };
        SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255);
        SDL_RenderFillRect(renderer, &player_rect);

        SDL_FRect enemy_rect = .() { x = m_enemy.x, y = m_enemy.y, w = m_enemy.width, h = m_enemy.height };
        SDL_SetRenderDrawColor(renderer, 255, 0, 0, 255);
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
