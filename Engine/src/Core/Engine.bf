using SDL3;
using System;

namespace Engine.Core;

public class engine_core
{
    private SDL3.SDL_Window* m_window = null;
    private SDL3.SDL_Renderer* m_renderer = null;
    private bool m_is_running = false;
    private i_game_loop m_game_instance = null;

    public this(i_game_loop game_instance)
    {
        m_game_instance = game_instance;
    }

    public ~this()
    {
        shutdown();
    }

    public Result<void> initialize(StringView title, int width, int height)
    {
        logger.info("Initializing SDL3...");
        if (!SDL3.SDL_Init(.SDL_INIT_VIDEO | .SDL_INIT_EVENTS))
        {
            logger.error(scope $"SDL could not initialize! SDL_Error: {StringView(SDL3.SDL_GetError())}");
            return .Err;
        }

        logger.info(scope $"Creating window '{title}' ({width}x{height})...");
        m_window = SDL3.SDL_CreateWindow(
            title.ToScopeCStr!(),
            (int32)width,
            (int32)height,
            .SDL_WINDOW_RESIZABLE
        );

        if (m_window == null)
        {
            logger.error(scope $"Window could not be created! SDL_Error: {StringView(SDL3.SDL_GetError())}");
            return .Err;
        }

        SDL3.SDL_SetWindowAspectRatio(m_window, 16.0f / 9.0f, 16.0f / 9.0f);

        m_renderer = SDL3.SDL_CreateRenderer(m_window, null);
        if (m_renderer == null)
        {
            logger.error(scope $"Renderer could not be created! SDL_Error: {StringView(SDL3.SDL_GetError())}");
            return .Err;
        }

        if (!SDL3.SDL_SetRenderVSync(m_renderer, 1))
        {
            logger.warn(scope $"Could not set VSync! SDL_Error: {StringView(SDL3.SDL_GetError())}");
        }

        if (!SDL3.SDL_SetRenderLogicalPresentation(m_renderer, (int32)width, (int32)height, .SDL_LOGICAL_PRESENTATION_LETTERBOX))
        {
            logger.warn(scope $"Could not set logical presentation! SDL_Error: {StringView(SDL3.SDL_GetError())}");
        }

        if (!SDL3.SDL_SetDefaultTextureScaleMode(m_renderer, .SDL_SCALEMODE_NEAREST))
        {
            logger.warn(scope $"Could not set default texture scale mode! SDL_Error: {StringView(SDL3.SDL_GetError())}");
        }

        m_is_running = true;
        if (m_game_instance != null)
        {
            m_game_instance.initialize();
        }

        return .Ok;
    }

    public void run()
    {
        logger.info("Starting game loop...");
        SDL3.SDL_Event event = .();

        const float delta_time = 1.0f / 60.0f; 
        uint64 old_time = SDL3.SDL_GetTicks();
        double accumulator = 0.0;

        while (m_is_running)
        {
            uint64 current_time = SDL3.SDL_GetTicks();
            double frame_time = (current_time - old_time) / 1000.0;
            old_time = current_time;
            
            if (frame_time > 0.25)
            {
                frame_time = 0.25;
            }
            
            accumulator += frame_time;
            
            while (SDL3.SDL_PollEvent(&event))
            {
                if ((SDL3.SDL_EventType)event.type == .SDL_EVENT_QUIT)
                {
                    m_is_running = false;
                }
            }
            
            while (accumulator >= delta_time)
            {
                if (m_game_instance != null)
                {
                    m_game_instance.update(delta_time);
                }
                accumulator -= delta_time;
            }
            
            float alpha = (float)(accumulator / delta_time);

            SDL3.SDL_SetRenderDrawColor(m_renderer, 255, 255, 255, 255);
            SDL3.SDL_RenderClear(m_renderer);

            if (m_game_instance != null)
            {
                m_game_instance.draw(alpha);
            }

            SDL3.SDL_RenderPresent(m_renderer);
        }
    }

    public void shutdown()
    {
        logger.info("Shutting down engine...");
        if (m_game_instance != null)
        {
            m_game_instance.cleanup();
            m_game_instance = null;
        }

        if (m_renderer != null)
        {
            SDL3.SDL_DestroyRenderer(m_renderer);
            m_renderer = null;
        }

        if (m_window != null)
        {
            SDL3.SDL_DestroyWindow(m_window);
            m_window = null;
        }

        SDL3.SDL_Quit();
    }
}
