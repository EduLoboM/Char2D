using System;
using SDL3;

namespace game;

class hud_renderer
{
    public static void draw_character_bars(SDL_Renderer* renderer, character c, bool is_party, combat_state state, int actions_left, float game_time)
    {
        if (is_party)
        {
            draw_utils.draw_bar(renderer, c.x, c.y - 12, c.width, c.health, c.max_health, colors.GREEN[0], colors.GREEN[1], colors.GREEN[2]);
            draw_utils.draw_bar(renderer, c.x, c.y - 20, c.width, c.tp, c.max_tp, colors.GOLD[0], colors.GOLD[1], colors.GOLD[2]);

            if (state == .strategy)
            {
                float total_dots_w = (actions_left - 1) * 8.0f + 4.0f;
                float start_x = c.x + (c.width - total_dots_w) / 2.0f;
                for (int i = 0; i < actions_left; i++)
                {
                    SDL_FRect dot = .() { x = start_x + i * 8.0f, y = c.y - 28, w = 4, h = 4 };
                    draw_utils.set_color(renderer, colors.GREEN);
                    SDL_RenderFillRect(renderer, &dot);
                }
            }
        }
        else
        {
            draw_utils.draw_bar(renderer, c.x, c.y - 12, c.width, c.health, c.max_health, colors.RED[0], colors.RED[1], colors.RED[2]);

            uint8 sr = 255, sg = 255, sb = 255;
            if (c.is_staggered())
            {
                sr = (uint8)((Math.Sin(game_time * 4.0f) * 0.5f + 0.5f) * 200 + 55);
                sg = (uint8)((Math.Sin(game_time * 4.0f + 2.094f) * 0.5f + 0.5f) * 200 + 55);
                sb = (uint8)((Math.Sin(game_time * 4.0f + 4.188f) * 0.5f + 0.5f) * 200 + 55);
            }
            draw_utils.draw_bar(renderer, c.x, c.y - 20, c.width, c.stagger, c.max_stagger, sr, sg, sb);
            draw_utils.draw_bar(renderer, c.x, c.y - 28, c.width, c.mercy_bar, c.max_mercy_bar, colors.BLUE[0], colors.BLUE[1], colors.BLUE[2]);
        }
    }

