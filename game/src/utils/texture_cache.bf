using System;
using System.Collections;
using engine.diagnostics;
using SDL3;
using SDL3_image;

namespace game;

class texture_cache
{
    private Dictionary<String, SDL_Texture*> m_cache = new .() ~ delete _;

    private static StringView[?] s_prefixes = .("", "game/", "../", "../game/");

    private SDL_Texture* try_load(SDL_Renderer* renderer, StringView prefix, StringView path, String buffer)
    {
        buffer.Clear();
        buffer.Append(prefix);
        buffer.Append(path);
        buffer.Ptr[buffer.Length] = 0;

        SDL_Texture* tex = IMG_LoadTexture(renderer, buffer.Ptr);
        if (tex != null)
        {
            logger.load(scope $"Loaded texture from path: {buffer}");
            String stored_key = new String(buffer);
            m_cache.Add(stored_key, tex);
            return tex;
        }
        return null;
    }

    public SDL_Texture* get(SDL_Renderer* renderer, StringView path)
    {
        String key = scope String(path);
        SDL_Texture* cached = null;
        if (m_cache.TryGetValue(key, out cached))
            return cached;

        String buffer = scope String(256);

        for (var prefix in s_prefixes)
        {
            if (SDL_Texture* tex = try_load(renderer, prefix, path, buffer))
                return tex;
        }

        if (path.StartsWith("game/"))
        {
            StringView sub = path.Substring(5);
            StringView[?] sub_prefixes = .("", "../");
            for (var prefix in sub_prefixes)
            {
                if (SDL_Texture* tex = try_load(renderer, prefix, sub, buffer))
                    return tex;
            }
        }

        logger.error(scope $"Failed to load texture: {path}");
        return null;
    }

    public void cleanup()
    {
        for (var kv in m_cache)
        {
            SDL_DestroyTexture(kv.value);
            delete kv.key;
        }
        m_cache.Clear();
    }
}
