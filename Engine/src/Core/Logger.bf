using System;

namespace Engine.Core;

public static class logger
{
    public static void info(StringView message)
    {
        Console.WriteLine($"[INFO] {message}");
    }

    public static void error(StringView message)
    {
        Console.WriteLine($"[ERROR] {message}");
    }
}