    public static void draw_action_panel(SDL_Renderer* renderer, ActionType selected_action)
    {
        SDL_FRect bg = .() { x = layout.ACTION_PANEL_X, y = layout.ACTION_PANEL_Y, w = layout.ACTION_PANEL_W, h = layout.ACTION_PANEL_H };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        draw_utils.set_color(renderer, colors.DARK_BG, 180);
        SDL_RenderFillRect(renderer, &bg);
        draw_utils.set_color(renderer, colors.PANEL_BORDER);
        SDL_RenderRect(renderer, &bg);

        StringView action_str = "";
        switch (selected_action)
        {
            case .Fight: action_str = "FIGHT"; break;
            case .Item: action_str = "ITEM"; break;
            case .Defend: action_str = "DEFEND"; break;
            case .Mercy: action_str = "MERCY"; break;
        }

        float txt_w = action_str.Length * 9.0f;
        float txt_x = 49.0f - (txt_w / 2.0f);

        draw_utils.set_color(renderer, colors.GOLD);
        pixel_font.draw_pixel_string(renderer, txt_x, 341, action_str, 1.5f);
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    public static void draw_minigame_panel(SDL_Renderer* renderer, attack_minigame minigame, my_game game)
    {
        SDL_FRect mg_panel = .() { x = layout.MINIGAME_PANEL_X, y = layout.MINIGAME_PANEL_Y, w = layout.MINIGAME_PANEL_W, h = layout.MINIGAME_PANEL_H };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        draw_utils.set_color(renderer, colors.DARK_BG, 230);
        SDL_RenderFillRect(renderer, &mg_panel);
        draw_utils.set_color(renderer, colors.PANEL_BORDER_ALT);
        SDL_RenderRect(renderer, &mg_panel);

        if (minigame != null)
            minigame.draw(renderer, game);
    }

    public static void draw_minigame_selection(SDL_Renderer* renderer, MinigameType selected, int player_tp)
    {
        float panel_x = layout.MG_SELECT_X;
        float panel_y = layout.MG_SELECT_Y;
        float panel_w = layout.MG_SELECT_W;
        float panel_h = layout.MG_SELECT_H;
        float center_x = panel_x + panel_w / 2.0f;

        SDL_FRect mg_panel = .() { x = panel_x, y = panel_y, w = panel_w, h = panel_h };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        draw_utils.set_color(renderer, colors.DARK_BG, 230);
        SDL_RenderFillRect(renderer, &mg_panel);
        draw_utils.set_color(renderer, colors.PANEL_BORDER_ALT);
        SDL_RenderRect(renderer, &mg_panel);

        StringView title = "SELECT ATTACK";
        float title_w = title.Length * 9.0f;
        draw_utils.set_color(renderer, colors.TEXT_DEFAULT);
        pixel_font.draw_pixel_string(renderer, center_x - title_w / 2.0f, panel_y + 8, title, 1.5f);

        float dot_y = panel_y + 26;
        float dot_total_w = 5 * 4 + 4 * 8;
        float dot_start_x = center_x - dot_total_w / 2.0f;
        for (int i = 0; i < 5; i++)
        {
            float dx = dot_start_x + i * 12;
            SDL_FRect dot = .() { x = dx, y = dot_y, w = 4, h = 4 };
            if (i == (int)selected)
            {
                draw_utils.set_color(renderer, colors.GOLD);
                SDL_RenderFillRect(renderer, &dot);
            }
            else
            {
                draw_utils.set_color(renderer, colors.PANEL_BORDER);
                SDL_RenderRect(renderer, &dot);
            }
        }

        draw_utils.set_color(renderer, colors.GOLD);
        pixel_font.draw_pixel_string(renderer, panel_x + 12, panel_y + 42, "<", 2.0f);
        pixel_font.draw_pixel_string(renderer, panel_x + panel_w - 24, panel_y + 42, ">", 2.0f);

        StringView name = selected.Name;
        float name_w = name.Length * 12.0f;
        draw_utils.set_color(renderer, colors.GOLD);
        pixel_font.draw_pixel_string(renderer, center_x - name_w / 2.0f, panel_y + 38, name, 2.0f);

        StringView cost_str = selected.CostStr;
        bool can_afford = player_tp >= selected.TpCost;
        float cost_w = cost_str.Length * 9.0f;
        if (can_afford)
            draw_utils.set_color(renderer, colors.GREEN);
        else
            draw_utils.set_color(renderer, colors.RED);
        pixel_font.draw_pixel_string(renderer, center_x - cost_w / 2.0f, panel_y + 60, cost_str, 1.5f);

        StringView diff_str = selected.Difficulty;
        float diff_w = diff_str.Length * 9.0f;
        draw_utils.set_color(renderer, colors.TEXT_MUTED);
        pixel_font.draw_pixel_string(renderer, center_x - diff_w / 2.0f, panel_y + 76, diff_str, 1.5f);

        StringView mult_hint = selected.MultHint;
        float mult_w = mult_hint.Length * 6.0f;
        draw_utils.set_color(renderer, colors.TEXT_DARK);
        pixel_font.draw_pixel_string(renderer, center_x - mult_w / 2.0f, panel_y + 94, mult_hint, 1.0f);

        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    public static void draw_defense_selection(SDL_Renderer* renderer, DefenseType selected)
    {
        float panel_x = layout.MG_SELECT_X;
        float panel_y = layout.MG_SELECT_Y;
        float panel_w = layout.MG_SELECT_W;
        float panel_h = layout.MG_SELECT_H;
        float center_x = panel_x + panel_w / 2.0f;

        SDL_FRect def_panel = .() { x = panel_x, y = panel_y, w = panel_w, h = panel_h };
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        draw_utils.set_color(renderer, colors.DARK_BG, 230);
        SDL_RenderFillRect(renderer, &def_panel);
        draw_utils.set_color(renderer, colors.PANEL_BORDER_ALT);
        SDL_RenderRect(renderer, &def_panel);

        StringView title = "SELECT DEFENSE";
        float title_w = title.Length * 9.0f;
        draw_utils.set_color(renderer, colors.TEXT_DEFAULT);
        pixel_font.draw_pixel_string(renderer, center_x - title_w / 2.0f, panel_y + 8, title, 1.5f);

        float dot_y = panel_y + 26;
        float dot_total_w = 3 * 4 + 2 * 8;
        float dot_start_x = center_x - dot_total_w / 2.0f;
        for (int i = 0; i < 3; i++)
        {
            float dx = dot_start_x + i * 12;
            SDL_FRect dot = .() { x = dx, y = dot_y, w = 4, h = 4 };
            if (i == (int)selected)
            {
                draw_utils.set_color(renderer, colors.GOLD);
                SDL_RenderFillRect(renderer, &dot);
            }
            else
            {
                draw_utils.set_color(renderer, colors.PANEL_BORDER);
                SDL_RenderRect(renderer, &dot);
            }
        }

        draw_utils.set_color(renderer, colors.GOLD);
        pixel_font.draw_pixel_string(renderer, panel_x + 12, panel_y + 42, "<", 2.0f);
        pixel_font.draw_pixel_string(renderer, panel_x + panel_w - 24, panel_y + 42, ">", 2.0f);

        StringView name = "";
        StringView desc_str = "";
        StringView benefit_str = "";

        switch (selected)
        {
            case .Evade:
                name = "EVADE";
                desc_str = "20% TO TAKE 0 DAMAGE";
                benefit_str = "TAKE 0 DMG: 20%";
            case .Guard:
                name = "GUARD";
                desc_str = "FLAT 50% DAMAGE REDUCTION";
                benefit_str = "DAMAGE TAKEN: -50%";
            case .Counter:
                name = "COUNTER";
                desc_str = "RETURN 50% OF DAMAGE TAKEN";
                benefit_str = "RETURN 50% DMG ON HIT";
        }

        float name_w = name.Length * 12.0f;
        draw_utils.set_color(renderer, colors.GOLD);
        pixel_font.draw_pixel_string(renderer, center_x - name_w / 2.0f, panel_y + 38, name, 2.0f);

        StringView tp_str = "16 TP";
        float tp_w = tp_str.Length * 9.0f;
        draw_utils.set_color(renderer, colors.GREEN);
        pixel_font.draw_pixel_string(renderer, center_x - tp_w / 2.0f, panel_y + 60, tp_str, 1.5f);

        float desc_w = desc_str.Length * 9.0f;
        draw_utils.set_color(renderer, colors.TEXT_MUTED);
        pixel_font.draw_pixel_string(renderer, center_x - desc_w / 2.0f, panel_y + 78, desc_str, 1.5f);

        float benefit_w = benefit_str.Length * 6.0f;
        draw_utils.set_color(renderer, colors.TEXT_DARK);
        pixel_font.draw_pixel_string(renderer, center_x - benefit_w / 2.0f, panel_y + 94, benefit_str, 1.0f);

        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }
}
