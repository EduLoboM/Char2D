using System;
using Engine.Core;

namespace Game;

class my_game : i_game_loop
{
    public void initialize()
    {
        logger.info("my_game has initialized!");
    }

    public void update(float delta_time)
    {
        
    }

    public void draw()
    {
        
    }

    public void cleanup()
    {
        logger.info("my_game is cleaning up!");
    }
}

class program
{
    public static int Main(String[] args)
    {
        my_game game = scope my_game();
        engine_core engine = scope engine_core(game);

        if (engine.initialize("Char2D Game Window", 800, 600) case .Err)
        {
            logger.error("Failed to initialize engine.");
            return 1;
        }

        engine.run();
        return 0;
    }
}
