using System;
using System.Collections;
using SDL3;

namespace game;

class draw_utils
{
    private static float[24] s_cos_table;
    private static float[24] s_sin_table;
    private static bool s_tables_built = false;

    public static void set_color(SDL_Renderer* renderer, uint8[4] color)
    {
        SDL_SetRenderDrawColor(renderer, color[0], color[1], color[2], color[3]);
    }

    public static void set_color(SDL_Renderer* renderer, uint8[4] color, uint8 alpha)
    {
        SDL_SetRenderDrawColor(renderer, color[0], color[1], color[2], alpha);
    }

    private static void build_circle_tables()
    {
        if (s_tables_built) return;
        for (int i = 0; i < 24; i++)
        {
            float angle = ((i + 1) * 2.0f * 3.14159265f) / 24.0f;
            s_cos_table[i] = (float)Math.Cos(angle);
            s_sin_table[i] = (float)Math.Sin(angle);
        }
        s_tables_built = true;
    }

    public static void draw_circle_outline(SDL_Renderer* renderer, float cx, float cy, float radius, uint8 r, uint8 g, uint8 b, uint8 a)
    {
        build_circle_tables();
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, r, g, b, a);
        float prev_x = cx + radius;
        float prev_y = cy;
        for (int i = 0; i < 24; i++)
        {
            float curr_x = cx + s_cos_table[i] * radius;
            float curr_y = cy + s_sin_table[i] * radius;
            SDL_RenderLine(renderer, prev_x, prev_y, curr_x, curr_y);
            prev_x = curr_x;
            prev_y = curr_y;
        }
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    public static void draw_circle_filled(SDL_Renderer* renderer, float cx, float cy, float radius, uint8 r, uint8 g, uint8 b, uint8 a)
    {
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, r, g, b, a);
        int r_int = (int)radius;
        int r2 = r_int * r_int;
        int x = r_int;

        for (int y = 0; y <= r_int; y++)
        {
            while (x * x + y * y > r2 && x > 0)
            {
                x--;
            }
            SDL_RenderLine(renderer, cx - x, cy + y, cx + x, cy + y);
            if (y != 0)
            {
                SDL_RenderLine(renderer, cx - x, cy - y, cx + x, cy - y);
            }
        }
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }

    public static void draw_bar(SDL_Renderer* renderer, float x, float y, float val, float max_val, uint8 r, uint8 g, uint8 b)
    {
        float bar_width = 32;
        float bar_height = 4;
        float bar_w = val * bar_width / max_val;
        if (bar_w < 0.0f) bar_w = 0.0f;
        if (bar_w > bar_width) bar_w = bar_width;

        SDL_FRect max_bar = .() { x = x, y = y, w = bar_width, h = bar_height };
        SDL_FRect bar = .() { x = x, y = y, w = bar_w, h = bar_height };

        set_color(renderer, colors.DARK_BG_ALT);
        SDL_RenderFillRect(renderer, &max_bar);
        SDL_SetRenderDrawColor(renderer, r, g, b, 255);
        SDL_RenderFillRect(renderer, &bar);
        set_color(renderer, colors.PANEL_BORDER_DARK);
        SDL_RenderRect(renderer, &max_bar);
    }

    public static void draw_filled_polygon(SDL_Renderer* renderer, List<Vector2> vertices, uint8 r, uint8 g, uint8 b, uint8 a)
    {
        if (vertices.Count < 3) return;

        SDL_Vertex[] sdl_vertices = scope SDL_Vertex[vertices.Count];
        SDL_FColor col = .() { r = r / 255.0f, g = g / 255.0f, b = b / 255.0f, a = a / 255.0f };

        for (int i = 0; i < vertices.Count; i++)
        {
            sdl_vertices[i] = .() {
                position = .() { x = vertices[i].x, y = vertices[i].y },
                color = col,
                tex_coord = .() { x = 0.0f, y = 0.0f }
            };
        }

        int num_indices = (vertices.Count - 2) * 3;
        int32[] indices = scope int32[num_indices];
        int idx = 0;
        for (int i = 1; i < vertices.Count - 1; i++)
        {
            indices[idx++] = 0;
            indices[idx++] = (int32)i;
            indices[idx++] = (int32)(i + 1);
        }

        SDL_RenderGeometry(renderer, null, sdl_vertices.Ptr, (int32)vertices.Count, indices.Ptr, (int32)num_indices);
    }

    public static void draw_polygon_outline(SDL_Renderer* renderer, List<Vector2> vertices, uint8 r, uint8 g, uint8 b, uint8 a)
    {
        if (vertices.Count < 2) return;
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_BLEND);
        SDL_SetRenderDrawColor(renderer, r, g, b, a);
        for (int i = 0; i < vertices.Count; i++)
        {
            Vector2 p1 = vertices[i];
            Vector2 p2 = vertices[(i + 1) % vertices.Count];
            SDL_RenderLine(renderer, p1.x, p1.y, p2.x, p2.y);
        }
        SDL_SetRenderDrawBlendMode(renderer, SDL_BlendMode.SDL_BLENDMODE_NONE);
    }
}
