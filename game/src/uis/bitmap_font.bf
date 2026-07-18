using System;
using System.Collections;
using SDL3;

namespace game;

class bitmap_font
{
    private static StringView MAP = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~º§";
    
    private static int32[97] X_MINS = .(0, 12, 10, 6, 9, 5, 7, 13, 11, 11, 8, 9, 13, 11, 13, 10, 9, 11, 9, 9, 9, 9, 8, 9, 9, 9, 13, 13, 9, 10, 9, 9, 5, 6, 8, 8, 8, 8, 9, 7, 7, 10, 9, 8, 9, 5, 7, 8, 8, 8, 8, 9, 8, 8, 8, 6, 7, 7, 8, 11, 10, 11, 9, 9, 12, 8, 8, 10, 8, 9, 10, 9, 9, 12, 11, 9, 12, 6, 8, 9, 8, 9, 9, 9, 10, 8, 8, 7, 8, 9, 9, 10, 13, 10, 7, 11, 9);
    private static int32[97] WIDTHS = .(8, 6, 10, 18, 12, 20, 16, 4, 8, 8, 14, 12, 4, 8, 4, 10, 12, 8, 12, 12, 12, 12, 14, 12, 12, 12, 4, 4, 12, 10, 12, 12, 20, 18, 14, 14, 14, 14, 12, 16, 16, 10, 12, 14, 12, 20, 16, 14, 14, 14, 14, 12, 14, 14, 14, 18, 16, 16, 14, 8, 10, 8, 12, 12, 6, 14, 14, 10, 14, 12, 10, 12, 12, 6, 8, 12, 6, 18, 14, 12, 14, 12, 12, 12, 10, 14, 14, 16, 14, 12, 12, 10, 4, 10, 16, 8, 12);
    private static Dictionary<String, SDL_Texture*> s_textures = new .();

    public static ~this()
    {
        for (var pair in s_textures)
        {
            SDL_DestroyTexture(pair.value);
            delete pair.key;
        }
        delete s_textures;
    }

    private static SDL_Texture* get_texture(SDL_Renderer* renderer, StringView font_name)
    {
        for (var pair in s_textures)
        {
            if (pair.key == font_name)
                return pair.value;
        }

        String path = scope .();
        path.AppendF("game/ast/fonts/{}.png", font_name);

        SDL_Texture* tex = SDL3_image.IMG_LoadTexture(renderer, path.CStr());
        if (tex != null)
        {
            s_textures[new String(font_name)] = tex;
        }
        return tex;
    }

    public static void draw_string(SDL_Renderer* renderer, float x, float y, StringView text, int32 size, StringView font_name = "grape_soda")
    {
        SDL_Texture* tex = get_texture(renderer, font_name);
        if (tex == null) return;
        
        uint8 r = 255, g = 255, b = 255, a = 255;
        SDL_GetRenderDrawColor(renderer, &r, &g, &b, &a);
        SDL_SetTextureColorMod(tex, r, g, b);
        SDL_SetTextureAlphaMod(tex, a);
        
        float scale = size / 32.0f;
        float cur_x = x;
        
        for (int i = 0; i < text.Length; i++)
        {
            char8 c = text[i];
            int index = MAP.IndexOf(c);
            if (index == -1)
            {
                index = 0;
            }
            
            int col = index % 20;
            int row = index / 20;
            
            float src_x = col * 32.0f + X_MINS[index];
            float src_y = row * 32.0f;
            float src_w = (float)WIDTHS[index];
            float src_h = 32.0f;
            
            SDL_FRect srcRect = .() {
                x = src_x,
                y = src_y,
                w = src_w,
                h = src_h
            };
            
            SDL_FRect dstRect = .() {
                x = cur_x,
                y = y,
                w = src_w * scale,
                h = size
            };
            
            if (WIDTHS[index] > 0)
            {
                SDL_RenderTexture(renderer, tex, &srcRect, &dstRect);
            }
            
            cur_x += (src_w + 2.0f) * scale;
        }
    }

    public static void draw_string_gradient(SDL_Renderer* renderer, float x, float y, StringView text, int32 size, SDL_FColor top_color, SDL_FColor bottom_color, StringView font_name = "grape_soda")
    {
        SDL_Texture* tex = get_texture(renderer, font_name);
        if (tex == null) return;
        
        SDL_SetTextureColorMod(tex, 255, 255, 255);
        SDL_SetTextureAlphaMod(tex, 255);
        
        float scale = size / 32.0f;
        float cur_x = x;
        
        for (int i = 0; i < text.Length; i++)
        {
            char8 c = text[i];
            int index = MAP.IndexOf(c);
            if (index == -1) index = 0;
            
            int col = index % 20;
            int row = index / 20;
            
            float src_x = col * 32.0f + X_MINS[index];
            float src_y = row * 32.0f;
            float src_w = (float)WIDTHS[index];
            float src_h = 32.0f;
            
            if (src_w > 0)
            {
                SDL_Vertex[4] vertices = .();
                vertices[0].position = .() { x = cur_x, y = y };
                vertices[0].color = top_color;
                vertices[0].tex_coord = .() { x = src_x / 640.0f, y = src_y / 160.0f };
                
                vertices[1].position = .() { x = cur_x + src_w * scale, y = y };
                vertices[1].color = top_color;
                vertices[1].tex_coord = .() { x = (src_x + src_w) / 640.0f, y = src_y / 160.0f };
                
                vertices[2].position = .() { x = cur_x + src_w * scale, y = y + size };
                vertices[2].color = bottom_color;
                vertices[2].tex_coord = .() { x = (src_x + src_w) / 640.0f, y = (src_y + src_h) / 160.0f };
                
                vertices[3].position = .() { x = cur_x, y = y + size };
                vertices[3].color = bottom_color;
                vertices[3].tex_coord = .() { x = src_x / 640.0f, y = (src_y + src_h) / 160.0f };
                
                int32[6] indices = .(0, 1, 2, 0, 2, 3);
                
                SDL_RenderGeometry(renderer, tex, &vertices[0], 4, &indices[0], 6);
            }
            
            cur_x += (src_w + 2.0f) * scale;
        }
    }

    public static float measure_string(StringView text, int32 size)
    {
        float scale = size / 32.0f;
        float width = 0;
        for (int i = 0; i < text.Length; i++)
        {
            char8 c = text[i];
            int index = MAP.IndexOf(c);
            if (index == -1) index = 0;
            width += ((float)WIDTHS[index] + 2.0f) * scale;
        }
        return width;
    }
}
