using System;
using engine.core;
using engine.diagnostics;

namespace game;

class program
{
    public static int Main(String[] args)
    {
        my_game game = scope my_game();
        engine_core engine = scope engine_core(game);

        if (engine.initialize("Char2D Game Window", 640, 360) case .Err)
        {
            logger.error("Failed to initialize engine.");
            return 1;
        }

        engine.run();
        return 0;
    }
}
