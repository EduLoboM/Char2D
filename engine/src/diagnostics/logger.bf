using System;

namespace engine.diagnostics;

public static class logger
{

    public static void setup(StringView format, params Object[] args)
    {
        Console.Write("\x1b[1;31m[\x1b[1;31mS\x1b[1;33mE\x1b[1;32mT\x1b[1;36mU\x1b[1;34mP\x1b[1;34m]\x1b[0m \x1b[3m");
        Console.Write(format, params args);
        Console.WriteLine("\x1b[0m");
    }

    public static void load(StringView format, params Object[] args)
    {
        Console.Write("\x1b[1;32m[LOAD]\x1b[0m \x1b[3m");
        Console.Write(format, params args);
        Console.WriteLine("\x1b[0m");
    }

    public static void game(StringView format, params Object[] args)
    {
        Console.Write("\x1b[1;37m[GAME]\x1b[0m \x1b[3m");
        Console.Write(format, params args);
        Console.WriteLine("\x1b[0m");
    }

    public static void error(StringView format, params Object[] args)
    {
        Console.Write("\x1b[1;31m[ERROR]\x1b[0m \x1b[3m");
        Console.Write(format, params args);
        Console.WriteLine("\x1b[0m");
    }

    public static void warn(StringView format, params Object[] args)
    {
        Console.Write("\x1b[1;33m[WARN]\x1b[0m \x1b[3m");
        Console.Write(format, params args);
        Console.WriteLine("\x1b[0m");
    }
}