using System;
using SDL3;

namespace game;

class pixel_font
{
    public static void draw_pixel_char(SDL_Renderer* renderer, float x, float y, char8 c, float scale)
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
            case '<': glyph = 0b0010001100111110110000100; break;
            case '>': glyph = 0b0010000110111110011000100; break;
            case '-': glyph = 0b0000000000111110000000000; break;
            case '^': glyph = 0b0010001110111110010000100; break;
            case 'v': glyph = 0b0010000100111110111000100; break;
            case 'h': glyph = 0b0101011111111110111000100; break;
            case 'd': glyph = 0b0010001110111110111000100; break;
            case 'c': glyph = 0b0010001110111110010001110; break;
            case 's': glyph = 0b0010001110111111101100100; break;
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

    public static void draw_pixel_string(SDL_Renderer* renderer, float x, float y, StringView text, float scale)
    {
        float cur_x = x;
        for (int i = 0; i < text.Length; i++)
        {
            draw_pixel_char(renderer, cur_x, y, text[i], scale);
            cur_x += 6.0f * scale;
        }
    }
}
