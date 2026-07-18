using System;
using System.Collections;
using SDL3;

namespace game;

class hud_renderer
{
    public static void draw_character_bars(SDL_Renderer* renderer, character c, bool is_party, combat_state state, int actions_left, int max_actions, float game_time)
    {
        if (is_party)
        {
            draw_utils.draw_bar(renderer, c.x, c.y - 12, c.width, c.health, c.max_health, colors.GREEN[0], colors.GREEN[1], colors.GREEN[2]);
            draw_utils.draw_bar(renderer, c.x, c.y - 20, c.width, c.tp, c.max_tp, colors.GOLD[0], colors.GOLD[1], colors.GOLD[2]);

            if (state == .strategy || state == .selecting_minigame || state == .selecting_defense || state == .minigame)
            {
                float cx = c.x + c.width / 2.0f;
                float h = 6.0f;
                float w = 8.0f;
                float bounce = (float)Math.Sin(game_time * 8.0f) * 2.0f;
                float target_cy = c.y - 26.0f - h + bounce;

                if (max_actions == 1)
                {
                    bool active = actions_left > 0;
                    draw_inverted_triangle(renderer, cx, target_cy, w, h, active, 46, 204, 113, 255);
                }
                else if (max_actions == 2)
                {
                    float offset = 6.0f;
                    
                    bool active1 = actions_left > 0;
                    draw_inverted_triangle(renderer, cx - offset, target_cy, w, h, active1, 46, 204, 113, 255);

                    bool active2 = actions_left > 1;
                    draw_inverted_triangle(renderer, cx + offset, target_cy, w, h, active2, 46, 204, 113, 255);
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

            if (state == .dodging)
            {
                float cx = c.x + c.width / 2.0f;
                float h = 6.0f;
                float w = 8.0f;
                float bounce = (float)Math.Sin(game_time * 8.0f) * 2.0f;
                float target_cy = c.y - 34.0f - h + bounce;

                draw_inverted_triangle(renderer, cx, target_cy, w, h, true, 231, 76, 60, 255);
            }
        }
    }

    private static void draw_inverted_triangle(SDL_Renderer* renderer, float cx, float cy, float w, float h, bool active, uint8 r, uint8 g, uint8 b, uint8 a)
    {
        List<Vector2> vertices = scope .();
        vertices.Add(.(cx - w / 2.0f, cy));
        vertices.Add(.(cx + w / 2.0f, cy));
        vertices.Add(.(cx, cy + h));

        if (active)
        {
            draw_utils.draw_filled_polygon(renderer, vertices, r, g, b, a);
            draw_utils.draw_polygon_outline(renderer, vertices, (uint8)(r * 0.8f), (uint8)(g * 0.8f), (uint8)(b * 0.8f), a);
        }
        else
        {
            draw_utils.draw_polygon_outline(renderer, vertices, 140, 140, 155, 180);
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

        float txt_w = bitmap_font.measure_string(action_str, 16);
        float txt_x = 49.0f - (txt_w / 2.0f);

        draw_utils.set_color(renderer, colors.GOLD);
        bitmap_font.draw_string(renderer, txt_x, 341 - 4, action_str, 16);
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
        float title_w = bitmap_font.measure_string(title, 16);
        draw_utils.set_color(renderer, colors.TEXT_DEFAULT);
        bitmap_font.draw_string(renderer, center_x - title_w / 2.0f, panel_y + 8 - 4, title, 16);

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
        bitmap_font.draw_string(renderer, panel_x + 12, panel_y + 42 - 3, "<", 16);
        bitmap_font.draw_string(renderer, panel_x + panel_w - 24, panel_y + 42 - 3, ">", 16);

        StringView name = selected.Name;
        float name_w = bitmap_font.measure_string(name, 16);
        draw_utils.set_color(renderer, colors.GOLD);
        bitmap_font.draw_string(renderer, center_x - name_w / 2.0f, panel_y + 38 - 3, name, 16);

        StringView cost_str = selected.CostStr;
        bool can_afford = player_tp >= selected.TpCost;
        float cost_w = bitmap_font.measure_string(cost_str, 16);
        if (can_afford)
            draw_utils.set_color(renderer, colors.GREEN);
        else
            draw_utils.set_color(renderer, colors.RED);
        bitmap_font.draw_string(renderer, center_x - cost_w / 2.0f, panel_y + 60 - 4, cost_str, 16);

        StringView diff_str = selected.Difficulty;
        float diff_w = bitmap_font.measure_string(diff_str, 16);
        draw_utils.set_color(renderer, colors.TEXT_MUTED);
        bitmap_font.draw_string(renderer, center_x - diff_w / 2.0f, panel_y + 76 - 4, diff_str, 16);

        StringView mult_hint = selected.MultHint;
        float mult_w = bitmap_font.measure_string(mult_hint, 16);
        draw_utils.set_color(renderer, colors.TEXT_DARK);
        bitmap_font.draw_string(renderer, center_x - mult_w / 2.0f, panel_y + 94 - 5, mult_hint, 16);

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
        float title_w = bitmap_font.measure_string(title, 16);
        draw_utils.set_color(renderer, colors.TEXT_DEFAULT);
        bitmap_font.draw_string(renderer, center_x - title_w / 2.0f, panel_y + 8 - 4, title, 16);

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
        bitmap_font.draw_string(renderer, panel_x + 12, panel_y + 42 - 3, "<", 16);
        bitmap_font.draw_string(renderer, panel_x + panel_w - 24, panel_y + 42 - 3, ">", 16);

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

        float name_w = bitmap_font.measure_string(name, 16);
        draw_utils.set_color(renderer, colors.GOLD);
        bitmap_font.draw_string(renderer, center_x - name_w / 2.0f, panel_y + 38 - 3, name, 16);

        StringView tp_str = "16 TP";
        float tp_w = bitmap_font.measure_string(tp_str, 16);
        draw_utils.set_color(renderer, colors.GREEN);
        bitmap_font.draw_string(renderer, center_x - tp_w / 2.0f, panel_y + 60 - 4, tp_str, 16);

        float desc_w = bitmap_font.measure_string(desc_str, 16);
        draw_utils.set_color(renderer, colors.TEXT_MUTED);
        bitmap_font.draw_string(renderer, center_x - desc_w / 2.0f, panel_y + 78 - 4, desc_str, 16);

        float benefit_w = bitmap_font.measure_string(benefit_str, 16);
        draw_utils.set_color(renderer, colors.TEXT_DARK);
        bitmap_font.draw_string(renderer, center_x - benefit_w / 2.0f, panel_y + 94 - 5, benefit_str, 16);

        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }
}
