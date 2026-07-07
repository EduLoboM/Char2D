using System;

namespace Engine.Core;

public static class logger
{
    public static void info(StringView format, params Object[] args)
    {
        Console.Write("[INFO] ");
        Console.WriteLine(format, params args);
    }

    public static void error(StringView format, params Object[] args)
    {
        Console.Write("[ERROR] ");
        Console.WriteLine(format, params args);
    }

    public static void warn(StringView format, params Object[] args)
    {
        Console.Write("[WARN] ");
        Console.WriteLine(format, params args);
    }
}