using System;
using SDL3;

namespace game;

class SpriteAnimation
{
    public SDL_Texture* Texture;

    public int FrameWidth;
    public int FrameHeight;

    public int CurrentFrame = 0;

    public this(SDL_Texture* texture, int frameWidth, int frameHeight)
    {
        this.Texture = texture;
        this.FrameWidth = frameWidth;
        this.FrameHeight = frameHeight;
    }

    public void Draw(SDL_Renderer* renderer, float screenX, float screenY)
    {
        SDL_FRect srcRect = .() {
            x = CurrentFrame * FrameWidth,
            y = 0,
            w = FrameWidth,
            h = FrameHeight
        };

        SDL_FRect dstRect = .() {
            x = screenX,
            y = screenY,
            w = FrameWidth,
            h = FrameHeight
        };

        SDL_RenderTexture(renderer, Texture, &srcRect, &dstRect);
    }
}
