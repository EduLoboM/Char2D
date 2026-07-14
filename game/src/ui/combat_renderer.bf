using System;
using SDL3;

namespace game;

class combat_renderer
{
    public static void draw_character_bars(SDL_Renderer* renderer, character c, bool is_party, combat_state state, int actions_left, float game_time)
    {
        hud_renderer.draw_character_bars(renderer, c, is_party, state, actions_left, game_time);
    }

    public static void draw_character_sprite(SDL_Renderer* renderer, character c, texture_cache textures)
    {
        arena_renderer.draw_character_sprite(renderer, c, textures);
    }

    public static void draw_action_panel(SDL_Renderer* renderer, ActionType selected_action)
    {
        hud_renderer.draw_action_panel(renderer, selected_action);
    }

    public static void draw_arena(SDL_Renderer* renderer, my_game game, texture_cache textures)
    {
        arena_renderer.draw_arena(renderer, game, textures);
    }

    public static void draw_bullet(SDL_Renderer* renderer, ref enemy_bullet bullet, float game_time)
    {
        arena_renderer.draw_bullet(renderer, ref bullet, game_time);
    }

    public static void draw_minigame_panel(SDL_Renderer* renderer, attack_minigame minigame, my_game game)
    {
        hud_renderer.draw_minigame_panel(renderer, minigame, game);
    }

    public static void draw_minigame_selection(SDL_Renderer* renderer, MinigameType selected, int player_tp)
    {
        hud_renderer.draw_minigame_selection(renderer, selected, player_tp);
    }
}
